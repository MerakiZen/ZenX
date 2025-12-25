import '../../../../core/domain/entity.dart';

/// Personal record entity
class PersonalRecord extends Entity {
  final String id;
  final String userId;
  final String exerciseId;
  final PersonalRecordType recordType;
  final double value;
  final DateTime achievedAt;
  final String? workoutId;
  final DateTime createdAt;

  const PersonalRecord({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.recordType,
    required this.value,
    required this.achievedAt,
    this.workoutId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        exerciseId,
        recordType,
        value,
        achievedAt,
        workoutId,
        createdAt,
      ];
}

/// Personal record types
enum PersonalRecordType {
  oneRepMax('1RM'),
  maxReps('max_reps'),
  maxVolume('max_volume'),
  maxWeight('max_weight');

  final String value;
  const PersonalRecordType(this.value);
}









