import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../domain/entities/exercise.dart';

/// Provider for exercise repository
final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) => ExerciseRepository(ref));

/// Provider for fetching all exercises
final exercisesProvider = FutureProvider.autoDispose<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).fetchExercises();
});

/// Provider for fetching exercises by category
final exercisesByCategoryProvider =
    FutureProvider.autoDispose.family<List<Exercise>, String>((ref, category) {
  return ref.watch(exerciseRepositoryProvider).fetchExercisesByCategory(category);
});

/// Provider for searching exercises
final searchExercisesProvider =
    FutureProvider.autoDispose.family<List<Exercise>, String>((ref, query) {
  return ref.watch(exerciseRepositoryProvider).searchExercises(query);
});

/// Provider for fetching single exercise
final exerciseProvider =
    FutureProvider.autoDispose.family<Exercise?, String>((ref, id) {
  return ref.watch(exerciseRepositoryProvider).fetchExercise(id);
});

class ExerciseRepository {
  ExerciseRepository(this._ref);

  final Ref _ref;

  GraphQLClient get _client => _ref.read(graphqlProvider);

  Future<List<Exercise>> fetchExercises({String? category}) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getExercises),
          variables: {
            if (category != null && category.isNotEmpty) 'category': category,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

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
        // Re-throw other errors for debugging
        throw result.exception!;
      }

      final exercises = result.data?['exercises'] as List<dynamic>? ?? [];
      return exercises
          .whereType<Map<String, dynamic>>()
          .map(Exercise.fromGraphql)
          .toList();
    } catch (e) {
      // Log error but return empty list to prevent UI crashes
      print('Error fetching exercises: $e');
      return [];
    }
  }

  Future<List<Exercise>> fetchExercisesByCategory(String category) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getExercises),
          variables: {
            'category': category.toUpperCase(),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
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

      final exercises = result.data?['exercises'] as List<dynamic>? ?? [];
      final allExercises = exercises
          .whereType<Map<String, dynamic>>()
          .map(Exercise.fromGraphql)
          .toList();

      // Client-side category filtering (backend should support this)
      return allExercises.where((ex) {
        return ex.category?.toLowerCase() == category.toLowerCase();
      }).toList();
    } catch (e) {
      print('Error fetching exercises by category: $e');
      return [];
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    if (query.isEmpty) {
      return fetchExercises();
    }

    try {
      // Backend doesn't support search query parameter yet, so we fetch all and filter client-side
      final allExercises = await fetchExercises();
      final queryLower = query.toLowerCase();
      
      return allExercises.where((ex) {
        return ex.name.toLowerCase().contains(queryLower) ||
            (ex.description?.toLowerCase().contains(queryLower) ?? false) ||
            (ex.primaryMuscleGroup?.toLowerCase().contains(queryLower) ?? false) ||
            (ex.equipmentRequired?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching exercises: $e');
      return [];
    }
  }

  Future<Exercise?> fetchExercise(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GraphQLQueries.getExercise),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final exerciseData = result.data?['exercise'] as Map<String, dynamic>?;
    if (exerciseData == null) {
      return null;
    }

    return Exercise.fromGraphql(exerciseData);
  }
}

