import 'package:freezed_annotation/freezed_annotation.dart';
import '../errors/failures.dart';

part 'result.freezed.dart';

/// Result type for handling success and failure cases
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Returns true if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is a failure
  bool get isFailure => this is FailureResult<T>;

  /// Returns the data if successful, null otherwise
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Returns the failure if present, null otherwise
  Failure? get failureOrNull => when(
        success: (_) => null,
        failure: (failure) => failure,
      );

  /// Maps the success value to a new type
  Result<R> map<R>(R Function(T) mapper) {
    return when(
      success: (data) => Result.success(mapper(data)),
      failure: (failure) => Result.failure(failure),
    );
  }

  /// Maps the failure to a new failure
  Result<T> mapFailure(Failure Function(Failure) mapper) {
    return when(
      success: (data) => Result.success(data),
      failure: (failure) => Result.failure(mapper(failure)),
    );
  }
}









