import 'package:drift/drift.dart';

/// Exercises table
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get primaryMuscleGroup => text().nullable()();
  TextColumn get secondaryMuscleGroups => text().nullable()(); // JSON array
  TextColumn get equipmentRequired => text().nullable()();
  TextColumn get difficultyLevel => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Workouts table
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get name => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get totalVolumeKg => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Workout exercises table (junction table)
class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer()();
  IntColumn get exerciseId => integer()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Sets table
class Sets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutExerciseId => integer()();
  IntColumn get setNumber => integer()();
  IntColumn get reps => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get rpe => real().nullable()(); // Rate of Perceived Exertion
  TextColumn get notes => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Personal records table
class PersonalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get exerciseId => integer()();
  TextColumn get recordType => text()(); // '1RM', 'max_reps', 'max_volume'
  RealColumn get value => real()();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  IntColumn get workoutId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

