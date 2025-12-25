import 'dart:async';
import '../../utils/result.dart';
import '../../errors/failures.dart';
import '../datasource.dart';

/// Offline-first pattern implementation guide
/// 
/// This class provides utilities and patterns for implementing
/// offline-first data flow in repositories.
class OfflineFirstPattern {
  OfflineFirstPattern._();

  /// Write flow: Write to local DB immediately, sync to server in background
  /// 
  /// 1. User creates/updates data
  /// 2. Write to local database immediately
  /// 3. UI updates from local database (instant)
  /// 4. Sync to server in background
  /// 5. On success: Update local record with server ID
  /// 6. On failure: Mark for retry
  static Future<Result<T>> writeFlow<T>({
    required Future<Result<T>> Function() writeToLocal,
    required Future<Result<T>> Function(T) syncToRemote,
    required Future<void> Function(T) onSuccess,
    required Future<void> Function(Failure, T) onFailure,
  }) async {
    // Step 1-3: Write to local DB immediately
    final localResult = await writeToLocal();

    return localResult.when(
      success: (localItem) async {
        // Step 4: Sync to server in background (don't await)
        syncToRemote(localItem).then((remoteResult) {
          remoteResult.when(
            success: (serverItem) {
              // Step 5: Update local record with server data
              onSuccess(serverItem);
            },
            failure: (failure) {
              // Step 6: Mark for retry
              onFailure(failure, localItem);
            },
          );
        });

        // Return immediately with local data
        return Result.success(localItem);
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  /// Read flow: Display from local DB immediately, fetch from server in background
  /// 
  /// 1. User opens screen
  /// 2. Display data from local database immediately
  /// 3. Fetch from server in background
  /// 4. Merge server data with local database
  /// 5. UI updates automatically via Stream
  static Stream<T> readFlow<T>({
    required Stream<T> localStream,
    required Future<Result<T>> Function() fetchFromRemote,
    required Future<void> Function(T) mergeToLocal,
  }) {
    // Step 2: Start with local stream
    final controller = StreamController<T>.broadcast();

    // Subscribe to local stream
    final localSubscription = localStream.listen(
      (localData) {
        controller.add(localData);
      },
      onError: controller.addError,
    );

    // Step 3: Fetch from server in background
    fetchFromRemote().then((remoteResult) {
      remoteResult.when(
        success: (remoteData) {
          // Step 4: Merge server data with local database
          mergeToLocal(remoteData).then((_) {
            // Step 5: UI will update automatically via local stream
          });
        },
        failure: (failure) {
          // Log error but don't block UI
          // UI continues to show local data
        },
      );
    });

    controller.onCancel = () {
      localSubscription.cancel();
    };

    return controller.stream;
  }

  /// Conflict resolution: Last-write-wins
  static T resolveConflictLastWriteWins<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    return remoteTimestamp.isAfter(localTimestamp) ? remote : local;
  }

  /// Conflict resolution: Timestamp-based with user prompt
  static Future<T?> resolveConflictWithPrompt<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
    required Future<bool> Function(T local, T remote) showConflictDialog,
  }) async {
    final shouldUseRemote = await showConflictDialog(local, remote);
    return shouldUseRemote ? remote : local;
  }
}

/// Mixin for repositories implementing offline-first pattern
/// Note: This is a template - actual implementation depends on specific data sources
mixin OfflineFirstMixin<T> {
  /// Local data source
  LocalDataSource get localDataSource;

  /// Remote data source
  RemoteDataSource get remoteDataSource;

  /// Write entity with offline-first pattern
  /// Note: This requires data sources to implement save/update methods
  Future<Result<T>> writeOfflineFirst(T entity) {
    // TODO: Implement based on actual data source APIs
    // This is a placeholder
    return Future.value(Result.success(entity));
  }

  /// Read entity with offline-first pattern
  /// Note: This requires data sources to implement watch/get methods
  Stream<T> readOfflineFirst(String id) {
    // TODO: Implement based on actual data source APIs
    // This is a placeholder
    return Stream.value(null as T);
  }
}

