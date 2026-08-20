class ApiResponse<T> {
  const ApiResponse({required this.data, this.message, this.statusCode});

  final T data;
  final String? message;
  final int? statusCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJson,
  ) {
    return ApiResponse<T>(
      data: fromJson(json['data']),
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
    );
  }
}
