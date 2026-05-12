/// Generic API response wrapper for SafePath AI.
///
/// Provides a consistent structure for all API responses,
/// making it easy to handle success/failure at the call site.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  /// Whether the request was successful.
  final bool success;

  /// The parsed response data (null on failure).
  final T? data;

  /// Server-provided message.
  final String? message;

  /// HTTP status code.
  final int? statusCode;

  /// Validation or field-level errors from the server.
  final Map<String, dynamic>? errors;

  /// Factory for a successful response.
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  /// Factory for a failed response.
  factory ApiResponse.failure({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Parse a raw JSON map into an [ApiResponse].
  ///
  /// [fromJson] converts the `data` field into type [T].
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
}
