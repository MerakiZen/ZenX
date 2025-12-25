class ExercisePerformance {
  final String exerciseId;
  final String exerciseName;
  final double? heaviestWeight;
  final double? projectedOneRM;
  final double? bestSetVolume;
  final double? bestSessionVolume;
  final int? mostReps;
  final List<PersonalRecord> personalRecords;
  final List<WorkoutExerciseEntry> history;

  ExercisePerformance({
    required this.exerciseId,
    required this.exerciseName,
    this.heaviestWeight,
    this.projectedOneRM,
    this.bestSetVolume,
    this.bestSessionVolume,
    this.mostReps,
    required this.personalRecords,
    required this.history,
  });

  factory ExercisePerformance.fromJson(Map<String, dynamic> json) {
    return ExercisePerformance(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      heaviestWeight: (json['heaviestWeight'] as num?)?.toDouble(),
      projectedOneRM: (json['projectedOneRM'] as num?)?.toDouble(),
      bestSetVolume: (json['bestSetVolume'] as num?)?.toDouble(),
      bestSessionVolume: (json['bestSessionVolume'] as num?)?.toDouble(),
      mostReps: json['mostReps'],
      personalRecords: (json['personalRecords'] as List?)
              ?.map((e) => PersonalRecord.fromJson(e))
              .toList() ??
          [],
      history: (json['history'] as List?)
              ?.map((e) => WorkoutExerciseEntry.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PersonalRecord {
  final String recordType;
  final double value;
  final String achievedAt;

  PersonalRecord({
    required this.recordType,
    required this.value,
    required this.achievedAt,
  });

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      recordType: json['recordType'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      achievedAt: json['achievedAt'] ?? '',
    );
  }
}

class WorkoutExerciseEntry {
  final String workoutId;
  final String date;
  final double weight;
  final int reps;
  final double? oneRM;
  final double? volume;

  WorkoutExerciseEntry({
    required this.workoutId,
    required this.date,
    required this.weight,
    required this.reps,
    this.oneRM,
    this.volume,
  });

  factory WorkoutExerciseEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseEntry(
      workoutId: json['workoutId'] ?? '',
      date: json['date'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] ?? 0,
      oneRM: (json['oneRM'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
    );
  }
}
