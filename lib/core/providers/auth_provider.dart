import 'package:flutter/material.dart';

import '../api/backend_auth_service.dart';
import '../utils/logger.dart';

/// Authentication state for the UI to react to.
enum AuthStatus {
  initial,
 authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    BackendAuthService? authService,
  }) : _authService = authService ?? BackendAuthService();

  final BackendAuthService _authService;

  // ═══════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════

  AuthStatus _status = AuthStatus.unauthenticated;

  Map<String, dynamic>? _user;

  String? _errorMessage;

  bool _isLoading = false;

  // ═══════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════

  AuthStatus get status => _status;

  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  bool get isLoading => _isLoading;

  String? get userId => _user?['id'];

  String? get email => _user?['email'];

  String? get displayName => _user?['name'];

  String? get errorMessage => _errorMessage;

  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _executeAuthAction(() async {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _user = response['user'];

      _status = AuthStatus.authenticated;

      AppLogger.info(
        'Login successful',
        tag: 'AuthProvider',
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _executeAuthAction(() async {
      final response = await _authService.register(
        name: displayName,
        email: email,
        password: password,
      );

      _user = response['user'];

      _status = AuthStatus.authenticated;

      AppLogger.info(
        'Registration successful',
        tag: 'AuthProvider',
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════

  Future<bool> sendPasswordReset(String email) async {
    _errorMessage = 'Password reset not implemented yet';

    notifyListeners();

    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // GOOGLE SIGN IN
  // ═══════════════════════════════════════════════════════════

  Future<bool> signInWithGoogle() async {
    _errorMessage = 'Google Sign-In removed for backend auth';

    notifyListeners();

    return false;
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();

      _user = null;

      _status = AuthStatus.unauthenticated;

      _clearError();

      AppLogger.info(
        'Logout successful',
        tag: 'AuthProvider',
      );
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ERROR MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  void clearError() {
    _clearError();

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════

  Future<bool> _executeAuthAction(
    Future<void> Function() action,
  ) async {
    _setLoading(true);

    _clearError();

    try {
      await action();

      _setLoading(false);

      return true;
    } catch (e) {
      _handleError(e);

      _setLoading(false);

      return false;
    }
  }

  void _handleError(Object error) {
    _errorMessage = error.toString();

    _status = AuthStatus.error;

    AppLogger.error(
      'Authentication error: $error',
      tag: 'AuthProvider',
      error: error,
    );

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    if (value) {
      _status = AuthStatus.loading;
    }

    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}