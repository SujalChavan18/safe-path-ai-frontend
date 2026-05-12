/// Domain-level failure types for SafePath AI.
///
/// Used in the domain layer to represent operation failures
/// without leaking implementation details (e.g., Dio, Firebase).
sealed class Failure {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'Failure($code): $message';
}

/// Server/API failure.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network connectivity failure.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Authentication failure.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code = 'AUTH_ERROR'});
}

/// Cache/local storage failure.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local data.',
    super.code = 'CACHE_ERROR',
  });
}

/// Location/GPS failure.
class LocationFailure extends Failure {
  const LocationFailure({
    required super.message,
    super.code = 'LOCATION_ERROR',
  });
}

/// Permission denied failure.
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code = 'PERMISSION_DENIED',
  });
}

/// Validation failure (invalid input).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;
}

/// Unknown/unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
  });
}
