import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity service provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Service for checking network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity results
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged.map((result) => [result]);

  /// Check current connectivity status
  Future<List<ConnectivityResult>> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return [result];
  }

  /// Check if device is currently online
  Future<bool> isOnline() async {
    final results = await checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}

