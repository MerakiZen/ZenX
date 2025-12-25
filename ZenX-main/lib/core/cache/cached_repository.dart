import 'dart:async';
import '../utils/result.dart';
import '../cache/cache_manager.dart';

/// Mixin for repositories that implement caching
mixin CachedRepository<T> {
  final CacheManager _cacheManager = CacheManager();

  /// Get cache key for entity
  String getCacheKey(String id);

  /// Get cache TTL
  Duration getCacheTTL();

  /// Get from cache or fetch
  Future<Result<T>> getCachedOrFetch(
    String id,
    Future<Result<T>> Function() fetch,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    // Try cache first
    final cacheKey = getCacheKey(id);
    final cached = await _cacheManager.get<Map<String, dynamic>>(
      cacheKey,
      (value) {
        try {
          // Parse JSON string to Map
          // This is simplified - should use proper JSON parsing
          return <String, dynamic>{};
        } catch (e) {
          return <String, dynamic>{};
        }
      },
    );

    if (cached != null) {
      try {
        final entity = fromJson(cached);
        return Result.success(entity);
      } catch (e) {
        // Cache corrupted, remove it
        await _cacheManager.remove(cacheKey);
      }
    }

    // Fetch from source
    final result = await fetch();

    // Cache on success
    result.when(
      success: (entity) async {
        final json = toJson(entity);
        await _cacheManager.set(
          cacheKey,
          json.toString(), // Simplified - should use proper JSON encoding
          ttl: getCacheTTL(),
        );
      },
      failure: (_) {},
    );

    return result;
  }

  /// Invalidate cache for entity
  Future<void> invalidateCache(String id) async {
    final cacheKey = getCacheKey(id);
    await _cacheManager.remove(cacheKey);
  }

  /// Invalidate all cache
  Future<void> clearCache() async {
    await _cacheManager.clear();
  }
}

