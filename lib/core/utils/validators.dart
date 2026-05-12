/// Input validators for SafePath AI.
///
/// Provides static validation methods for common input types.
/// Returns `null` on success, or an error message string on failure.
class Validators {
  Validators._();

  /// Validate email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength.
  ///
  /// Requirements: ≥ 8 chars, uppercase, lowercase, digit.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Validate password confirmation matches.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate phone number format.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleaned)) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  /// Validate required non-empty text.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length.
  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length.
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }
}
