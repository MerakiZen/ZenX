import '../entities/exercise.dart' as entity;

/// Exercise model for JSON serialization
class Exercise {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String? primaryMuscleGroup;
  final List<String> secondaryMuscleGroups;
  final String? equipmentRequired;
  final String? difficultyLevel;
  final bool isCustom;
  final DateTime? createdAt;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const [],
    this.equipmentRequired,
    this.difficultyLevel,
    this.isCustom = false,
    this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      primaryMuscleGroup: json['primaryMuscleGroup'] as String?,
      secondaryMuscleGroups: json['secondaryMuscleGroups'] != null
          ? List<String>.from(json['secondaryMuscleGroups'] as List)
          : [],
      equipmentRequired: json['equipmentRequired'] as String?,
      difficultyLevel: json['difficultyLevel'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'primaryMuscleGroup': primaryMuscleGroup,
      'secondaryMuscleGroups': secondaryMuscleGroups,
      'equipmentRequired': equipmentRequired,
      'difficultyLevel': difficultyLevel,
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  entity.Exercise toEntity() {
    return entity.Exercise(
      id: id,
      name: name,
      description: description,
      category: category,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      equipmentRequired: equipmentRequired,
      difficultyLevel: difficultyLevel,
      isCustom: isCustom,
      createdBy: null,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
