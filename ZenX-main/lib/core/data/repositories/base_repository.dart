import '../../domain/repository.dart';
import '../../utils/result.dart';
import '../../errors/failures.dart';

/// Base repository implementation with common functionality
abstract class BaseRepository implements Repository {
  const BaseRepository();

  /// Handle network errors
  Result<T> handleNetworkError<T>(dynamic error) {
    return Result.failure(
      Failure.network(
        message: error.toString(),
      ),
    );
  }

  /// Handle server errors
  Result<T> handleServerError<T>(dynamic error, {int? statusCode}) {
    return Result.failure(
      Failure.server(
        message: error.toString(),
        statusCode: statusCode,
      ),
    );
  }

  /// Handle cache errors
  Result<T> handleCacheError<T>(dynamic error) {
    return Result.failure(
      Failure.cache(
        message: error.toString(),
      ),
    );
  }

  /// Handle unknown errors
  Result<T> handleUnknownError<T>(dynamic error) {
    return Result.failure(
      Failure.unknown(
        message: error.toString(),
      ),
    );
  }
}

