import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Centralized Dio HTTP client for SafePath AI.
///
/// Singleton that provides typed request methods with automatic
/// error mapping, interceptors, and response parsing.
///
/// Usage:
/// ```dart
/// final client = ApiClient.instance;
/// final response = await client.get('/user/profile');
/// ```
class ApiClient {
  ApiClient._() {
    _dio = Dio(_baseOptions);
    _initInterceptors();
  }

  static ApiClient? _instance;

  /// Singleton accessor.
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio _dio;

  /// Expose Dio for advanced use cases (e.g., file uploads).
  Dio get dio => _dio;

  // ── Base Options ──
  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    responseType: ResponseType.json,
  );

  void _initInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);
  }

  // ═════════════════════════════════════════════════════════
  //  HTTP METHODS
  // ═════════════════════════════════════════════════════════

  /// GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// PUT request.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// PATCH request.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// DELETE request.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  //  TYPED RESPONSE HELPERS
  // ═════════════════════════════════════════════════════════

  /// Perform a GET and parse into [ApiResponse<T>].
  Future<ApiResponse<T>> getTyped<T>(
    String path, {
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await get(path, queryParameters: queryParameters);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      fromJson,
    );
  }

  /// Perform a POST and parse into [ApiResponse<T>].
  Future<ApiResponse<T>> postTyped<T>(
    String path, {
    required T Function(dynamic) fromJson,
    dynamic data,
  }) async {
    final response = await post(path, data: data);
    return ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      fromJson,
    );
  }

  // ═════════════════════════════════════════════════════════
  //  ERROR MAPPING
  // ═════════════════════════════════════════════════════════

  /// Wraps a Dio call and maps [DioException] to typed [ApiException].
  Future<Response> _safeRequest(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const CancelledException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map ? data['message'] as String? : null;

        return switch (statusCode) {
          401 => UnauthorizedException(message: message ?? 'Unauthorized'),
          403 => ForbiddenException(message: message ?? 'Forbidden'),
          404 => NotFoundException(message: message ?? 'Not found'),
          int s when s >= 500 => ServerException(
              message: message ?? 'Server error',
              statusCode: statusCode,
            ),
          _ => ApiException(
              message: message ?? 'Request failed',
              statusCode: statusCode,
              data: data,
            ),
        };

      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred',
        );
    }
  }

  // ═════════════════════════════════════════════════════════
  //  CONFIGURATION
  // ═════════════════════════════════════════════════════════

  /// Update the base URL (e.g., for environment switching).
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Reset the singleton (useful for testing).
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}
