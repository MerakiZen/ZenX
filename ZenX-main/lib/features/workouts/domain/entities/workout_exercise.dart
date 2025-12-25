import '../../../../core/domain/entity.dart';
import '../../../exercises/domain/entities/exercise.dart';
import 'set.dart';

/// Workout exercise entity (exercise within a workout)
class WorkoutExercise extends Entity {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int orderIndex;
  final Exercise? exercise;
  final List<WorkoutSet> sets;
  final DateTime createdAt;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    this.exercise,
    this.sets = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, workoutId, exerciseId, orderIndex, exercise, sets, createdAt];

  factory WorkoutExercise.fromGraphql(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String? ?? json['exerciseId'] as String? ?? '',
      workoutId: json['workoutId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      orderIndex: json['orderIndex'] as int? ?? json['order'] as int? ?? 0,
      exercise: json['exercise'] != null
          ? Exercise.fromGraphql(json['exercise'] as Map<String, dynamic>)
          : null,
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((e) => WorkoutSet.fromGraphql(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
