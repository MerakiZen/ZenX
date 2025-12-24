import '../../../../core/domain/entity.dart';

/// Body measurement entity
class BodyMeasurement extends Entity {
  final String id;
  final String userId;
  final DateTime measurementDate;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? muscleMassKg;
  final Map<String, dynamic>? measurements; // Flexible JSONB data
  final DateTime createdAt;

  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.measurementDate,
    this.weightKg,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.measurements,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        measurementDate,
        weightKg,
        bodyFatPercentage,
        muscleMassKg,
        measurements,
        createdAt,
      ];
}









