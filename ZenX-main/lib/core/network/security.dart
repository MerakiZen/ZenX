import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security utilities for handling authentication tokens
class SecurityManager {
  SecurityManager._();

  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiryKey = 'token_expiry';

  /// Save access token securely
  static Future<void> saveAccessToken(String token, DateTime expiry) async {
    await _storage.write(key: _accessTokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token securely
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  /// Check if token needs refresh (within 5 minutes of expiry)
  static Future<bool> needsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    final refreshTime = expiry.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenExpiryKey);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;
    return !await isTokenExpired();
  }
}









