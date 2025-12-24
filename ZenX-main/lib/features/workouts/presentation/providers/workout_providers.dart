import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/set.dart';

/// Provider for workout repository
final workoutRepositoryProvider =
    Provider<WorkoutRepository>((ref) => WorkoutRepository(ref));

/// Provider for fetching all workouts
final workoutsProvider = FutureProvider.autoDispose<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).fetchWorkouts(limit: 20);
});

/// Legacy provider for workout list (for compatibility)
final workoutListProvider = workoutsProvider;

/// Lightweight view model used by the workout list screen.
class WorkoutListItem {
  final String id;
  final String title;
  final String? notes;
  final int exerciseCount;
  final int totalSets;

  const WorkoutListItem({
    required this.id,
    required this.title,
    required this.exerciseCount,
    required this.totalSets,
    this.notes,
  });
}

/// Provider for fetching single workout
final workoutProvider =
    FutureProvider.autoDispose.family<Workout?, String>((ref, id) {
  return ref.watch(workoutRepositoryProvider).fetchWorkout(id);
});

class WorkoutRepository {
  WorkoutRepository(this._ref);

  final Ref _ref;

  GraphQLClient get _client => _ref.read(graphqlProvider);

  Future<List<Workout>> fetchWorkouts({int? limit}) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getWorkouts),
          variables: {
            if (limit != null) 'limit': limit,
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

      final workouts = result.data?['workouts'] as List<dynamic>? ?? [];
      return workouts
          .whereType<Map<String, dynamic>>()
          .map(Workout.fromGraphql)
          .toList();
    } catch (e) {
      // Log error but return empty list to prevent UI crashes
      print('Error fetching workouts: $e');
      return [];
    }
  }

  Future<Workout?> fetchWorkout(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(GraphQLQueries.getWorkout),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final workoutData = result.data?['workout'] as Map<String, dynamic>?;
    if (workoutData == null) {
      return null;
    }

    return Workout.fromGraphql(workoutData);
  }

  Future<Workout> createWorkout({
    required String name,
    String? notes,
    List<WorkoutExerciseInput>? exercises,
  }) async {
    final exercisesInput = exercises?.map((ex) => {
          'exerciseId': ex.exerciseId,
          'order': ex.order,
          'sets': ex.sets.map((set) => {
                'setNumber': set.setNumber,
                if (set.reps != null) 'reps': set.reps,
                if (set.weightKg != null) 'weightKg': set.weightKg,
                if (set.rpe != null) 'rpe': set.rpe,
                if (set.notes != null) 'notes': set.notes,
                if (set.completed != null) 'completed': set.completed,
              }).toList(),
        }).toList();

    final result = await _client.mutate(
      MutationOptions(
        document: gql(GraphQLQueries.createWorkout),
        variables: {
          'input': {
            'name': name,
            if (notes != null) 'notes': notes,
            if (exercisesInput != null) 'exercises': exercisesInput,
          },
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final workoutData = result.data?['createWorkout'] as Map<String, dynamic>?;
    if (workoutData == null) {
      throw Exception('Failed to create workout');
    }

    return Workout.fromGraphql(workoutData);
  }
}

/// Input model for creating workout exercises
class WorkoutExerciseInput {
  final String exerciseId;
  final int order;
  final List<WorkoutSetInput> sets;

  WorkoutExerciseInput({
    required this.exerciseId,
    required this.order,
    required this.sets,
  });
}

/// Input model for creating workout sets
class WorkoutSetInput {
  final int setNumber;
  final int? reps;
  final double? weightKg;
  final double? rpe;
  final String? notes;
  final bool? completed;

  WorkoutSetInput({
    required this.setNumber,
    this.reps,
    this.weightKg,
    this.rpe,
    this.notes,
    this.completed,
  });
}
