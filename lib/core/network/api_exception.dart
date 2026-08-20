// ignore_for_file: unnecessary_type_check, invalid_null_aware_operator

class ApiException implements Exception {
  ApiException({this.message = 'Unknown API error', this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'ApiException(code: $code, status: $statusCode, message: $message)';

  static ApiException fromDioError(Object error) {
    try {
      final e = error as dynamic;
      if (e.toString().contains('SocketException')) {
        return ApiException(message: 'Network error', code: 'network');
      }
    } catch (_) {}

    final dioError = error as dynamic;
    final response = dioError.response;
    if (response != null) {
      final status = response.statusCode as int?;
      final message = response.data is String
          ? response.data as String
          : (response.data is Map ? response.data['message']?.toString() : dioError.message.toString());
      return ApiException(message: message ?? 'HTTP error', statusCode: status, code: status?.toString());
    }

    final msg = (error is Error) ? error.toString() : (error?.toString() ?? 'Unknown');
    return ApiException(message: msg);
  }
}
