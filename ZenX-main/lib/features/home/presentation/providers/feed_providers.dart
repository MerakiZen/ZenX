import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../../home/domain/entities/notification.dart';
import '../../../home/domain/entities/post_comment.dart';
import '../../../home/domain/entities/workout_post.dart';

final feedRepositoryProvider =
    Provider<FeedRepository>((ref) => FeedRepository(ref));

final homeFeedProvider = FutureProvider.autoDispose<List<WorkoutPost>>(
  (ref) => ref.watch(feedRepositoryProvider).fetchFeed(),
);

final discoverFeedProvider = FutureProvider.autoDispose<List<WorkoutPost>>(
  (ref) => ref.watch(feedRepositoryProvider).fetchFeed(discover: true),
);

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(feedRepositoryProvider).fetchNotifications(limit: 50),
);

class FeedRepository {
  FeedRepository(this._ref);

  final Ref _ref;

  GraphQLClient get _client => _ref.read(graphqlProvider);

  Future<List<WorkoutPost>> fetchFeed({
    bool discover = false,
    int limit = 20,
  }) async {
    try {
      final document =
          gql(discover ? GraphQLQueries.discoverFeed : GraphQLQueries.feed);
      final result = await _client.query(
        QueryOptions(
          document: document,
          variables: {
            'limit': limit,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        // If unauthorized, return empty list instead of throwing
        final errors = result.exception?.graphqlErrors ?? [];
        if (errors.any((e) => e.message.toLowerCase().contains('unauthorized'))) {
          return [];
        }
        throw result.exception!;
      }

      final rootKey = discover ? 'discoverFeed' : 'feed';
      final feed = result.data?[rootKey] as Map<String, dynamic>? ?? {};
      final edges = feed['edges'] as List<dynamic>? ?? [];
      return edges
          .whereType<Map<String, dynamic>>()
          .map(WorkoutPost.fromGraphql)
          .toList();
    } catch (e) {
      // Return empty list on any error to prevent UI crashes
      return [];
    }
  }

  Future<({int likesCount, bool isLiked})> toggleLike(String postId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(GraphQLQueries.toggleFeedLike),
        variables: {'postId': postId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payload =
        result.data?['toggleFeedLike'] as Map<String, dynamic>? ?? {};
    final likesCount = payload['likesCount'] as int? ?? 0;
    final isLiked = payload['isLiked'] as bool? ?? false;
    return (likesCount: likesCount, isLiked: isLiked);
  }

  Future<List<PostComment>> fetchComments(String postId,
      {int limit = 50}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GraphQLQueries.feedComments),
        variables: {'postId': postId, 'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payload = result.data?['feedComments'] as Map<String, dynamic>? ?? {};
    final comments = payload['comments'] as List<dynamic>? ?? [];
    return comments
        .whereType<Map<String, dynamic>>()
        .map(PostComment.fromGraphql)
        .toList();
  }

  Future<PostComment> addComment({
    required String postId,
    required String body,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(GraphQLQueries.addFeedComment),
        variables: {'postId': postId, 'body': body},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payload =
        result.data?['addFeedComment'] as Map<String, dynamic>? ?? {};
    return PostComment.fromGraphql(payload);
  }

  Future<List<AppNotification>> fetchNotifications({int limit = 50}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GraphQLQueries.notifications),
        variables: {'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payload =
        result.data?['notifications'] as Map<String, dynamic>? ?? {};
    final nodes = payload['nodes'] as List<dynamic>? ?? [];
    return nodes
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromGraphql)
        .toList();
  }

  Future<void> markNotificationRead(String notificationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(GraphQLQueries.markNotificationRead),
        variables: {'notificationId': notificationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }
  }
}
