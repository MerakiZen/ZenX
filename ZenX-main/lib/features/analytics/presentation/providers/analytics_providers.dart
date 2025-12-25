import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';

/// Provides the aggregated progress snapshot for the signed-in athlete.
<<<<<<< Updated upstream
final progressSnapshotProvider =
    FutureProvider.autoDispose<ProgressSnapshotData>((ref) async {
  final client = ref.watch(graphqlProvider);
  final result = await client.query(
    QueryOptions(
      document: gql(GraphQLQueries.progressSnapshot),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) {
    throw result.exception!;
  }

  final payload = result.data?['progressSnapshot'] as Map<String, dynamic>?;
  if (payload == null) {
    return const ProgressSnapshotData.empty();
  }
  return ProgressSnapshotData.fromJson(payload);
});

/// Provides the detailed personal record list.
final personalRecordsProvider =
    FutureProvider.autoDispose<List<PersonalRecordData>>((ref) async {
  final client = ref.watch(graphqlProvider);
  final result = await client.query(
    QueryOptions(
      document: gql(GraphQLQueries.personalRecords),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) {
    throw result.exception!;
  }

  final records = result.data?['personalRecords'] as List<dynamic>? ?? const [];
  return records
      .whereType<Map<String, dynamic>>()
      .map(PersonalRecordData.fromJson)
      .toList();
});

class ProgressSnapshotData {
  final DateTime? capturedAt;
  final double totalVolumeKg;
  final double averageRpe;
  final int workoutCount;
  final List<PersonalRecordData> records;

  const ProgressSnapshotData({
    required this.capturedAt,
    required this.totalVolumeKg,
    required this.averageRpe,
    required this.workoutCount,
    required this.records,
  });

  const ProgressSnapshotData.empty()
      : capturedAt = null,
        totalVolumeKg = 0,
        averageRpe = 0,
        workoutCount = 0,
        records = const [];

  bool get hasData =>
      workoutCount > 0 || totalVolumeKg > 0 || records.isNotEmpty;

  factory ProgressSnapshotData.fromJson(Map<String, dynamic> json) {
    final records = (json['prs'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PersonalRecordData.fromJson)
        .toList();

    return ProgressSnapshotData(
      capturedAt: _parseDate(json['capturedAt'] as String?),
      totalVolumeKg: _parseDouble(json['totalVolumeKg']),
      averageRpe: _parseDouble(json['averageRpe']),
      workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
      records: records,
    );
  }
}

class PersonalRecordData {
  final String exerciseId;
  final String recordType;
  final double value;
  final DateTime? achievedAt;
  final ExerciseSummary? exercise;

  const PersonalRecordData({
    required this.exerciseId,
    required this.recordType,
    required this.value,
    required this.achievedAt,
    required this.exercise,
  });

  factory PersonalRecordData.fromJson(Map<String, dynamic> json) {
    return PersonalRecordData(
      exerciseId: json['exerciseId'] as String? ?? '',
      recordType: json['recordType'] as String? ?? 'max_weight',
      value: _parseDouble(json['value']),
      achievedAt: _parseDate(json['achievedAt'] as String?),
      exercise:
          ExerciseSummary.fromJson(json['exercise'] as Map<String, dynamic>?),
    );
  }
}

class ExerciseSummary {
  final String id;
  final String? name;
  final String? category;

  const ExerciseSummary({
    required this.id,
    this.name,
    this.category,
  });

  static ExerciseSummary? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return ExerciseSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      category: json['category'] as String?,
    );
  }
}

double _parseDouble(Object? value) {
  if (value == null) {
    return 0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _parseDate(String? input) {
  if (input == null || input.isEmpty) {
    return null;
  }
  return DateTime.tryParse(input)?.toLocal();
}

// Workout Calendar and Muscle Stats (client-side calculations)

/// Analytics data models
class WorkoutCalendarData {
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> workoutDays;
  final int totalWorkouts;

  const WorkoutCalendarData({
    required this.startDate,
    required this.endDate,
    required this.workoutDays,
    required this.totalWorkouts,
  });
}

class MuscleGroupStat {
  final String muscleGroup;
  final int setCount;
  final double volume;
  final double percentage;

  const MuscleGroupStat({
    required this.muscleGroup,
    required this.setCount,
    required this.volume,
    required this.percentage,
  });
}

/// Provider for workout calendar (last 7 days)
final workoutCalendarProvider = FutureProvider.family<WorkoutCalendarData, DateTime>((ref, startDate) async {
  final endDate = startDate.add(const Duration(days: 6));

  // Fetch all workouts  
  final workouts = await ref.watch(workoutsProvider.future);

  // Filter workouts within date range
  final filteredWorkouts = workouts.where((workout) {
    final workoutDate = workout.completedAt ?? workout.createdAt;
    return workoutDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
           workoutDate.isBefore(endDate.add(const Duration(days: 1)));
  }).toList();

  // Extract unique workout days
  final workoutDays = filteredWorkouts
      .map((w) => w.completedAt ?? w.createdAt)
      .map((date) => DateTime(date.year, date.month, date.day))
      .toSet()
      .toList()
    ..sort();

  return WorkoutCalendarData(
    startDate: startDate,
    endDate: endDate,
    workoutDays: workoutDays,
    totalWorkouts: filteredWorkouts.length,
  );
});

/// Provider for muscle group statistics (last 7 days)
final muscleGroupStatsProvider = FutureProvider.family<List<MuscleGroupStat>, DateTime>((ref, startDate) async {
  final endDate = startDate.add(const Duration(days: 6));

  // Fetch all workouts
  final workouts = await ref.watch(workoutsProvider.future);

  // Filter workouts within date range
  final filteredWorkouts = workouts.where((workout) {
    final workoutDate = workout.completedAt ?? workout.createdAt;
    return workoutDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
           workoutDate.isBefore(endDate.add(const Duration(days: 1)));
  }).toList();

  // Calculate stats per muscle group
  final Map<String, _MuscleGroupData> muscleData = {};

  for (final workout in filteredWorkouts) {
    for (final exercise in workout.exercises) {
      final muscleGroup = exercise.exercise?.primaryMuscleGroup ?? 'Unknown';
      
      if (!muscleData.containsKey(muscleGroup)) {
        muscleData[muscleGroup] = _MuscleGroupData();
      }

      final data = muscleData[muscleGroup]!;
      data.setCount += exercise.sets.length;

      for (final set in exercise.sets) {
        final weight = set.weightKg ?? 0;
        final reps = set.reps ?? 0;
        data.volume += weight * reps;
      }
    }
  }

  // Calculate total sets for percentages
  final totalSets = muscleData.values.fold<int>(
    0,
    (sum, data) => sum + data.setCount,
  );

  // Convert to list of stats
  final stats = muscleData.entries.map((entry) {
    final percentage = totalSets > 0 ? (entry.value.setCount / totalSets) * 100 : 0.0;
    return MuscleGroupStat(
      muscleGroup: entry.key,
      setCount: entry.value.setCount,
      volume: entry.value.volume,
      percentage: percentage,
    );
  }).toList()
    ..sort((a, b) => b.setCount.compareTo(a.setCount)); // Sort by set count descending

  return stats;
});

// Helper classes for accumulating data
class _MuscleGroupData {
  int setCount = 0;
  double volume = 0;
=======

part 'analytics_providers.g.dart';

@riverpod
Future<WorkoutCalendar> workoutCalendar(WorkoutCalendarRef ref, {required DateTime startDate, required DateTime endDate}) async {
  final client = ref.watch(graphqlClientProvider);
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getWorkoutCalendar),
    variables: {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    },
  ));
  
  if (result.hasException) {
    throw result.exception!;
  }
  
  return WorkoutCalendar.fromJson(result.data!['workoutCalendar']);
}

@riverpod
Future<List<MuscleGroupStat>> muscleGroupStats(MuscleGroupStatsRef ref, {DateTime? startDate, DateTime? endDate}) async {
  final client = ref.watch(graphqlClientProvider);
  final variables = <String, dynamic>{};
  if (startDate != null && endDate != null) {
    variables['dateRange'] = {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    };
  }
  
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getMuscleGroupStats),
    variables: variables,
  ));
  
  if (result.hasException) {
    throw result.exception!;
  }
  
  final List data = result.data!['muscleGroupStats'];
  return data.map((e) => MuscleGroupStat.fromJson(e)).toList();
}

@riverpod
Future<List<ExerciseRecord>> topExercises(TopExercisesRef ref, {int limit = 10, DateTime? startDate, DateTime? endDate}) async {
  final client = ref.watch(graphqlClientProvider);
  final variables = <String, dynamic>{'limit': limit};
  if (startDate != null && endDate != null) {
    variables['dateRange'] = {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
    };
  }
  
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getTopExercises),
    variables: variables,
  ));
  
  if (result.hasException) {
    throw result.exception!;
  }
  
  final List data = result.data!['topExercises'];
  return data.map((e) => ExerciseRecord.fromJson(e)).toList();
}

@riverpod
Future<ExercisePerformance> exercisePerformance(ExercisePerformanceRef ref, String exerciseId) async {
  final client = ref.watch(graphqlClientProvider);
  final result = await client.query(QueryOptions(
    document: gql(GraphQLQueries.getExercisePerformance),
    variables: {'exerciseId': exerciseId},
  ));
  
  if (result.hasException) {
    throw result.exception!;
  }
  
  return ExercisePerformance.fromJson(result.data!['exercisePerformance']);
>>>>>>> Stashed changes
}
