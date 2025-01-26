/// Base class for authentication-related exceptions
class AuthException implements Exception {
  final String message;
  final String code;
  final dynamic details;

  AuthException({
    required this.message,
    required this.code,
    this.details,
  });

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

/// Thrown when authentication credentials are invalid
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({String? message})
      : super(
          message: message ?? 'Invalid username or password',
          code: 'invalid_credentials',
        );
}

/// Thrown when authentication token is expired
class TokenExpiredException extends AuthException {
  TokenExpiredException()
      : super(
          message: 'Authentication token has expired',
          code: 'token_expired',
        );
}

/// Thrown when refresh token operation fails
class TokenRefreshException extends AuthException {
  TokenRefreshException({String? message})
      : super(
          message: message ?? 'Failed to refresh authentication token',
          code: 'token_refresh_failed',
        );
}

/// Thrown when user is not authenticated
class UnauthenticatedException extends AuthException {
  UnauthenticatedException()
      : super(
          message: 'User is not authenticated',
          code: 'unauthenticated',
        );
}

/// Thrown when an operation requires specific permissions
class UnauthorizedException extends AuthException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'User is not authorized for this operation',
          code: 'unauthorized',
        );
}
