import '../../../../core/domain/entity.dart';
import 'workout_exercise.dart';

/// Workout entity
class Workout extends Entity {
  final String id;
  final String userId;
  final String? name;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final double? totalVolumeKg;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<WorkoutExercise> exercises;

  const Workout({
    required this.id,
    required this.userId,
    this.name,
    this.notes,
    this.exercises = const [],
    this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.totalVolumeKg,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if workout is active
  bool get isActive => startedAt != null && completedAt == null;

  /// Check if workout is completed
  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        notes,
        startedAt,
        completedAt,
        durationSeconds,
        totalVolumeKg,
        createdAt,
        updatedAt,
      ];

  factory Workout.fromGraphql(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String?,
      notes: json['notes'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromGraphql(e as Map<String, dynamic>))
          .toList(),
      durationSeconds: json['durationSeconds'] as int?,
      totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}









