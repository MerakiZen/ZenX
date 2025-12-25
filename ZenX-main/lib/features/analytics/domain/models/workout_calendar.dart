class WorkoutCalendar {
  final String startDate;
  final String endDate;
  final List<String> workoutDays;
  final int totalWorkouts;

  WorkoutCalendar({
    required this.startDate,
    required this.endDate,
    required this.workoutDays,
    required this.totalWorkouts,
  });

  factory WorkoutCalendar.fromJson(Map<String, dynamic> json) {
    return WorkoutCalendar(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      workoutDays: List<String>.from(json['workoutDays'] ?? []),
      totalWorkouts: json['totalWorkouts'] ?? 0,
    );
  }
}
