import '../utils/typedefs.dart';

/// Base use case interface
/// All use cases should implement this interface
abstract class UseCase<Type, Params> {
  /// Execute the use case
  AsyncResult<Type> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<Type> {
  /// Execute the use case
  AsyncResult<Type> call();
}

/// Use case with void return type
abstract class UseCaseVoid<Params> {
  /// Execute the use case
  AsyncVoidResult call(Params params);
}

/// Use case with void return type and no parameters
abstract class UseCaseVoidNoParams {
  /// Execute the use case
  AsyncVoidResult call();
}









