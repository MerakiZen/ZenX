import '../../../../core/domain/entity.dart';

/// Exercise entity
class Exercise extends Entity {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? primaryMuscleGroup;
  final List<String> secondaryMuscleGroups;
  final String? equipmentRequired;
  final String? difficultyLevel;
  final bool isCustom;
  final String? createdBy;
  final DateTime createdAt;

  const Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const [],
    this.equipmentRequired,
    this.difficultyLevel,
    this.isCustom = false,
    this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        primaryMuscleGroup,
        secondaryMuscleGroups,
        equipmentRequired,
        difficultyLevel,
        isCustom,
        createdBy,
        createdAt,
      ];

  factory Exercise.fromGraphql(Map<String, dynamic> json) {
    final secondaryGroups = (json['secondaryMuscleGroups'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      primaryMuscleGroup: json['primaryMuscleGroup'] as String?,
      secondaryMuscleGroups: secondaryGroups,
      equipmentRequired: json['equipmentRequired'] as String?,
      difficultyLevel: json['difficultyLevel'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}









