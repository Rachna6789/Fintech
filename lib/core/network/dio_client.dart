// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io' show X509Certificate, HttpClient;
import 'dart:math';

import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../services/secure_storage_service.dart';
import 'api_exception.dart';

typedef TokenRefreshHandler = Future<String?> Function();
typedef CertificateValidation = bool Function(X509Certificate certificate, String host);

class DioClient {
  DioClient({
    required EnvConfig config,
    required SecureStorageService secureStorageService,
    this.tokenRefreshHandler,
    this.certificateValidation,
    int maxRetries = 2,
  })  : _secureStorageService = secureStorageService,
        _maxRetries = maxRetries,
        _defaultTimeout = config.requestTimeout,
        dio = Dio(BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: config.requestTimeout,
          sendTimeout: config.requestTimeout,
          receiveTimeout: config.requestTimeout,
          headers: const {
            Headers.acceptHeader: Headers.jsonContentType,
            Headers.contentTypeHeader: Headers.jsonContentType,
          },
        )) {
    // Attach interceptors
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorageService.readAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        // Handle 401 by attempting token refresh once
        if (err.response?.statusCode == 401 && tokenRefreshHandler != null) {
          try {
            final newToken = await tokenRefreshHandler!();
            if (newToken != null && newToken.isNotEmpty) {
              await _secureStorageService.saveAuthToken(newToken);
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final cloned = await dio.fetch(requestOptions);
              return handler.resolve(cloned);
            }
          } catch (_) {
            // fallthrough to error handling below
          }
        }
        handler.next(err);
      },
    ));

    if (config.enableNetworkLogging) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    // Certificate pinning hook for IO platforms (optional - provide certificateValidation)
    try {
      // Only available on dart:io platforms
      final adapter = dio.httpClientAdapter;
      if (certificateValidation != null) {
        // Use the IO HttpClient if available
        // Note: DefaultHttpClientAdapter is platform dependent; we set badCertificateCallback when possible
        // If running on Flutter (IO), cast to `HttpClient` via onHttpClientCreate when supported by adapter.
        // This is a best-effort hook; provide a certificateValidation callback for real pinning logic.
        // Many platforms use `DefaultHttpClientAdapter` which exposes `onHttpClientCreate`.
        // We attempt to set it via dynamic invocation to avoid import issues on web.
        try {
          (adapter as dynamic).onHttpClientCreate = (HttpClient client) {
            client.badCertificateCallback = (X509Certificate cert, String host, int port) {
              try {
                return certificateValidation!(cert, host);
              } catch (_) {
                return false;
              }
            };
            return client;
          };
        } catch (_) {}
      }
    } catch (_) {}
  }

  final Dio dio;
  final SecureStorageService _secureStorageService;
  final TokenRefreshHandler? tokenRefreshHandler;
  final CertificateValidation? certificateValidation;

  final Duration _defaultTimeout;
  final int _maxRetries;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Duration? timeout,
  }) {
    return _request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      timeout: timeout,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Duration? timeout,
  }) {
    return _request<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      timeout: timeout,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Duration? timeout,
  }) {
    return _request<T>(
      path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      timeout: timeout,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Duration? timeout,
  }) {
    return _request<T>(
      path,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      timeout: timeout,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    Duration? timeout,
  }) {
    return _request<T>(
      path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      timeout: timeout,
    );
  }

  Future<Response<T>> uploadMultipart<T>(
    String path, {
    Map<String, dynamic>? data,
    required List<MultipartFile> files,
    String filesField = 'files',
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    Duration? timeout,
  }) async {
    final form = FormData();
    if (data != null) {
      data.forEach((key, value) {
        form.fields.add(MapEntry(key, value?.toString() ?? ''));
      });
    }
    for (final file in files) {
      form.files.add(MapEntry(filesField, file));
    }

    return _request<T>(
      path,
      method: 'POST',
      data: form,
      queryParameters: queryParameters,
      options: options ?? Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      timeout: timeout,
    );
  }

  Future<Response<T>> _request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Duration? timeout,
  }) async {
    final effectiveOptions = options ?? Options();
    effectiveOptions.method = method;

    final millis = timeout?.inMilliseconds ?? _defaultTimeout.inMilliseconds;

    int attempt = 0;
    while (true) {
      try {
        final r = await dio.request<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: effectiveOptions.copyWith(method: method),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ).timeout(Duration(milliseconds: millis));
        return r;
      } on DioException catch (err) {
        // classify timeout-like exceptions

        // If unauthorized and token refresh already attempted in interceptor, fall through
        if (err.response != null) {
          throw ApiException.fromDioError(err);
        }

        // Network errors: retry with backoff
        attempt++;
        if (attempt > _maxRetries || !(_shouldRetryOnError(err))) {
          throw ApiException.fromDioError(err);
        }

        final backoffMs = _exponentialBackoff(attempt);
        await Future.delayed(Duration(milliseconds: backoffMs));
        continue;
      } on TimeoutException {
        attempt++;
        if (attempt > _maxRetries) {
          throw ApiException(message: 'Request timed out', code: 'timeout');
        }
        final backoffMs = _exponentialBackoff(attempt);
        await Future.delayed(Duration(milliseconds: backoffMs));
        continue;
      } catch (e) {
        throw ApiException(message: e.toString());
      }
    }
  }

  bool _shouldRetryOnError(DioException err) {
    if (err.type == DioExceptionType.cancel) return false;
    if (err.type == DioExceptionType.badResponse) return false; // server responded with 4xx/5xx
    return true;
  }

  int _exponentialBackoff(int attempt, {int base = 300}) {
    final jitter = Random().nextInt(100);
    return (base * pow(2, attempt - 1)).toInt() + jitter;
  }
}
