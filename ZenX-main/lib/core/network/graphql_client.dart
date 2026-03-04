import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'rate_limiter.dart';
import 'security.dart';
import 'token_refresh_interceptor.dart';

/// GraphQL client provider with authentication
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  // Use a custom client with explicit timeouts to prevent hangs on physical devices
  final httpClient = http.Client();
  
  final httpLink = HttpLink(
    AppConfig.apiBaseUrl,
    httpClient: httpClient,
    defaultHeaders: {
      'X-Client-Timeout': AppConfig.connectionTimeout.inSeconds.toString(),
    },
  );

  final refreshClient = GraphQLClient(
    link: HttpLink(
      AppConfig.apiBaseUrl,
      httpClient: httpClient,
    ),
    cache: GraphQLCache(),
  );

  final authLink = AuthLink(
    getToken: () async {
      final tokenResult =
          await TokenRefreshInterceptor.ensureValidToken(refreshClient);
      return tokenResult.when(
        success: (token) => token != null ? 'Bearer $token' : null,
        failure: (_) => null,
      );
    },
  );

  // Error link for handling authentication errors and rate limiting
  final errorLink = Link.function(
    (request, [forward]) {
      // Check rate limit before making request
      final rateLimiter = GraphQLRateLimiter();
      
      return Stream.fromFuture(Future(() async {
        if (!rateLimiter.canMakeRequest()) {
          await rateLimiter.waitIfNeeded();
        }
        rateLimiter.recordRequest();
      })).asyncExpand((_) => forward!(request)).timeout(
        AppConfig.connectionTimeout,
        onTimeout: (sink) {
          sink.addError(TimeoutException(
            'Request timed out after ${AppConfig.connectionTimeout.inSeconds} seconds. Check if the server is reachable.',
            AppConfig.connectionTimeout,
          ));
        },
      ).map((response) {
        if (response.errors != null) {
          for (final error in response.errors!) {
            if (error.extensions?['code'] == 'UNAUTHENTICATED') {
              SecurityManager.clearAuthData();
            }
            // Handle rate limiting errors
            if (error.extensions?['code'] == 'RATE_LIMIT_EXCEEDED') {
              // Wait and retry
              // This would be handled by retry logic
            }
          }
        }
        return response;
      });
    },
  );

  final link = Link.from([
    errorLink,
    authLink,
    httpLink,
  ]);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  );
});

/// GraphQL client provider for queries and mutations
final graphqlProvider = Provider<GraphQLClient>((ref) {
  return ref.watch(graphqlClientProvider);
});
