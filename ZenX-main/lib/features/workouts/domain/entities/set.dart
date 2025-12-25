import '../../../../core/domain/entity.dart';

/// Workout set entity (rep set within a workout exercise)
class WorkoutSet extends Entity {
  final String id;
  final String workoutExerciseId;
  final int setNumber;
  final int? reps;
  final double? weightKg;
  final double? rpe; // Rate of Perceived Exertion (1-10)
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  const WorkoutSet({
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    this.reps,
    this.weightKg,
    this.rpe,
    this.notes,
    this.completed = false,
    required this.createdAt,
  });

  /// Calculate volume (reps * weight)
  double? get volume {
    if (reps == null || weightKg == null) return null;
    return reps! * weightKg!;
  }

  @override
  List<Object?> get props => [
        id,
        workoutExerciseId,
        setNumber,
        reps,
        weightKg,
        rpe,
        notes,
        completed,
        createdAt,
      ];

  factory WorkoutSet.fromGraphql(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String? ?? '',
      workoutExerciseId: json['workoutExerciseId'] as String? ?? '',
      setNumber: json['setNumber'] as int? ?? 0,
      reps: json['reps'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      rpe: (json['rpe'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      completed: json['completed'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}









