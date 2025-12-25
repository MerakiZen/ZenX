// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workoutCalendarHash() => r'00384e21ea11f362cdc44428b39752f8058a8127';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [workoutCalendar].
@ProviderFor(workoutCalendar)
const workoutCalendarProvider = WorkoutCalendarFamily();

/// See also [workoutCalendar].
class WorkoutCalendarFamily extends Family<AsyncValue<WorkoutCalendar>> {
  /// See also [workoutCalendar].
  const WorkoutCalendarFamily();

  /// See also [workoutCalendar].
  WorkoutCalendarProvider call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return WorkoutCalendarProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  WorkoutCalendarProvider getProviderOverride(
    covariant WorkoutCalendarProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workoutCalendarProvider';
}

/// See also [workoutCalendar].
class WorkoutCalendarProvider
    extends AutoDisposeFutureProvider<WorkoutCalendar> {
  /// See also [workoutCalendar].
  WorkoutCalendarProvider({
    required DateTime startDate,
    required DateTime endDate,
  }) : this._internal(
          (ref) => workoutCalendar(
            ref as WorkoutCalendarRef,
            startDate: startDate,
            endDate: endDate,
          ),
          from: workoutCalendarProvider,
          name: r'workoutCalendarProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$workoutCalendarHash,
          dependencies: WorkoutCalendarFamily._dependencies,
          allTransitiveDependencies:
              WorkoutCalendarFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  WorkoutCalendarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<WorkoutCalendar> Function(WorkoutCalendarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WorkoutCalendarProvider._internal(
        (ref) => create(ref as WorkoutCalendarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WorkoutCalendar> createElement() {
    return _WorkoutCalendarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutCalendarProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkoutCalendarRef on AutoDisposeFutureProviderRef<WorkoutCalendar> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _WorkoutCalendarProviderElement
    extends AutoDisposeFutureProviderElement<WorkoutCalendar>
    with WorkoutCalendarRef {
  _WorkoutCalendarProviderElement(super.provider);

  @override
  DateTime get startDate => (origin as WorkoutCalendarProvider).startDate;
  @override
  DateTime get endDate => (origin as WorkoutCalendarProvider).endDate;
}

String _$muscleGroupStatsHash() => r'c3032c10b9f4dd176add2cf4d40aa17c2a45d41a';

/// See also [muscleGroupStats].
@ProviderFor(muscleGroupStats)
const muscleGroupStatsProvider = MuscleGroupStatsFamily();

/// See also [muscleGroupStats].
class MuscleGroupStatsFamily extends Family<AsyncValue<List<MuscleGroupStat>>> {
  /// See also [muscleGroupStats].
  const MuscleGroupStatsFamily();

  /// See also [muscleGroupStats].
  MuscleGroupStatsProvider call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MuscleGroupStatsProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  MuscleGroupStatsProvider getProviderOverride(
    covariant MuscleGroupStatsProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'muscleGroupStatsProvider';
}

/// See also [muscleGroupStats].
class MuscleGroupStatsProvider
    extends AutoDisposeFutureProvider<List<MuscleGroupStat>> {
  /// See also [muscleGroupStats].
  MuscleGroupStatsProvider({
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
          (ref) => muscleGroupStats(
            ref as MuscleGroupStatsRef,
            startDate: startDate,
            endDate: endDate,
          ),
          from: muscleGroupStatsProvider,
          name: r'muscleGroupStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$muscleGroupStatsHash,
          dependencies: MuscleGroupStatsFamily._dependencies,
          allTransitiveDependencies:
              MuscleGroupStatsFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  MuscleGroupStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<MuscleGroupStat>> Function(MuscleGroupStatsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MuscleGroupStatsProvider._internal(
        (ref) => create(ref as MuscleGroupStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MuscleGroupStat>> createElement() {
    return _MuscleGroupStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MuscleGroupStatsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MuscleGroupStatsRef
    on AutoDisposeFutureProviderRef<List<MuscleGroupStat>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _MuscleGroupStatsProviderElement
    extends AutoDisposeFutureProviderElement<List<MuscleGroupStat>>
    with MuscleGroupStatsRef {
  _MuscleGroupStatsProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as MuscleGroupStatsProvider).startDate;
  @override
  DateTime? get endDate => (origin as MuscleGroupStatsProvider).endDate;
}

String _$topExercisesHash() => r'f94beb3816ce608ea7706a088603581a9898e1f0';

/// See also [topExercises].
@ProviderFor(topExercises)
const topExercisesProvider = TopExercisesFamily();

/// See also [topExercises].
class TopExercisesFamily extends Family<AsyncValue<List<ExerciseRecord>>> {
  /// See also [topExercises].
  const TopExercisesFamily();

  /// See also [topExercises].
  TopExercisesProvider call({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TopExercisesProvider(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  TopExercisesProvider getProviderOverride(
    covariant TopExercisesProvider provider,
  ) {
    return call(
      limit: provider.limit,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topExercisesProvider';
}

/// See also [topExercises].
class TopExercisesProvider
    extends AutoDisposeFutureProvider<List<ExerciseRecord>> {
  /// See also [topExercises].
  TopExercisesProvider({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
          (ref) => topExercises(
            ref as TopExercisesRef,
            limit: limit,
            startDate: startDate,
            endDate: endDate,
          ),
          from: topExercisesProvider,
          name: r'topExercisesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$topExercisesHash,
          dependencies: TopExercisesFamily._dependencies,
          allTransitiveDependencies:
              TopExercisesFamily._allTransitiveDependencies,
          limit: limit,
          startDate: startDate,
          endDate: endDate,
        );

  TopExercisesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<ExerciseRecord>> Function(TopExercisesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopExercisesProvider._internal(
        (ref) => create(ref as TopExercisesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExerciseRecord>> createElement() {
    return _TopExercisesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopExercisesProvider &&
        other.limit == limit &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopExercisesRef on AutoDisposeFutureProviderRef<List<ExerciseRecord>> {
  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _TopExercisesProviderElement
    extends AutoDisposeFutureProviderElement<List<ExerciseRecord>>
    with TopExercisesRef {
  _TopExercisesProviderElement(super.provider);

  @override
  int get limit => (origin as TopExercisesProvider).limit;
  @override
  DateTime? get startDate => (origin as TopExercisesProvider).startDate;
  @override
  DateTime? get endDate => (origin as TopExercisesProvider).endDate;
}

String _$exercisePerformanceHash() =>
    r'5bf0d9c91d432af7ea6a21d10becdd1a35fa3044';

/// See also [exercisePerformance].
@ProviderFor(exercisePerformance)
const exercisePerformanceProvider = ExercisePerformanceFamily();

/// See also [exercisePerformance].
class ExercisePerformanceFamily
    extends Family<AsyncValue<ExercisePerformance>> {
  /// See also [exercisePerformance].
  const ExercisePerformanceFamily();

  /// See also [exercisePerformance].
  ExercisePerformanceProvider call(
    String exerciseId,
  ) {
    return ExercisePerformanceProvider(
      exerciseId,
    );
  }

  @override
  ExercisePerformanceProvider getProviderOverride(
    covariant ExercisePerformanceProvider provider,
  ) {
    return call(
      provider.exerciseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'exercisePerformanceProvider';
}

/// See also [exercisePerformance].
class ExercisePerformanceProvider
    extends AutoDisposeFutureProvider<ExercisePerformance> {
  /// See also [exercisePerformance].
  ExercisePerformanceProvider(
    String exerciseId,
  ) : this._internal(
          (ref) => exercisePerformance(
            ref as ExercisePerformanceRef,
            exerciseId,
          ),
          from: exercisePerformanceProvider,
          name: r'exercisePerformanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exercisePerformanceHash,
          dependencies: ExercisePerformanceFamily._dependencies,
          allTransitiveDependencies:
              ExercisePerformanceFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  ExercisePerformanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exerciseId,
  }) : super.internal();

  final String exerciseId;

  @override
  Override overrideWith(
    FutureOr<ExercisePerformance> Function(ExercisePerformanceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExercisePerformanceProvider._internal(
        (ref) => create(ref as ExercisePerformanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exerciseId: exerciseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExercisePerformance> createElement() {
    return _ExercisePerformanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExercisePerformanceProvider &&
        other.exerciseId == exerciseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exerciseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExercisePerformanceRef
    on AutoDisposeFutureProviderRef<ExercisePerformance> {
  /// The parameter `exerciseId` of this provider.
  String get exerciseId;
}

class _ExercisePerformanceProviderElement
    extends AutoDisposeFutureProviderElement<ExercisePerformance>
    with ExercisePerformanceRef {
  _ExercisePerformanceProviderElement(super.provider);

  @override
  String get exerciseId => (origin as ExercisePerformanceProvider).exerciseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
