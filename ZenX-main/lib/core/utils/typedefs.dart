import 'result.dart';

/// Type definitions for common use cases

/// Async result type alias
typedef AsyncResult<T> = Future<Result<T>>;

/// Void result type
typedef VoidResult = Result<void>;

/// Async void result type
typedef AsyncVoidResult = Future<VoidResult>;

