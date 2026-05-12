import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebase_auth_exceptions.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/firebase_service.dart';
import '../utils/logger.dart';

/// Authentication state for the UI to react to.
enum AuthStatus {
  /// Initial state — checking stored session.
  initial,

  /// User is authenticated.
  authenticated,

  /// User is not authenticated.
  unauthenticated,

  /// An auth operation is in progress.
  loading,

  /// An auth operation failed.
  error,
}

/// Production authentication state provider for SafePath AI.
///
/// Wraps [FirebaseAuthService] and exposes UI-reactive state via
/// [ChangeNotifier]. Listens to the Firebase auth state stream
/// for automatic sign-in/sign-out detection (e.g., token expiry,
/// account deletion from another device).
///
/// Usage:
/// ```dart
/// final auth = context.read<AuthProvider>();
/// await auth.loginWithEmail(email: '...', password: '...');
/// if (auth.isAuthenticated) { /* navigate */ }
/// ```
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    FirebaseAuthService? authService,
  }) : _authService = authService ?? FirebaseAuthService() {
    _initAuthStateListener();
  }

  final FirebaseAuthService _authService;

  // ═══════════════════════════════════════════════════════════
  //  STATE
  // ═══════════════════════════════════════════════════════════

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  StreamSubscription<User?>? _authStateSubscription;

  // ═══════════════════════════════════════════════════════════
  //  GETTERS
  // ═══════════════════════════════════════════════════════════

  /// Current authentication status.
  AuthStatus get status => _status;

  /// The authenticated Firebase user, or `null`.
  User? get user => _user;

  /// Whether a user is currently signed in.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// User's UID.
  String? get userId => _user?.uid;

  /// User's email.
  String? get email => _user?.email;

  /// User's display name.
  String? get displayName => _user?.displayName;

  /// User's photo URL.
  String? get photoUrl => _user?.photoURL;

  /// Whether the user's email is verified.
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// The last error message from a failed auth operation.
  String? get errorMessage => _errorMessage;

  /// Sign-in providers linked to the current account.
  List<String> get linkedProviders => _authService.linkedProviders;

  /// Whether the user signed in via Google.
  bool get isGoogleLinked => _authService.isGoogleLinked;

  // ═══════════════════════════════════════════════════════════
  //  AUTH STATE LISTENER
  // ═══════════════════════════════════════════════════════════

  /// Subscribe to Firebase auth state changes.
  ///
  /// This automatically updates the provider when:
  /// - The user signs in/out from another device
  /// - The user's token expires
  /// - The account is deleted/disabled
  void _initAuthStateListener() {
    _authStateSubscription = _authService.authStateChanges.listen(
      (User? user) {
        _user = user;
        if (user != null) {
          _status = AuthStatus.authenticated;
          AppLogger.info('Auth state: authenticated (${user.uid})', tag: 'AuthProvider');

          // Save FCM token on authentication
          _saveFcmTokenSilently();
        } else {
          _status = AuthStatus.unauthenticated;
          AppLogger.info('Auth state: unauthenticated', tag: 'AuthProvider');
        }
        notifyListeners();
      },
      onError: (error) {
        AppLogger.error('Auth state stream error: $error', tag: 'AuthProvider');
        _status = AuthStatus.error;
        _errorMessage = 'Authentication state error';
        notifyListeners();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  EMAIL / PASSWORD AUTH
  // ═══════════════════════════════════════════════════════════

  /// Sign in with email and password.
  ///
  /// Returns `true` on success, `false` on failure.
  /// On failure, [errorMessage] is populated.
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _executeAuthAction(() async {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    });
  }

  /// Register a new account with email, password, and display name.
  ///
  /// Returns `true` on success, `false` on failure.
  /// On failure, [errorMessage] is populated.
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _executeAuthAction(() async {
      await _authService.createAccountWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  GOOGLE SIGN-IN
  // ═══════════════════════════════════════════════════════════

  /// Sign in with Google.
  ///
  /// Returns `true` on success, `false` on failure or cancellation.
  /// On failure, [errorMessage] is populated.
  Future<bool> signInWithGoogle() async {
    return _executeAuthAction(() async {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // User cancelled — not an error, but not success either
        throw _UserCancelledException();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  SIGN OUT
  // ═══════════════════════════════════════════════════════════

  /// Sign out the current user.
  ///
  /// Clears all local auth state. FCM token is removed from Firestore.
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
      AppLogger.info('Logout successful', tag: 'AuthProvider');
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PASSWORD MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Send a password reset email.
  ///
  /// Returns `true` if the email was sent, `false` on error.
  Future<bool> sendPasswordReset(String email) async {
    return _executeAuthAction(() async {
      await _authService.sendPasswordResetEmail(email);
    });
  }

  /// Update the current user's password.
  ///
  /// Requires recent authentication.
  Future<bool> updatePassword(String newPassword) async {
    return _executeAuthAction(() async {
      await _authService.updatePassword(newPassword);
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  EMAIL VERIFICATION
  // ═══════════════════════════════════════════════════════════

  /// Send an email verification link.
  ///
  /// Returns `true` if sent, `false` on error.
  Future<bool> sendVerificationEmail() async {
    return _executeAuthAction(() async {
      await _authService.sendEmailVerification();
    });
  }

  /// Refresh the current user to check for email verification changes.
  Future<void> refreshUser() async {
    try {
      _user = await _authService.refreshUser();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to refresh user: $e', tag: 'AuthProvider');
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PROFILE MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Update the user's display name and/or photo URL.
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    return _executeAuthAction(() async {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      // Reload user to reflect changes
      _user = await _authService.refreshUser();
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  RE-AUTHENTICATION
  // ═══════════════════════════════════════════════════════════

  /// Re-authenticate the user (required before sensitive operations).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> reauthenticate({
    required String email,
    required String password,
  }) async {
    return _executeAuthAction(() async {
      await _authService.reauthenticate(
        email: email,
        password: password,
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  ACCOUNT DELETION
  // ═══════════════════════════════════════════════════════════

  /// Permanently delete the user's account.
  ///
  /// Returns `true` on success, `false` on error.
  /// May require recent authentication — call [reauthenticate] first.
  Future<bool> deleteAccount() async {
    return _executeAuthAction(() async {
      await _authService.deleteAccount();
      _user = null;
      _status = AuthStatus.unauthenticated;
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  ERROR MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Clear the current error message.
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Execute an auth action with standardized loading/error handling.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> _executeAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    _clearError();

    try {
      await action();
      _setLoading(false);
      return true;
    } on _UserCancelledException {
      // User cancelled (e.g., Google sign-in dialog) — not an error
      _setLoading(false);
      return false;
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  /// Map exceptions to user-friendly error messages.
  void _handleError(Object error) {
    if (error is FirebaseAuthException) {
      _errorMessage = FirebaseAuthExceptionMapper.fromException(error);
      _status = AuthStatus.error;
      AppLogger.error(
        'Auth error [${error.code}]: $_errorMessage',
        tag: 'AuthProvider',
      );
    } else {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = AuthStatus.error;
      AppLogger.error(
        'Unexpected auth error: $error',
        tag: 'AuthProvider',
        error: error,
      );
    }
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

  /// Silently save the FCM token after authentication.
  Future<void> _saveFcmTokenSilently() async {
    try {
      await FirebaseService.saveFcmTokenToFirestore();
    } catch (e) {
      AppLogger.warning('Failed to save FCM token: $e', tag: 'AuthProvider');
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

/// Internal exception for user cancellation (not a real error).
class _UserCancelledException implements Exception {}
