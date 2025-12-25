import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'graphql_client.dart';

/// WebSocket client provider for GraphQL subscriptions
final websocketClientProvider = Provider<WebSocketLink>((ref) {
  final uri = Uri.parse(AppConfig.websocketUrl);

  return WebSocketLink(
    uri.toString(),
    config: const SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );
});

/// GraphQL client with WebSocket support for subscriptions
final graphqlClientWithWebSocketProvider = Provider<GraphQLClient>((ref) {
  final httpLink = ref.watch(graphqlClientProvider).link;
  final websocketLink = ref.watch(websocketClientProvider);

  // Split link: HTTP for queries/mutations, WebSocket for subscriptions
  final link = Link.split(
    (request) => request.isSubscription,
    websocketLink,
    httpLink,
  );

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  );
});

