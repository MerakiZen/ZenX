import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/typedefs.dart';
import '../errors/failures.dart';

/// Base state class for StateNotifier
abstract class BaseState {
  const BaseState();
}

/// State with loading indicator
class LoadingState extends BaseState {
  const LoadingState();
}

/// State with error
class ErrorState extends BaseState {
  final Failure failure;
  const ErrorState(this.failure);
}

/// State with data
class DataState<T> extends BaseState {
  final T data;
  const DataState(this.data);
}

/// Base StateNotifier with common functionality
abstract class BaseStateNotifier<T extends BaseState> extends StateNotifier<T> {
  BaseStateNotifier(super.state);

  /// Handle async operation with loading and error states
  Future<void> executeAsync<U>({
    required AsyncResult<U> Function() operation,
    required T Function(U data) onSuccess,
    required T Function(Failure failure) onError,
  }) async {
    state = const LoadingState() as T;
    
    final result = await operation();
    
    result.when(
      success: (data) => state = onSuccess(data),
      failure: (failure) => state = onError(failure),
    );
  }

  /// Handle async operation without loading state
  Future<void> executeAsyncSilent<U>({
    required AsyncResult<U> Function() operation,
    required void Function(U data) onSuccess,
    required void Function(Failure failure) onError,
  }) async {
    final result = await operation();
    
    result.when(
      success: onSuccess,
      failure: onError,
    );
  }
}

