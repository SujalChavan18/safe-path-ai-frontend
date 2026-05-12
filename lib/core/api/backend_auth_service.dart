import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/constants/api_constants.dart';
import 'api_client.dart';

class BackendAuthService {
  BackendAuthService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  final ApiClient _client = ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    final token = data['token'];

    if (token != null) {
      await _storage.write(
        key: 'access_token',
        value: token,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    final token = data['token'];

    if (token != null) {
      await _storage.write(
        key: 'access_token',
        value: token,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}