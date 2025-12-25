import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application configuration based on build variant
class AppConfig {
  AppConfig._();

  /// Current environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  /// Check if running in staging
  static bool get isStaging => environment == 'staging';

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  // Custom URL override for generalized APK support
  static String? _customApiUrl;
  static const String _prefCustomUrlKey = 'custom_zenx_api_url';

  /// Initialize configuration (load saved URL)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customApiUrl = prefs.getString(_prefCustomUrlKey);
    } catch (e) {
      debugPrint('Failed to load custom URL config: $e');
    }
  }

  /// Set and save a custom API base URL (e.g. http://192.168.1.50:4000/graphql)
  static Future<void> setCustomUrl(String? url) async {
    _customApiUrl = url;
    final prefs = await SharedPreferences.getInstance();
    if (url != null && url.isNotEmpty) {
      await prefs.setString(_prefCustomUrlKey, url);
    } else {
      await prefs.remove(_prefCustomUrlKey);
    }
  }

  /// API base URL based on environment
  static String get apiBaseUrl {
    // If a custom URL is set (e.g. for testing on physical devices), use it
    if (_customApiUrl != null && _customApiUrl!.isNotEmpty) {
      return _customApiUrl!;
    }

    switch (environment) {
      case 'production':
        return 'https://api.zenx.app/graphql';
      case 'staging':
        return 'https://api-staging.zenx.app/graphql';
      case 'development':
      default:
<<<<<<< Updated upstream
        // Default to LAN IP, but can be overridden
        return 'http://192.168.1.10:4000/graphql';
=======
        // Use 10.0.2.2 to connect to host's localhost from Android emulator
        // Use localhost for iOS simulator
        return kIsWeb ? 'http://localhost:4000/graphql' : 
               (defaultTargetPlatform == TargetPlatform.android 
                 ? 'http://10.0.2.2:4000/graphql' 
                 : 'http://localhost:4000/graphql');
>>>>>>> Stashed changes
    }
  }

  /// WebSocket URL for subscriptions
  static String get websocketUrl {
    // Derive WS URL from custom HTTP URL if present
    if (_customApiUrl != null && _customApiUrl!.isNotEmpty) {
      final uri = Uri.parse(_customApiUrl!);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      return uri.replace(scheme: scheme).toString();
    }

    switch (environment) {
      case 'production':
        return 'wss://api.zenx.app/graphql';
      case 'staging':
        return 'wss://api-staging.zenx.app/graphql';
      case 'development':
      default:
        return 'ws://192.168.1.10:4000/graphql';
    }
  }

  /// JWT token expiry duration (15 minutes)
  static const Duration tokenExpiry = Duration(minutes: 15);

  /// Refresh token expiry duration (7 days)
  static const Duration refreshTokenExpiry = Duration(days: 7);

  /// Token refresh threshold (5 minutes before expiry)
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  /// Cache TTL configurations
  static const Duration cacheUserSessionTTL = Duration(minutes: 15);
  static const Duration cacheExerciseLibraryTTL = Duration(hours: 1);
  static const Duration cacheRecentWorkoutsTTL = Duration(minutes: 5);
  static const Duration cacheUserProfileTTL = Duration(minutes: 30);
  static const Duration cachePersonalRecordTTL = Duration(hours: 1);

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Request batching
  static const Duration batchDelay = Duration(milliseconds: 50);
  static const int maxBatchSize = 10;

  /// Enable verbose logging
  static bool get enableVerboseLogging => !isProduction;

  /// Enable debug overlays
  static bool get enableDebugOverlays => kDebugMode && isDevelopment;

  /// App version
  static const String appVersion = '1.0.0';

  /// Build number
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  /// Full version string
  static String get fullVersion => '$appVersion+$buildNumber';
}

