import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase Auth error codes to user-friendly messages.
///
/// Centralizes all error message strings so they can be easily
/// localized or updated without touching business logic.
///
/// Usage:
/// ```dart
/// try {
///   await FirebaseAuth.instance.signInWithEmailAndPassword(...);
/// } on FirebaseAuthException catch (e) {
///   final message = FirebaseAuthExceptionMapper.getMessage(e.code);
///   // show message to user
/// }
/// ```
class FirebaseAuthExceptionMapper {
  FirebaseAuthExceptionMapper._();

  /// Convert a [FirebaseAuthException] to a user-friendly message.
  static String fromException(FirebaseAuthException e) {
    return getMessage(e.code);
  }

  /// Convert a Firebase Auth error code to a user-friendly message.
  static String getMessage(String code) {
    return switch (code) {
      // ── Sign In ──
      'user-not-found' => 'No account found with this email address.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' =>
        'Invalid credentials. Please check your email and password.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' =>
        'This account has been disabled. Contact support for help.',

      // ── Registration ──
      'email-already-in-use' =>
        'An account already exists with this email address.',
      'weak-password' =>
        'Password is too weak. Use at least 8 characters with mixed case and numbers.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled. Please contact support.',

      // ── Rate Limiting ──
      'too-many-requests' =>
        'Too many failed attempts. Please wait a moment and try again.',

      // ── Network ──
      'network-request-failed' =>
        'Network error. Please check your internet connection and try again.',

      // ── Token / Session ──
      'requires-recent-login' =>
        'This action requires recent authentication. Please sign in again.',
      'session-expired' =>
        'Your session has expired. Please sign in again.',

      // ── Google Sign-In ──
      'account-exists-with-different-credential' =>
        'An account already exists with this email using a different sign-in method.',
      'invalid-verification-code' =>
        'Invalid verification code. Please try again.',
      'invalid-verification-id' =>
        'Verification session expired. Please request a new code.',

      // ── Phone Auth ──
      'invalid-phone-number' =>
        'Please enter a valid phone number with country code.',
      'quota-exceeded' =>
        'SMS quota exceeded. Please try again later.',
      'missing-phone-number' =>
        'Phone number is required.',

      // ── Account Management ──
      'credential-already-in-use' =>
        'This credential is already associated with another account.',
      'provider-already-linked' =>
        'This sign-in method is already linked to your account.',
      'no-such-provider' =>
        'This sign-in method is not linked to your account.',

      // ── Email Verification ──
      'expired-action-code' =>
        'This link has expired. Please request a new one.',
      'invalid-action-code' =>
        'This link is invalid. It may have already been used.',

      // ── Default ──
      _ => 'Authentication failed. Please try again. (Error: $code)',
    };
  }

  /// Whether the error code represents a user-recoverable error
  /// (vs. a system error that should be logged).
  static bool isUserRecoverable(String code) {
    const systemErrors = {
      'internal-error',
      'app-not-authorized',
      'app-not-installed',
      'captcha-check-failed',
      'web-storage-unsupported',
    };
    return !systemErrors.contains(code);
  }
}
