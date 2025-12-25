class MuscleGroupStat {
  final String muscleGroup;
  final int setCount;
  final double volume;
  final double percentage;

  MuscleGroupStat({
    required this.muscleGroup,
    required this.setCount,
    required this.volume,
    required this.percentage,
  });

  factory MuscleGroupStat.fromJson(Map<String, dynamic> json) {
    return MuscleGroupStat(
      muscleGroup: json['muscleGroup'] ?? '',
      setCount: json['setCount'] ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
