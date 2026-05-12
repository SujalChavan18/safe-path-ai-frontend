import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/constants/app_constants.dart';

/// Dio interceptor that injects the Bearer token into every request.
///
/// Reads the access token from [FlutterSecureStorage] and attaches
/// it as an `Authorization` header. Skips auth endpoints.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  /// Endpoints that should NOT receive an auth header.
  static const _publicPaths = ['/auth/login', '/auth/register'];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isPublic = _publicPaths.any((p) => path.contains(p));

    if (!isPublic) {
      final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic here.
      // 1. Call refresh token endpoint
      // 2. Retry the original request
      // 3. If refresh fails, force logout
    }
    handler.next(err);
  }
}
