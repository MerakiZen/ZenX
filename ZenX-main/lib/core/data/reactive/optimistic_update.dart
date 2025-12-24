import '../../utils/result.dart';
import '../../utils/typedefs.dart';
import '../../errors/failures.dart';

/// Helper for optimistic UI updates
class OptimisticUpdate<T> {
  /// Execute an operation with optimistic update
  /// 
  /// [optimisticValue] is the value to show immediately
  /// [operation] is the actual async operation
  /// [onSuccess] is called when operation succeeds
  /// [onFailure] is called when operation fails (for rollback)
  static Future<Result<T>> execute<T>({
    required T optimisticValue,
    required AsyncResult<T> Function() operation,
    required void Function(T) onSuccess,
    required void Function(Failure) onFailure,
  }) async {
    // Show optimistic value immediately
    onSuccess(optimisticValue);

    // Execute actual operation
    final result = await operation();

    result.when(
      success: (actualValue) {
        // Operation succeeded, keep the changes
        onSuccess(actualValue);
      },
      failure: (failure) {
        // Operation failed, rollback
        onFailure(failure);
      },
    );

    return result;
  }

  /// Execute a list operation with optimistic update
  static Future<Result<List<T>>> executeList<T>({
    required List<T> optimisticList,
    required AsyncResult<List<T>> Function() operation,
    required void Function(List<T>) onSuccess,
    required void Function(Failure) onFailure,
  }) async {
    return execute<List<T>>(
      optimisticValue: optimisticList,
      operation: operation,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }

  /// Execute a create operation with optimistic update
  static Future<Result<T>> create<T>({
    required T newItem,
    required AsyncResult<T> Function() createOperation,
    required void Function(T) addItem,
    required void Function() removeItem,
    required void Function(Failure) showError,
  }) async {
    // Add item optimistically
    addItem(newItem);

    final result = await createOperation();

    result.when(
      success: (createdItem) {
        // Replace optimistic item with actual created item
        removeItem();
        addItem(createdItem);
      },
      failure: (failure) {
        // Remove optimistic item on failure
        removeItem();
        showError(failure);
      },
    );

    return result;
  }

  /// Execute an update operation with optimistic update
  static Future<Result<T>> update<T>({
    required T updatedItem,
    required T originalItem,
    required AsyncResult<T> Function() updateOperation,
    required void Function(T) updateItem,
    required void Function(T) revertItem,
    required void Function(Failure) showError,
  }) async {
    // Update item optimistically
    updateItem(updatedItem);

    final result = await updateOperation();

    result.when(
      success: (actualItem) {
        // Update with actual item from server
        updateItem(actualItem);
      },
      failure: (failure) {
        // Revert to original item on failure
        revertItem(originalItem);
        showError(failure);
      },
    );

    return result;
  }

  /// Execute a delete operation with optimistic update
  static Future<Result<void>> delete<T>({
    required T itemToDelete,
    required AsyncVoidResult Function() deleteOperation,
    required void Function(T) removeItem,
    required void Function(T) restoreItem,
    required void Function(Failure) showError,
  }) async {
    // Remove item optimistically
    removeItem(itemToDelete);

    final result = await deleteOperation();

    result.when(
      success: (_) {
        // Item successfully deleted, keep it removed
      },
      failure: (failure) {
        // Restore item on failure
        restoreItem(itemToDelete);
        showError(failure);
      },
    );

    return result;
  }
}

