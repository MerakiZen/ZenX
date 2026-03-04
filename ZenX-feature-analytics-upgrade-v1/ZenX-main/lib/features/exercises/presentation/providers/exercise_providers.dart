import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../domain/models/exercise.dart';

part 'exercise_providers.g.dart';

/// Provider to fetch all exercises with optional filters
@riverpod
Future<List<Exercise>> exercises(ExercisesRef ref, {String? query, String? category}) async {
  final client = ref.watch(graphqlProvider);
  
  final variables = <String, dynamic>{};
  if (query != null && query.isNotEmpty) {
    variables['query'] = query;
  }
  if (category != null && category.isNotEmpty) {
    variables['category'] = category;
  }
  
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getExercises),
    variables: variables,
    fetchPolicy: FetchPolicy.networkOnly,
  ));
  
  if (result.hasException) {
    // If unauthorized or network error, return empty list instead of throwing
    final errors = result.exception?.graphqlErrors ?? [];
    final exceptionMessage = result.exception?.toString().toLowerCase() ?? '';
    if (errors.any((e) => e.message.toLowerCase().contains('unauthorized')) ||
        exceptionMessage.contains('unauthorized') ||
        exceptionMessage.contains('linkexception') ||
        exceptionMessage.contains('network')) {
      return [];
    }
    throw result.exception!;
  }
  
  final exercisesJson = result.data?['exercises'] as List<dynamic>?;
  if (exercisesJson == null) {
    return [];
  }
  
  return exercisesJson
      .whereType<Map<String, dynamic>>()
      .map(Exercise.fromJson)
      .toList();
}

/// Provider to search exercises by name
@riverpod
Future<List<Exercise>> searchExercises(SearchExercisesRef ref, String searchQuery) async {
  if (searchQuery.isEmpty) {
    return ref.watch(exercisesProvider(query: null, category: null).future);
  }
  return ref.watch(exercisesProvider(query: searchQuery, category: null).future);
}

/// Provider to filter exercises by category
@riverpod
Future<List<Exercise>> exercisesByCategory(ExercisesByCategoryRef ref, String category) async {
  return ref.watch(exercisesProvider(query: null, category: category).future);
}

/// Provider for single exercise
@riverpod
Future<Exercise?> exercise(ExerciseRef ref, String id) async {
  final client = ref.watch(graphqlProvider);
  
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getExercise),
    variables: {'id': id},
    fetchPolicy: FetchPolicy.networkOnly,
  ));

  if (result.hasException) {
    throw result.exception!;
  }

  final exerciseData = result.data?['exercise'] as Map<String, dynamic>?;
  if (exerciseData == null) {
    return null;
  }

  return Exercise.fromJson(exerciseData);
}
