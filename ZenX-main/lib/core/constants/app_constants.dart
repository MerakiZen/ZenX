/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'ZenX';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String graphqlEndpoint = 'https://api.zenx.app/graphql';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Database Configuration
  static const String databaseName = 'ZenX_DB.sqlite';
  static const int databaseVersion = 1;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}









