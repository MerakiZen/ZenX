import 'dart:async';
import '../../utils/typedefs.dart';
import '../repositories/base_repository.dart';

/// Base repository with reactive data flow support
/// Implements offline-first pattern with real-time updates
abstract class ReactiveRepository<T> extends BaseRepository {
  const ReactiveRepository();

  /// Watch all entities (reactive stream from local database)
  Stream<List<T>> watchAll();

  /// Watch single entity by ID
  Stream<T?> watchById(String id);

  /// Get all entities (one-time read from local database)
  AsyncResult<List<T>> getAll();

  /// Get single entity by ID (one-time read from local database)
  AsyncResult<T?> getById(String id);

  /// Create entity (write to local DB immediately, sync to server in background)
  AsyncResult<T> create(T entity);

  /// Update entity (write to local DB immediately, sync to server in background)
  AsyncResult<T> update(T entity);

  /// Delete entity (write to local DB immediately, sync to server in background)
  AsyncVoidResult delete(String id);

  /// Sync local data with remote server
  AsyncVoidResult sync();

  /// Get pending sync items
  Stream<List<SyncItem>> watchPendingSync();

  /// Retry failed sync operations
  AsyncVoidResult retryFailedSync();
}

/// Sync item for tracking pending operations
class SyncItem {
  final String id;
  final SyncOperation operation;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final int retryCount;

  SyncItem({
    required this.id,
    required this.operation,
    required this.timestamp,
    required this.data,
    this.retryCount = 0,
  });
}

enum SyncOperation {
  create,
  update,
  delete,
}









