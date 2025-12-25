class ExerciseRecord {
  final String exerciseId;
  final String exerciseName;
  final int workoutCount;
  final String? lastPerformed;
  final double? averageWeight;

  ExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.workoutCount,
    this.lastPerformed,
    this.averageWeight,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      workoutCount: json['workoutCount'] ?? 0,
      lastPerformed: json['lastPerformed'],
      averageWeight: (json['averageWeight'] as num?)?.toDouble(),
    );
  }
}
