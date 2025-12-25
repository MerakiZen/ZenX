/// Local data source for authentication
/// Handles local storage of auth tokens and user session
abstract class AuthLocalDataSource {
  /// Save authentication token
  Future<void> saveToken(String token);

  /// Get authentication token
  Future<String?> getToken();

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken);

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Clear all auth data
  Future<void> clearAuthData();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}









