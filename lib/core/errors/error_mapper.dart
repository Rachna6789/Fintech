import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';
import 'failure.dart';

class ErrorMapper {
  const ErrorMapper._();

  static Failure toFailure(Object error) {
    if (error is Failure) return error;

    if (error is AppException) {
      return switch (error) {
        NetworkException() => NetworkFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
        CacheException() => CacheFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
        AuthException() => AuthFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
        ValidationException() => ValidationFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
        UnknownException() => UnknownFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
        AppException() => UnknownFailure(
            message: error.message,
            code: error.code,
            cause: error.cause,
          ),
      };
    }

    if (error is DioException) {
      return NetworkFailure(
        message: _dioMessage(error),
        code: error.response?.statusCode?.toString(),
        cause: error,
      );
    }

    if (error is FirebaseAuthException) {
      return AuthFailure(
        message: error.message ?? 'Authentication failed.',
        code: error.code,
        cause: error,
      );
    }

    if (error is FirebaseException) {
      return UnknownFailure(
        message: error.message ?? 'Firebase operation failed.',
        code: error.code,
        cause: error,
      );
    }

    return UnknownFailure(
      message: 'Something went wrong. Please try again.',
      cause: error,
    );
  }

  static String _dioMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.sendTimeout => 'Request timed out.',
      DioExceptionType.receiveTimeout => 'Server response timed out.',
      DioExceptionType.transformTimeout => 'Response processing timed out.',
      DioExceptionType.badCertificate => 'Unable to verify server certificate.',
      DioExceptionType.badResponse => 'Server returned an unexpected response.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.connectionError => 'No internet connection.',
      DioExceptionType.unknown => 'Network request failed.',
    };
  }
}
