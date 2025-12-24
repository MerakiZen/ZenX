import 'package:graphql_flutter/graphql_flutter.dart';

import '../errors/failures.dart';
import '../utils/result.dart';
import 'graphql_queries.dart';
import 'security.dart';

/// Token refresh interceptor for handling JWT token expiration
class TokenRefreshInterceptor {
  TokenRefreshInterceptor._();

  /// Refresh access token using refresh token
  static Future<Result<String>> refreshToken(GraphQLClient client) async {
    try {
      final refreshToken = await SecurityManager.getRefreshToken();
      if (refreshToken == null) {
        return const Result.failure(
          Failure.network(message: 'No refresh token available'),
        );
      }

      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.refreshToken),
          variables: {'refreshToken': refreshToken},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        return Result.failure(
          Failure.network(message: result.exception.toString()),
        );
      }

      final payload = result.data?['refreshToken'] as Map<String, dynamic>?;
      if (payload == null) {
        return const Result.failure(
          Failure.network(message: 'Empty refresh response'),
        );
      }

      final newAccessToken = payload['accessToken'] as String?;
      final newRefreshToken = payload['refreshToken'] as String?;
      final expiresAtRaw = payload['expiresAt'] as String?;
      if (newAccessToken == null || expiresAtRaw == null) {
        return const Result.failure(
          Failure.network(message: 'Invalid refresh payload'),
        );
      }

      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (expiresAt == null) {
        return const Result.failure(
          Failure.network(message: 'Invalid expiry timestamp'),
        );
      }

      await SecurityManager.saveAccessToken(newAccessToken, expiresAt);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await SecurityManager.saveRefreshToken(newRefreshToken);
      }

      return Result.success(newAccessToken);
    } catch (e) {
      return Result.failure(
        Failure.network(message: e.toString()),
      );
    }
  }

  /// Check and refresh token if needed
  static Future<Result<String?>> ensureValidToken(GraphQLClient client) async {
    final token = await SecurityManager.getAccessToken();
    if (token == null) {
      return const Result.success(null);
    }

    final isExpired = await SecurityManager.isTokenExpired();
    if (!isExpired) {
      return Result.success(token);
    }

    final refreshResult = await refreshToken(client);
    return refreshResult.when(
      success: (newToken) => Result.success(newToken),
      failure: (failure) {
        SecurityManager.clearAuthData();
        return Result.failure(failure);
      },
    );
  }
}
