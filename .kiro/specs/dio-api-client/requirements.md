# Requirements Document

## Introduction

This document specifies requirements for a production-ready Dio API client for the **fintrack** Flutter/Dart fintech application. The existing `DioClient` in `lib/core/network/` provides a basic foundation (base URL, timeouts, Bearer token injection, conditional logging). This feature upgrades it to a fully production-grade layer that adds: a complete HTTP method surface (GET, POST, PUT, DELETE, PATCH), multipart file upload, JWT token refresh with automatic retry on 401, exponential-backoff retry on network errors and 5xx responses, fine-grained timeout configuration, and structured error handling — all integrated with the existing Riverpod, `SecureStorageService`, and `EnvConfig` patterns.

---

## Glossary

- **DioClient**: The singleton Dio wrapper in `lib/core/network/dio_client.dart` responsible for all HTTP communication.
- **ApiClient**: A higher-level service (wrapping `DioClient`) that exposes typed HTTP methods (`get`, `post`, `put`, `delete`, `patch`, `uploadFile`) and returns `Result<T>`.
- **Interceptor**: A Dio interceptor that intercepts requests, responses, or errors before they reach calling code.
- **AuthInterceptor**: The interceptor responsible for injecting the JWT Bearer token and handling token refresh on 401 responses.
- **RetryInterceptor**: The interceptor responsible for retrying failed requests on network errors or 5xx responses.
- **TokenService**: A service responsible for reading, writing, and refreshing JWT access and refresh tokens via `SecureStorageService`.
- **EnvConfig**: The existing environment configuration class providing `apiBaseUrl`, `requestTimeout`, and `enableNetworkLogging`.
- **SecureStorageService**: The existing secure key-value store for persisting tokens.
- **ApiResponse\<T\>**: The existing typed wrapper for successful API payloads.
- **ApiError**: A structured representation of an API error response (HTTP status code, server error code, human-readable message).
- **Result\<T\>**: The existing `sealed class Result<T>` (`Success<T>` | `FailureResult<T>`) used for error propagation.
- **NetworkException**: The existing `AppException` subclass representing network-level failures.
- **AuthException**: The existing `AppException` subclass representing authentication failures.

---

## Requirements

### Requirement 1: HTTP Method Surface

**User Story:** As a feature developer, I want a typed API client that exposes GET, POST, PUT, DELETE, and PATCH methods, so that I can make any REST call without writing raw Dio code.

#### Acceptance Criteria

1. THE `ApiClient` SHALL expose a `get<T>` method that sends an HTTP GET request to a given path and returns `Future<Result<T>>`.
2. THE `ApiClient` SHALL expose a `post<T>` method that sends an HTTP POST request with an optional JSON body and returns `Future<Result<T>>`.
3. THE `ApiClient` SHALL expose a `put<T>` method that sends an HTTP PUT request with an optional JSON body and returns `Future<Result<T>>`.
4. THE `ApiClient` SHALL expose a `delete<T>` method that sends an HTTP DELETE request and returns `Future<Result<T>>`.
5. THE `ApiClient` SHALL expose a `patch<T>` method that sends an HTTP PATCH request with an optional JSON body and returns `Future<Result<T>>`.
6. WHEN any HTTP method is called, THE `ApiClient` SHALL accept optional query parameters of type `Map<String, dynamic>` and merge them into the request URL.
7. WHEN any HTTP method is called, THE `ApiClient` SHALL accept an optional `fromJson` callback of type `T Function(dynamic json)` to deserialise the response body into `T`.
8. WHEN a response is received with HTTP status 200–299, THE `ApiClient` SHALL return `Success<T>` wrapping the deserialised value.
9. WHEN a response is received with any HTTP status outside 200–299, THE `ApiClient` SHALL return `FailureResult<T>` wrapping an appropriate `Failure`.

---

### Requirement 2: Multipart File Upload

**User Story:** As a feature developer, I want to upload files (e.g., profile pictures, KYC documents) via the API client, so that I can attach binary data to requests without writing Dio `FormData` boilerplate.

#### Acceptance Criteria

1. THE `ApiClient` SHALL expose an `uploadFile<T>` method that accepts a file path, a form field name, an endpoint path, and optional extra form fields of type `Map<String, String>`.
2. WHEN `uploadFile` is called, THE `ApiClient` SHALL construct a `FormData` payload containing the file as a `MultipartFile` and any provided extra fields.
3. WHEN `uploadFile` is called, THE `ApiClient` SHALL set the `Content-Type` header to `multipart/form-data`.
4. WHEN `uploadFile` is called, THE `ApiClient` SHALL report upload progress via an optional `onSendProgress` callback of type `void Function(int sent, int total)`.
5. WHEN the `uploadFile` HTTP request completes with status 200–299, THE `ApiClient` SHALL return `Success<T>`.
6. IF the file path does not correspond to an existing file, THEN THE `ApiClient` SHALL return `FailureResult` wrapping a `ValidationFailure` with a descriptive message before sending any network request.
7. IF any file read or access error occurs during the upload operation (including after initial validation passes), THEN THE `ApiClient` SHALL return `FailureResult` wrapping a `ValidationFailure` and SHALL NOT propagate a raw exception.

---

### Requirement 3: JWT Authentication and Token Refresh

**User Story:** As a security engineer, I want all authenticated requests to carry a valid JWT Bearer token and to automatically refresh the token on 401 responses, so that users are not logged out due to token expiry.

#### Acceptance Criteria

1. WHEN any request is dispatched, THE `AuthInterceptor` SHALL read the current access token from `SecureStorageService` and attach it as `Authorization: Bearer <token>`.
2. WHEN a response with HTTP status 401 is received, THE `AuthInterceptor` SHALL attempt a token refresh using the stored refresh token before retrying the original request exactly once.
3. WHEN a token refresh succeeds, THE `AuthInterceptor` SHALL persist the new access token and refresh token via `SecureStorageService`, then retry the original request with the new access token.
4. WHEN a token refresh fails (network error, 401 on the refresh endpoint, or missing refresh token), THE `AuthInterceptor` SHALL clear all stored auth tokens via `SecureStorageService.clearAuthSession` and reject the request with an `AuthFailure`.
5. WHILE a token refresh is in-flight, THE `AuthInterceptor` SHALL queue all concurrent requests and resolve them with the new token once refresh completes, rather than triggering multiple simultaneous refresh attempts.
6. WHEN a request path matches the token refresh endpoint, THE `AuthInterceptor` SHALL skip token injection and refresh logic to prevent infinite loops.
7. WHEN no access token is stored, THE `AuthInterceptor` SHALL dispatch the request without an `Authorization` header.

---

### Requirement 4: Retry Logic

**User Story:** As a reliability engineer, I want failed requests to be automatically retried with backoff on transient errors, so that the app is resilient to temporary network blips and server overload.

#### Acceptance Criteria

1. THE `RetryInterceptor` SHALL retry a failed request when the `DioException` type is `connectionError`, `connectionTimeout`, `sendTimeout`, or `receiveTimeout`.
2. THE `RetryInterceptor` SHALL retry a failed request when the HTTP response status code is 500, 502, 503, or 504.
3. THE `RetryInterceptor` SHALL NOT retry requests that fail due to HTTP status codes 400, 401, 403, 404, or 422.
4. THE `RetryInterceptor` SHALL NOT retry a request that uses an HTTP method listed as non-idempotent (POST), unless the request was explicitly flagged as safe to retry.
5. THE `RetryInterceptor` SHALL use exponential backoff, waiting `baseDelay * 2^(attempt - 1)` before each retry, where `baseDelay` is 500 milliseconds.
6. THE `RetryInterceptor` SHALL attempt a configurable maximum number of retries, defaulting to 3, before forwarding the error.
7. WHEN all retry attempts are exhausted, THE `RetryInterceptor` SHALL forward the original `DioException` to the next error handler.

---

### Requirement 5: Timeout Configuration

**User Story:** As a reliability engineer, I want per-request and per-client timeout settings, so that long-running or stalled requests do not block the UI indefinitely.

#### Acceptance Criteria

1. THE `DioClient` SHALL apply `connectTimeout`, `sendTimeout`, and `receiveTimeout` from `EnvConfig.requestTimeout` as default timeouts for all requests.
2. WHEN an individual HTTP method is called with an explicit `Duration timeout` parameter, THE `ApiClient` SHALL override the default timeout for that single request only.
3. WHEN `connectTimeout` elapses without a connection being established, THE `DioClient` SHALL propagate the first `DioExceptionType.connectionTimeout` error that occurs.
4. WHEN `receiveTimeout` elapses while waiting for a server response, THE `DioClient` SHALL propagate the first `DioExceptionType.receiveTimeout` error that occurs.
5. WHEN `sendTimeout` elapses while uploading a request body, THE `DioClient` SHALL propagate the first `DioExceptionType.sendTimeout` error that occurs.

---

### Requirement 6: Logging Interceptor

**User Story:** As a developer, I want detailed request and response logs in non-production environments, so that I can debug API interactions without exposing sensitive data in production.

#### Acceptance Criteria

1. WHEN `EnvConfig.enableNetworkLogging` is `true`, THE `DioClient` SHALL attach a logging interceptor that records request method, URL, headers, and body.
2. WHEN `EnvConfig.enableNetworkLogging` is `true`, THE `DioClient` SHALL attach a logging interceptor that records response status code, headers, and body.
3. WHEN `EnvConfig.enableNetworkLogging` is `false`, THE `DioClient` SHALL NOT attach any logging interceptor.
4. WHEN the logging interceptor is active, THE `DioClient` SHALL redact the value of the `Authorization` header in log output, replacing it with `Bearer [REDACTED]`.
5. WHEN the logging interceptor is active and an error occurs, THE `DioClient` SHALL log the error type and message.

---

### Requirement 7: Structured Error Handling

**User Story:** As a feature developer, I want all API errors to be mapped to typed `Failure` objects, so that calling code can handle errors with exhaustive pattern matching rather than catching raw exceptions.

#### Acceptance Criteria

1. WHEN a `DioException` of type `connectionError` is caught, THE `ApiClient` SHALL return `FailureResult` wrapping a `NetworkFailure` with a descriptive message.
2. WHEN a `DioException` of type `connectionTimeout`, `sendTimeout`, or `receiveTimeout` is caught, THE `ApiClient` SHALL return `FailureResult` wrapping a `NetworkFailure` with a timeout-specific message.
3. WHEN an HTTP 401 response is caught and token refresh has failed, THE `ApiClient` SHALL return `FailureResult` wrapping an `AuthFailure`.
4. WHEN an HTTP 400 or 422 response is caught, THE `ApiClient` SHALL return `FailureResult` wrapping a `ValidationFailure` containing the server's error message if present.
5. WHEN an HTTP 403 response is caught, THE `ApiClient` SHALL return `FailureResult` wrapping an `AuthFailure` with message "Access denied."
6. WHEN an HTTP 404 response is caught, THE `ApiClient` SHALL return `FailureResult` wrapping a `NetworkFailure` with message "Resource not found."
7. WHEN an HTTP 5xx response is caught after all retries are exhausted, THE `ApiClient` SHALL return `FailureResult` wrapping a `NetworkFailure` with message "Server error. Please try again later."
8. WHEN any unexpected exception (non-Dio) is caught, THE `ApiClient` SHALL return `FailureResult` wrapping an `UnknownFailure`.
9. THE `ApiClient` SHALL never throw an exception to calling code; all errors SHALL be encapsulated in `FailureResult`.

---

### Requirement 8: Singleton and Dependency Injection

**User Story:** As a developer, I want the API client to be a singleton managed by Riverpod, so that the entire app shares one configured Dio instance without redundant instantiation.

#### Acceptance Criteria

1. THE `DioClient` SHALL be instantiated exactly once per app lifecycle via a Riverpod `Provider`.
2. THE `ApiClient` SHALL be instantiated exactly once per app lifecycle via a Riverpod `Provider` that depends on the `DioClient` provider.
3. WHEN the `DioClient` provider is first accessed, THE `DioClient` SHALL configure all interceptors (auth, retry, logging) in the correct order: auth → retry → logging.
4. THE `dioProvider` SHALL remain available for callers that need raw `Dio` access (e.g., for Riverpod-based repository tests).
5. WHEN the application disposes the Riverpod container, THE `DioClient` SHALL close the underlying `Dio` instance and cancel any in-flight requests.
