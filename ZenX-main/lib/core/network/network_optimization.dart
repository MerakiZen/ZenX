import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/result.dart';
import '../errors/failures.dart';

/// Network optimization utilities
class NetworkOptimization {
  NetworkOptimization._();

  /// Cache configuration for GraphQL
  static GraphQLCache createOptimizedCache() {
    return GraphQLCache(
      store: HiveStore(),
      // Cache policies
    );
  }

  /// Batch multiple queries into a single request
  static Future<Result<List<T>>> batchQueries<T>({
    required GraphQLClient client,
    required List<String> queries,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      // Combine queries into single batch request
      final batchQuery = queries.join('\n');
      final result = await client.query(QueryOptions(
        document: gql(batchQuery),
      ));

      if (result.hasException) {
        return Result.failure(
          Failure.network(message: result.exception.toString()),
        );
      }

      final data = result.data;
      if (data == null) {
        return const Result.failure(
          Failure.network(message: 'No data received'),
        );
      }

      // Parse results
      final items = <T>[];
      // Extract data for each query
      // This is simplified - actual implementation would parse each query result
      // In a real implementation, we would iterate through queries and parse each result separately
      if (data.isNotEmpty) {
        items.add(parser(data));
      }

      return Result.success(items);
    } catch (e) {
      return Result.failure(
        Failure.network(message: e.toString()),
      );
    }
  }

  /// Implement request deduplication
  static final Map<String, Future<Result<dynamic>>> _pendingRequests = {};

  static Future<Result<T>> deduplicateRequest<T>({
    required String key,
    required Future<Result<T>> Function() request,
  }) async {
    if (_pendingRequests.containsKey(key)) {
      final result = await _pendingRequests[key]!;
      return result as Result<T>;
    }

    final future = request();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(key);
    }
  }
}

/// Pagination helper for GraphQL queries
class PaginationHelper {
  final int pageSize;
  int _currentPage = 0;
  bool _hasMore = true;

  PaginationHelper({this.pageSize = 20});

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  void nextPage() {
    _currentPage++;
  }

  void reset() {
    _currentPage = 0;
    _hasMore = true;
  }

  void setHasMore(bool value) {
    _hasMore = value;
  }

  int get offset => _currentPage * pageSize;
  int get limit => pageSize;
}

