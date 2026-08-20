# Design Document: Dio API Client

## Overview

This design upgrades `lib/core/network/` from a minimal Dio wrapper into a production-grade HTTP layer for the fintrack app. The new layer adds: a full REST method surface (`get`, `post`, `put`, `delete`, `patch`, `uploadFile`) returning `Future<Result<T>>`; JWT Bearer injection with automatic 401 → refresh → retry using a `Completer`-based queue to handle concurrent requests; exponential-backoff retry for network errors and 5xx responses; per-request timeout overrides; structured error mapping to the existing `Failure` sealed class hierarchy; and a redacting logging interceptor gated by `EnvConfig.enableNetworkLogging`. All components are wired as Riverpod singletons in `network_providers.dart`.

---

## File / Component Map

```
lib/core/network/
├── dio_client.dart          (REPLACE)   DioClient singleton — BaseOptions, interceptor chain, dispose()
├── auth_interceptor.dart    (NEW)       JWT injection, 401 refresh, Completer queue
├── retry_interceptor.dart   (NEW)       Exponential-backoff retry on network errors + 5xx
├── token_service.dart       (NEW)       Read/write/refresh JWT tokens via SecureStorageService
├── api_client.dart          (NEW)       Typed HTTP wrappers — get/post/put/delete/patch/uploadFile
├── api_error_mapper.dart    (NEW)       DioException → Failure mapping
├── network_providers.dart   (REPLACE)   Riverpod providers for all components
├── api_response.dart        (KEEP)      Unchanged — ApiResponse<T> wrapper for server envelope
└── network_info.dart        (KEEP)      Unchanged — connectivity check
```

---

## Interceptor Order

Interceptors are added to `Dio` in the following order. Requests flow top-to-bottom; responses and errors flow bottom-to-top.

```
┌─────────────────────────────────────┐
│             Outgoing Request        │
└────────────────┬────────────────────┘
                 │
         ┌───────▼───────┐
         │ AuthInterceptor│  1. Injects Bearer token (skips refresh endpoint)
         └───────┬───────┘
                 │
        ┌────────▼────────┐
        │ RetryInterceptor│  2. Catches network/5xx errors, applies backoff+retry
        └────────┬────────┘
                 │
        ┌────────▼────────┐
        │  LogInterceptor │  3. Logs request/response/errors (redacts Authorization)
        └────────┬────────┘
                 │
         ┌───────▼───────┐
         │  HTTP Layer   │  Actual network call
         └───────────────┘
```

Error flow on 401:
- `AuthInterceptor.onError` intercepts the 401.
- If a refresh is not already in-flight, it starts one (sets `_isRefreshing = true`, creates a `Completer`).
- Other requests that hit 401 concurrently are pushed onto `_pendingQueue`.
- On refresh success: completes the `Completer`, resolves all queued requests with the new token, retries all of them.
- On refresh failure: rejects the `Completer`, rejects all queued requests with `AuthFailure`, calls `clearAuthSession`.

---

## Components and Interfaces

### `TokenService`

**Responsibilities:** Single source of truth for token reads, writes, and the refresh HTTP call.

```dart
class TokenService {
  TokenService({
    required SecureStorageService secureStorage,
    required Dio rawDio,            // raw Dio (no auth interceptor) for refresh call
    required EnvConfig config,
  });

  // Reads
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  // Writes (atomic pair)
  Future<void> saveTokens({required String accessToken, required String refreshToken});

  // Refresh — calls POST /auth/refresh with stored refresh token
  // Returns new token pair or throws DioException / AuthException on failure
  Future<({String accessToken, String refreshToken})> refresh();
}
```

**Key decisions:**
- Uses a plain `Dio` instance (no auth interceptor) injected by the provider to call the refresh endpoint. This prevents the auth interceptor from wrapping the refresh call and triggering an infinite loop.
- The refresh endpoint path is `'/auth/refresh'` — this same constant is referenced by `AuthInterceptor` to skip token injection.

---

### `AuthInterceptor`

**Responsibilities:** Inject `Authorization: Bearer` on every request (except the refresh endpoint); handle 401 by refreshing once and retrying; queue concurrent requests during a refresh.

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required TokenService tokenService});

  // Internal state
  bool _isRefreshing = false;
  Completer<String>? _refreshCompleter;   // completes with new access token
  final List<_PendingRequest> _pendingQueue = [];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler);

  // Private helpers
  Future<void> _handleTokenRefresh(DioException err, ErrorInterceptorHandler handler);
  Future<Response<dynamic>> _retryRequest(RequestOptions options, String token);
}

// Internal record for deferred requests
class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}
```

**Token injection (`onRequest`):**
1. If the path starts with `'/auth/refresh'`, call `handler.next(options)` immediately.
2. Read access token from `TokenService.getAccessToken()`.
3. If non-null, set `options.headers['Authorization'] = 'Bearer $token'`.
4. Call `handler.next(options)`.

**401 handling (`onError`):**
1. If status ≠ 401 or path is `/auth/refresh`, forward the error unchanged.
2. If `_isRefreshing == true`, push to `_pendingQueue` and await `_refreshCompleter!.future`.
3. Otherwise, set `_isRefreshing = true`, create a new `Completer<String>`.
4. Try `TokenService.refresh()`:
   - On success: call `saveTokens`, complete the `Completer` with new access token, drain `_pendingQueue` by retrying each with new token, retry the triggering request.
   - On failure: complete the `Completer` with error, reject all queued requests with `DioException` (type `badResponse`, status 401), call `secureStorage.clearAuthSession()`, forward `AuthFailure`.
5. Reset `_isRefreshing = false`.

---

### `RetryInterceptor`

**Responsibilities:** Retry transient failures (network errors and 5xx) with exponential backoff; skip non-idempotent methods unless explicitly flagged.

```dart
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  final int maxRetries;
  final Duration baseDelay;

  // Header key used to flag a POST as safe to retry
  static const retryableHeader = 'x-retryable';

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler);

  // Computes wait: baseDelay * 2^(attempt - 1)
  Duration _backoffDelay(int attempt);

  bool _isRetryable(DioException err);
  bool _isRetryableMethod(RequestOptions options);
}
```

**Retry decision (`_isRetryable`):**
- Retryable DioException types: `connectionError`, `connectionTimeout`, `sendTimeout`, `receiveTimeout`.
- Retryable HTTP status codes: 500, 502, 503, 504.
- NOT retryable: 400, 401, 403, 404, 422, and any other 4xx.

**Method check (`_isRetryableMethod`):**
- GET, PUT, DELETE, PATCH → always retryable.
- POST → only if `options.headers[retryableHeader] == 'true'`.

**Backoff:**
```
attempt 1 → 500ms
attempt 2 → 1000ms
attempt 3 → 2000ms
```

**Retry tracking:** The current attempt count is stored in `options.extra['retryCount']` (starts at 0, incremented per retry). This avoids needing external state.

---

### `DioClient`

**Responsibilities:** Singleton Dio wrapper; builds `BaseOptions` from `EnvConfig`; assembles the interceptor chain; exposes the `Dio` instance; provides `dispose()`.

```dart
class DioClient {
  DioClient({
    required EnvConfig config,
    required AuthInterceptor authInterceptor,
    required RetryInterceptor retryInterceptor,
  });

  late final Dio dio;

  // Disposes the Dio instance; called by Riverpod onDispose
  void dispose();
}
```

**Constructor logic:**
1. Create `Dio` with `BaseOptions(baseUrl, connectTimeout, sendTimeout, receiveTimeout, headers: {accept: application/json, content-type: application/json})`.
2. Add interceptors in order: `authInterceptor`, `retryInterceptor`, conditional `LogInterceptor`.
3. If `config.enableNetworkLogging`, add a custom log interceptor that:
   - Logs method, URL, headers (with `Authorization` replaced by `Bearer [REDACTED]`), body.
   - Logs response status, headers, body.
   - Logs error type and message.

---

### `ApiErrorMapper`

**Responsibilities:** Pure mapping function from `DioException` or arbitrary `Object` to a `Failure`.

```dart
class ApiErrorMapper {
  static Failure map(Object error) {
    if (error is DioException) return _mapDioException(error);
    return UnknownFailure(message: 'An unexpected error occurred.', cause: error);
  }

  static Failure _mapDioException(DioException e);
}
```

**Mapping table:**

| Error condition | `Failure` type | Message |
|---|---|---|
| `connectionError` | `NetworkFailure` | `'No internet connection.'` |
| `connectionTimeout` | `NetworkFailure` | `'Connection timed out.'` |
| `sendTimeout` | `NetworkFailure` | `'Request upload timed out.'` |
| `receiveTimeout` | `NetworkFailure` | `'Server took too long to respond.'` |
| HTTP 400 | `ValidationFailure` | server message or `'Bad request.'` |
| HTTP 401 | `AuthFailure` | `'Session expired. Please log in again.'` |
| HTTP 403 | `AuthFailure` | `'Access denied.'` |
| HTTP 404 | `NetworkFailure` | `'Resource not found.'` |
| HTTP 422 | `ValidationFailure` | server message or `'Validation failed.'` |
| HTTP 5xx | `NetworkFailure` | `'Server error. Please try again later.'` |
| Non-Dio exception | `UnknownFailure` | `'An unexpected error occurred.'` |

Server message extraction: reads `e.response?.data['message']` (String) if present.

---

### `ApiClient`

**Responsibilities:** Typed HTTP wrappers returning `Future<Result<T>>`; per-request timeout override; file upload; delegates error mapping to `ApiErrorMapper`; never throws.

```dart
class ApiClient {
  ApiClient({required DioClient dioClient});

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Duration? timeout,
  });

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Duration? timeout,
  });

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Duration? timeout,
  });

  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Duration? timeout,
  });

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
    Duration? timeout,
  });

  Future<Result<T>> uploadFile<T>({
    required String path,
    required String filePath,
    required String fieldName,
    Map<String, String>? extraFields,
    T Function(dynamic json)? fromJson,
    void Function(int sent, int total)? onSendProgress,
    Duration? timeout,
  });
}
```

**Per-method implementation pattern:**
```dart
Future<Result<T>> get<T>(String path, {...}) async {
  try {
    final options = _buildOptions(timeout: timeout);
    final response = await _dio.get<dynamic>(path,
        queryParameters: queryParameters,
        options: options);
    return _handleResponse<T>(response, fromJson);
  } catch (e) {
    return FailureResult(ApiErrorMapper.map(e));
  }
}
```

**`_buildOptions(Duration? timeout)`:** Returns `Options` with `sendTimeout`, `receiveTimeout`, and `connectTimeout` set to `timeout` when non-null; otherwise returns `Options()` (inherits Dio defaults).

**`_handleResponse<T>(Response, T Function(dynamic)?)`:**
- Status 200–299: If `fromJson` is provided, return `Success(fromJson(response.data))`; otherwise return `Success(response.data as T)`.
- Other: return `FailureResult(ApiErrorMapper.map(DioException(...)))`.

**`uploadFile` additional logic:**
1. Check `File(filePath).existsSync()`; if false, return `FailureResult(ValidationFailure(message: 'File not found: $filePath'))` immediately.
2. Wrap the file I/O in a try/catch; any `FileSystemException` maps to `ValidationFailure`.
3. Pass `options: Options(contentType: 'multipart/form-data')`.

---

### `ApiResponse<T>` (unchanged)

Kept as-is. Feature repositories that consume a server-standard envelope (`{data, message, statusCode}`) can use `ApiResponse.fromJson` as their `fromJson` callback.

---

### `network_providers.dart` (updated)

```dart
// Token service needs a raw Dio (no auth interceptor) to call /auth/refresh.
// This is created inline, not as a full DioClient, to avoid circular dependency.
final _rawDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(envConfigProvider);
  return Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: config.requestTimeout,
    receiveTimeout: config.requestTimeout,
    sendTimeout: config.requestTimeout,
  ));
});

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(
    secureStorage: ref.watch(secureStorageServiceProvider),
    rawDio: ref.watch(_rawDioProvider),
    config: ref.watch(envConfigProvider),
  );
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(tokenService: ref.watch(tokenServiceProvider));
});

final retryInterceptorProvider = Provider<RetryInterceptor>((ref) {
  return const RetryInterceptor();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final client = DioClient(
    config: ref.watch(envConfigProvider),
    authInterceptor: ref.watch(authInterceptorProvider),
    retryInterceptor: ref.watch(retryInterceptorProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

// Raw Dio kept for repositories that need it directly (e.g., tests)
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(dioClient: ref.watch(dioClientProvider));
});
```

**Singleton guarantee:** Riverpod `Provider` (non-family, non-autoDispose) creates exactly one instance per `ProviderContainer`. The entire app shares one `ProviderScope` at the root, so `DioClient` and `ApiClient` are each instantiated once. `ref.onDispose` ensures `DioClient.dispose()` is called when the container is destroyed (app shutdown or test teardown).

---

## Data Flow Diagrams

### Normal Request (GET /portfolio)

```
ApiClient.get("/portfolio")
  └─► Dio.get()
        └─► AuthInterceptor.onRequest
              reads access token → sets Authorization: Bearer <token>
        └─► RetryInterceptor (no-op on success path)
        └─► LogInterceptor (logs request)
        └─► HTTP: GET https://api.fintrack.app/portfolio
        └─► HTTP 200 response
        └─► LogInterceptor (logs response)
  └─► ApiClient._handleResponse → Success<T>(fromJson(body))
```

### 401 Token Refresh Flow

```
Dio.get("/portfolio")
  └─► HTTP: 401 Unauthorized
  └─► AuthInterceptor.onError
        ├─ [first request to hit 401]
        │    _isRefreshing = true
        │    _refreshCompleter = Completer<String>()
        │    TokenService.refresh()
        │      └─ rawDio.post("/auth/refresh", {refreshToken})
        │         ├─ 200: saveTokens(newAccess, newRefresh)
        │         │        _refreshCompleter.complete(newAccess)
        │         │        drain _pendingQueue (retry each with newAccess)
        │         │        retry original request → Success<T>
        │         └─ 401/error: _refreshCompleter.completeError(...)
        │                       clearAuthSession()
        │                       forward AuthFailure
        │
        └─ [concurrent requests that also hit 401]
             pushed to _pendingQueue
             await _refreshCompleter.future
             retried with new token once completer resolves
```

### Retry on 5xx Flow

```
Dio.post("/transactions")
  └─► HTTP: 503 Service Unavailable
  └─► RetryInterceptor.onError
        attempt = 0
        _isRetryable → true (503)
        _isRetryableMethod → true (POST is non-retryable by default; skipped here)
        [if GET/PUT/PATCH/DELETE or POST+retryable header]
          wait 500ms → retry
          HTTP: 503 again → wait 1000ms → retry
          HTTP: 503 again → wait 2000ms → retry
          HTTP: 503 again → maxRetries reached → forward original DioException
  └─► ApiErrorMapper.map → NetworkFailure("Server error. Please try again later.")
  └─► ApiClient returns FailureResult<T>(NetworkFailure)
```

### Multipart Upload Flow

```
ApiClient.uploadFile(
  path: "/kyc/documents",
  filePath: "/data/user/0/com.fintrack/cache/id_front.jpg",
  fieldName: "document",
  extraFields: {"documentType": "national_id"},
  onSendProgress: (sent, total) => ...
)
  └─► File.existsSync() → true (or return ValidationFailure immediately)
  └─► FormData({
        "document": MultipartFile.fromFileSync(filePath, filename: "id_front.jpg"),
        "documentType": "national_id"
      })
  └─► Dio.post("/kyc/documents",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
        onSendProgress: callback
      )
  └─► AuthInterceptor injects Bearer token
  └─► HTTP: POST multipart → 200 OK
  └─► Success<T>
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Success result for any 2xx status code

*For any* HTTP response with a status code in the range [200, 299], `ApiClient` shall return a `Success<T>` result, never a `FailureResult`.

**Validates: Requirements 1.8, 2.5**

---

### Property 2: Failure result for any non-2xx status code

*For any* HTTP response with a status code outside [200, 299], `ApiClient` shall return a `FailureResult<T>`, never a `Success`.

**Validates: Requirements 1.9**

---

### Property 3: Query parameters appear in request URL

*For any* non-empty `Map<String, dynamic>` passed as `queryParameters`, every key-value pair shall appear in the URL of the outgoing Dio request.

**Validates: Requirements 1.6**

---

### Property 4: fromJson callback is applied to response body

*For any* response body JSON value and any `fromJson: T Function(dynamic)` callback, the `Success<T>` result shall contain exactly `fromJson(responseBody)`.

**Validates: Requirements 1.7**

---

### Property 5: Authorization header matches stored access token

*For any* non-empty access token string stored in `SecureStorageService`, the outgoing request's `Authorization` header shall equal `'Bearer $token'`.

**Validates: Requirements 3.1**

---

### Property 6: Exactly one refresh call for any number of concurrent 401s

*For any* N ≥ 1 concurrent requests that receive a 401 response while no refresh is in-flight, `TokenService.refresh()` shall be called exactly once (not N times), and all N requests shall eventually resolve with the new access token.

**Validates: Requirements 3.5**

---

### Property 7: New tokens persisted and used in retry after refresh

*For any* successful token refresh returning a new `(accessToken, refreshToken)` pair, both values shall be persisted to `SecureStorageService`, and the retried request's `Authorization` header shall equal `'Bearer $newAccessToken'` (round-trip: save → read → use).

**Validates: Requirements 3.3**

---

### Property 8: Retryable error types always trigger a retry (up to max)

*For any* `DioException` with type in `{connectionError, connectionTimeout, sendTimeout, receiveTimeout}` and any idempotent HTTP method, `RetryInterceptor` shall retry the request at least once (up to `maxRetries` times).

**Validates: Requirements 4.1**

---

### Property 9: 5xx responses trigger retry; 4xx responses do not

*For any* HTTP status code in `{500, 502, 503, 504}`, `RetryInterceptor` shall retry the request. *For any* HTTP status code in `{400, 401, 403, 404, 422}`, `RetryInterceptor` shall NOT retry and shall forward the error immediately.

**Validates: Requirements 4.2, 4.3**

---

### Property 10: Exponential backoff formula is correct for each attempt

*For any* retry attempt number `n` in [1, maxRetries], the wait duration before that retry shall equal `500ms × 2^(n-1)` (i.e., 500ms, 1000ms, 2000ms for the default 3-retry configuration).

**Validates: Requirements 4.5**

---

### Property 11: Per-request timeout override applies only to that request

*For any* explicit `Duration` value passed as the `timeout` parameter to any `ApiClient` method, the `RequestOptions` for that request shall have `connectTimeout == sendTimeout == receiveTimeout == timeout`, while all other concurrent requests retain the `EnvConfig` defaults.

**Validates: Requirements 5.2**

---

### Property 12: Authorization header is redacted in all log output

*For any* bearer token string (including empty string), when the logging interceptor is active, the logged output for the `Authorization` header shall contain `'Bearer [REDACTED]'` and shall NOT contain the actual token value.

**Validates: Requirements 6.4**

---

### Property 13: DioException type maps to correct Failure subtype

*For any* `DioException` with a defined type or HTTP status code, `ApiErrorMapper.map()` shall return a `Failure` of the subtype specified in the mapping table (NetworkFailure, AuthFailure, ValidationFailure, or UnknownFailure), and the `Failure.message` shall not be empty.

**Validates: Requirements 7.1, 7.2, 7.4, 7.8**

---

### Property 14: ApiClient never throws — all errors wrapped in FailureResult

*For any* combination of request parameters, mock network response (any status code, any DioException type, any non-Dio exception), `ApiClient` shall return a `Result<T>` and shall never propagate an uncaught exception to the caller.

**Validates: Requirements 7.9**

---

## Error Handling

### AuthInterceptor error states

| Scenario | Outcome |
|---|---|
| No access token in storage | Request proceeds without `Authorization` header |
| Refresh endpoint called with missing refresh token | `clearAuthSession()` called; `AuthFailure` returned |
| Refresh endpoint returns 401 | Same as above |
| Refresh endpoint network error | Same as above |
| Refresh succeeds | New tokens saved; original + queued requests retried |

### RetryInterceptor error states

| Scenario | Outcome |
|---|---|
| Retryable error, attempts < maxRetries | Wait `baseDelay * 2^(attempt-1)`, retry |
| Retryable error, attempts == maxRetries | Forward original `DioException` |
| Non-retryable status (4xx) | Forward immediately, no delay |
| POST without retry flag | Forward immediately |

### ApiErrorMapper — exhaustive coverage

Every `DioException` type is handled. Unrecognised HTTP status codes that are not 2xx fall through to `UnknownFailure`. The mapper is a pure static function with no side effects, making it easy to test exhaustively.

---

## Testing Strategy

### Unit Tests (example-based)

- `DioClient` constructor: verify `BaseOptions` reflects `EnvConfig` values; verify interceptor list contains `AuthInterceptor`, `RetryInterceptor`, optional `LogInterceptor` in that order.
- `AuthInterceptor`: test no-token path (no header), refresh endpoint skip, refresh success path, refresh failure path (session cleared).
- `RetryInterceptor`: test POST skipped, POST with header retried, retries exhausted, non-retryable 4xx forwarded.
- `ApiErrorMapper`: one test per mapping entry in the table (11 cases + unknown).
- `ApiClient.uploadFile`: file-not-found returns `ValidationFailure` without network call.
- `network_providers`: same instance returned from two `ref.read` calls.

### Property-Based Tests

Using [`dart_test`](https://pub.dev/packages/test) with manual generators (no additional PBT library needed — generators are simple Dart lists/ranges). Each property test runs a minimum of 100 iterations.

Tag format per test: `// Feature: dio-api-client, Property N: <property_text>`

| Property | Generator | Assertion |
|---|---|---|
| P1 — 2xx → Success | `Random().nextInt(100) + 200` | result is `Success` |
| P2 — non-2xx → Failure | status codes from `[100..199, 300..599]` | result is `FailureResult` |
| P3 — query params in URL | random `Map<String, String>` | URL contains each k=v |
| P4 — fromJson applied | random JSON map + identity `fromJson` | `Success.value == body` |
| P5 — Bearer header matches token | random alphanumeric token string | header == `'Bearer $token'` |
| P6 — single refresh for N concurrent 401s | N in [2..10] | refresh called once |
| P7 — tokens persisted + used in retry | random token pair | storage and header match |
| P8 — retryable errors retried | sample from retryable types | retry count ≥ 1 |
| P9 — 5xx retried, 4xx not | sample from each set | retry/no-retry as expected |
| P10 — backoff formula | attempt in [1, 2, 3] | delay == 500ms * 2^(n-1) |
| P11 — timeout override per-request | random Duration | `RequestOptions` timeouts == override |
| P12 — token redacted in logs | random token string | log output ≠ raw token |
| P13 — DioException → correct Failure | all DioExceptionType values + status codes | correct Failure subtype |
| P14 — ApiClient never throws | all error scenarios | no exception escapes |
