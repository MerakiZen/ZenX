import 'dart:async';
import 'dart:collection';

/// Connection pool for managing limited resources
/// Used for database connections, HTTP clients, etc.
class ConnectionPool<T> {
  final int maxSize;
  final T Function() createConnection;
  final Future<void> Function(T) closeConnection;
  final List<T> _available = [];
  final Set<T> _inUse = {};
  final Queue<Completer<T>> _waitQueue = Queue<Completer<T>>();

  ConnectionPool({
    required this.maxSize,
    required this.createConnection,
    required this.closeConnection,
  });

  /// Get connection from pool
  Future<T> getConnection() async {
    // Return available connection if exists
    if (_available.isNotEmpty) {
      final connection = _available.removeAt(0);
      _inUse.add(connection);
      return connection;
    }

    // Create new connection if under limit
    if (_inUse.length < maxSize) {
      final connection = createConnection();
      _inUse.add(connection);
      return connection;
    }

    // Wait for connection to become available
    final completer = Completer<T>();
    _waitQueue.add(completer);
    return completer.future;
  }

  /// Return connection to pool
  Future<void> returnConnection(T connection) async {
    if (!_inUse.contains(connection)) {
      return;
    }

    _inUse.remove(connection);

    // If there are waiters, give connection to them
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      _inUse.add(connection);
      completer.complete(connection);
    } else {
      // Otherwise, add to available pool
      _available.add(connection);
    }
  }

  /// Close all connections
  Future<void> closeAll() async {
    for (final connection in _available) {
      await closeConnection(connection);
    }
    _available.clear();

    for (final connection in _inUse) {
      await closeConnection(connection);
    }
    _inUse.clear();

    // Complete all waiters with error
    while (_waitQueue.isNotEmpty) {
      _waitQueue.removeFirst().completeError('Pool closed');
    }
  }

  /// Get pool statistics
  Map<String, dynamic> getStats() {
    return {
      'available': _available.length,
      'inUse': _inUse.length,
      'waiting': _waitQueue.length,
      'total': _available.length + _inUse.length,
      'maxSize': maxSize,
    };
  }
}

