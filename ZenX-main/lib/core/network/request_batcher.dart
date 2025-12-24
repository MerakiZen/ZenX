import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';

/// Request batcher for combining multiple GraphQL queries
class RequestBatcher {
  RequestBatcher._();

  final Map<String, Completer<QueryResult>> _pendingRequests = {};
  Timer? _batchTimer;
  final Duration _batchDelay = const Duration(milliseconds: 50);

  /// Batch a query request
  Future<QueryResult> batchQuery({
    required GraphQLClient client,
    required String query,
    Map<String, dynamic>? variables,
  }) async {
    final requestKey = _generateRequestKey(query, variables);
    final completer = Completer<QueryResult>();

    _pendingRequests[requestKey] = completer;

    // Start batch timer if not already started
    _batchTimer ??= Timer(_batchDelay, () {
      _executeBatch(client);
    });

    return completer.future;
  }

  /// Generate unique key for request
  String _generateRequestKey(String query, Map<String, dynamic>? variables) {
    final varsString = variables?.toString() ?? '';
    return '$query$varsString';
  }

  /// Execute batched requests
  Future<void> _executeBatch(GraphQLClient client) async {
    final requests = Map<String, Completer<QueryResult>>.from(_pendingRequests);
    _pendingRequests.clear();
    _batchTimer = null;

    // Combine queries into single batch
    // This is simplified - actual implementation would use GraphQL batching
    for (final entry in requests.entries) {
      try {
        // Execute individual query
        // In production, this would be a single batched request
        final result = await client.query(
          QueryOptions(
            document: gql(entry.key.split('{')[0]), // Simplified
          ),
        );
        entry.value.complete(result);
      } catch (e) {
        entry.value.completeError(e);
      }
    }
  }

  /// Cancel all pending requests
  void cancelAll() {
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError('Batch cancelled');
      }
    }
    _pendingRequests.clear();
    _batchTimer?.cancel();
    _batchTimer = null;
  }
}

/// Extension for batching GraphQL queries
extension GraphQLBatching on GraphQLClient {
  /// Batch multiple queries into single request
  Future<List<QueryResult>> batchQueries(
    List<QueryOptions> queries,
  ) async {
    // This would use GraphQL batching if supported
    // For now, execute in parallel
    final futures = queries.map((query) => this.query(query));
    return Future.wait(futures);
  }
}









