/// Pagination helper for cursor-based pagination
class PaginationHelper {
  final int pageSize;
  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;

  PaginationHelper({this.pageSize = 20});

  /// Current cursor
  String? get cursor => _nextCursor;

  /// Check if there are more pages
  bool get hasMore => _hasMore && !_isLoading;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Load next page
  Future<List<T>> loadNext<T>({
    required Future<PaginatedResult<T>> Function(String? cursor) fetch,
  }) async {
    if (!hasMore || _isLoading) {
      return [];
    }

    _isLoading = true;

    try {
      final result = await fetch(_nextCursor);
      _nextCursor = result.nextCursor;
      _hasMore = result.hasMore;
      return result.items;
    } finally {
      _isLoading = false;
    }
  }

  /// Reset pagination
  void reset() {
    _nextCursor = null;
    _hasMore = true;
    _isLoading = false;
  }

  /// Set pagination state
  void setState({
    String? nextCursor,
    bool? hasMore,
  }) {
    _nextCursor = nextCursor;
    _hasMore = hasMore ?? true;
  }
}

/// Paginated result from API
class PaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  PaginatedResult({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });
}

/// Offset-based pagination helper
class OffsetPaginationHelper {
  final int pageSize;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  OffsetPaginationHelper({this.pageSize = 20});

  /// Current page (0-indexed)
  int get currentPage => _currentPage;

  /// Current offset
  int get offset => _currentPage * pageSize;

  /// Check if there are more pages
  bool get hasMore => _hasMore && !_isLoading;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Load next page
  Future<List<T>> loadNext<T>({
    required Future<OffsetPaginatedResult<T>> Function(int offset, int limit) fetch,
  }) async {
    if (!hasMore || _isLoading) {
      return [];
    }

    _isLoading = true;

    try {
      final result = await fetch(offset, pageSize);
      _hasMore = result.hasMore;
      if (_hasMore) {
        _currentPage++;
      }
      return result.items;
    } finally {
      _isLoading = false;
    }
  }

  /// Reset pagination
  void reset() {
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
  }
}

/// Offset-based paginated result
class OffsetPaginatedResult<T> {
  final List<T> items;
  final bool hasMore;

  OffsetPaginatedResult({
    required this.items,
    required this.hasMore,
  });
}









