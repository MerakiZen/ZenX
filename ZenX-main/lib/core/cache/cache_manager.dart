import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache manager for client-side caching
/// Implements multi-layer caching strategy
class CacheManager {
  CacheManager._();

  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final Map<String, _CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;

  /// Initialize cache manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _startCleanupTimer();
  }

  /// Get value from cache (memory first, then disk)
  Future<T?> get<T>(String key, T Function(String) parser) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return parser(memoryEntry.value);
    }

    // Check disk cache
    if (_prefs != null) {
      final diskValue = _prefs!.getString(key);
      if (diskValue != null) {
        // Restore to memory cache
        _memoryCache[key] = _CacheEntry(
          value: diskValue,
          expiry: DateTime.now().add(const Duration(minutes: 5)),
        );
        return parser(diskValue);
      }
    }

    return null;
  }

  /// Set value in cache (memory and disk)
  Future<void> set(String key, String value, {Duration? ttl}) async {
    final expiry = DateTime.now().add(ttl ?? const Duration(minutes: 5));

    // Set in memory cache
    _memoryCache[key] = _CacheEntry(value: value, expiry: expiry);

    // Set in disk cache
    if (_prefs != null) {
      await _prefs!.setString(key, value);
      await _prefs!.setString('${key}_expiry', expiry.toIso8601String());
    }
  }

  /// Remove value from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    if (_prefs != null) {
      await _prefs!.remove(key);
      await _prefs!.remove('${key}_expiry');
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((k) => k.endsWith('_expiry'));
      for (final key in keys) {
        await _prefs!.remove(key.replaceAll('_expiry', ''));
        await _prefs!.remove(key);
      }
    }
  }

  /// Clear expired entries
  void _clearExpired() {
    _memoryCache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      _clearExpired();
    });
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryEntries': _memoryCache.length,
      'memorySize': _memoryCache.values
          .fold(0, (sum, entry) => sum + entry.value.length),
    };
  }
}

class _CacheEntry {
  final String value;
  final DateTime expiry;

  _CacheEntry({required this.value, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Cache keys for different data types
class CacheKeys {
  CacheKeys._();

  // User cache
  static String userSession(String userId) => 'user:session:$userId';
  static String userProfile(String userId) => 'user:profile:$userId';

  // Exercise cache
  static String exerciseLibrary(String category) =>
      'exercise:library:$category';
  static String exercise(String exerciseId) => 'exercise:$exerciseId';

  // Workout cache
  static String recentWorkouts(String userId) => 'workout:recent:$userId';
  static String workout(String workoutId) => 'workout:$workoutId';

  // Analytics cache
  static String personalRecord(String userId, String exerciseId) =>
      'pr:$userId:$exerciseId';
  static String analytics(String userId) => 'analytics:$userId';

  // Cache TTL constants
  static const Duration userSessionTTL = Duration(minutes: 15);
  static const Duration exerciseLibraryTTL = Duration(hours: 1);
  static const Duration recentWorkoutsTTL = Duration(minutes: 5);
  static const Duration userProfileTTL = Duration(minutes: 30);
  static const Duration personalRecordTTL = Duration(hours: 1);
}









