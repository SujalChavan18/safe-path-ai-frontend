import 'dart:io';

import 'package:dio/dio.dart';

import '../api/api_exceptions.dart';
import '../utils/logger.dart';
import 'failures.dart';

/// Maps exceptions to domain [Failure] types and user-friendly messages.
///
/// Use this at the repository layer to convert infrastructure
/// exceptions into clean domain failures.
class ErrorHandler {
  ErrorHandler._();

  /// Convert any exception to a [Failure].
  static Failure handleException(Object error, [StackTrace? stackTrace]) {
    AppLogger.error(
      'Exception caught: $error',
      error: error,
      stackTrace: stackTrace,
    );

    if (error is ApiException) return _mapApiException(error);
    if (error is DioException) return _mapDioException(error);
    if (error is SocketException) return const NetworkFailure();
    if (error is FormatException) {
      return ServerFailure(message: 'Invalid response format: ${error.message}');
    }

    return UnknownFailure(message: error.toString());
  }

  /// Map [ApiException] subtypes to [Failure].
  static Failure _mapApiException(ApiException error) {
    return switch (error) {
      NetworkException() => const NetworkFailure(),
      TimeoutException() => const NetworkFailure(
          message: 'Request timed out. Please try again.',
        ),
      UnauthorizedException() => AuthFailure(message: error.message),
      ForbiddenException() => AuthFailure(message: error.message),
      NotFoundException() => ServerFailure(message: error.message),
      ServerException() => ServerFailure(message: error.message),
      CancelledException() => ServerFailure(message: error.message),
      _ => ServerFailure(message: error.message),
    };
  }

  /// Map [DioException] to [Failure].
  static Failure _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure(message: 'Connection timed out. Please try again.'),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.cancel =>
        const ServerFailure(message: 'Request was cancelled'),
      _ => ServerFailure(message: error.message ?? 'An error occurred'),
    };
  }

  /// Get a user-friendly error message from a [Failure].
  static String getUserMessage(Failure failure) {
    return failure.message;
  }
}
