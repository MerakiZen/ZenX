import 'dart:async';

/// Rate limiter for API requests
/// Implements token bucket algorithm to prevent exceeding rate limits
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final List<DateTime> _requests = [];

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  /// Check if request is allowed
  bool canMakeRequest() {
    _cleanOldRequests();
    return _requests.length < maxRequests;
  }

  /// Record a request
  void recordRequest() {
    _cleanOldRequests();
    _requests.add(DateTime.now());
  }

  /// Get time until next request is allowed
  Duration? getTimeUntilNextRequest() {
    _cleanOldRequests();
    if (_requests.length < maxRequests) {
      return null;
    }

    final oldestRequest = _requests.first;
    final nextAllowedTime = oldestRequest.add(window);
    final now = DateTime.now();

    if (nextAllowedTime.isAfter(now)) {
      return nextAllowedTime.difference(now);
    }

    return null;
  }

  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(window);
    _requests.removeWhere((request) => request.isBefore(cutoff));
  }

  /// Reset rate limiter
  void reset() {
    _requests.clear();
  }
}

/// Global rate limiter for GraphQL requests
class GraphQLRateLimiter {
  static final GraphQLRateLimiter _instance = GraphQLRateLimiter._internal();
  factory GraphQLRateLimiter() => _instance;
  GraphQLRateLimiter._internal();

  // Default: 100 requests per minute
  final RateLimiter _limiter = RateLimiter(
    maxRequests: 100,
    window: const Duration(minutes: 1),
  );

  /// Check if request can be made
  bool canMakeRequest() {
    return _limiter.canMakeRequest();
  }

  /// Record a request
  void recordRequest() {
    _limiter.recordRequest();
  }

  /// Get time until next request
  Duration? getTimeUntilNextRequest() {
    return _limiter.getTimeUntilNextRequest();
  }

  /// Wait until request can be made
  Future<void> waitIfNeeded() async {
    final waitTime = getTimeUntilNextRequest();
    if (waitTime != null) {
      await Future.delayed(waitTime);
    }
  }
}









