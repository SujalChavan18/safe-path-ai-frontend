/// Typed API exceptions for SafePath AI.
///
/// Provides a structured exception hierarchy that the [ApiClient]
/// throws, enabling callers to catch specific failure types.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// No network connectivity.
class NetworkException extends ApiException {
  const NetworkException({super.message = 'No internet connection'});
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Request timed out'});
}

/// 401 — Authentication required or token expired.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized — please log in again',
  }) : super(statusCode: 401);
}

/// 403 — Insufficient permissions.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied',
  }) : super(statusCode: 403);
}

/// 404 — Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
  }) : super(statusCode: 404);
}

/// 5xx — Server-side error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Internal server error',
    int? statusCode,
  }) : super(statusCode: statusCode ?? 500);
}

/// Request was cancelled.
class CancelledException extends ApiException {
  const CancelledException({
    super.message = 'Request was cancelled',
  });
}
