/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.statusCode]);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}









