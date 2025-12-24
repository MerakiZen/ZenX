import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Exercise detail screen (Hevy style)
class ExerciseDetailScreen extends BaseScreen {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  _ExerciseData _getExerciseData(String exerciseId) {
    // Map exercise IDs to their data
    final exercisesMap = {
      'leg_press_machine': _ExerciseData(
        name: 'Leg Press (Machine)',
        category: 'Legs',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        equipment: 'Machine',
        description: 'A compound leg exercise performed on a leg press machine, targeting the quadriceps, glutes, and hamstrings.',
        oneRM: 200.0,
        maxReps: 12,
        maxVolume: 2400.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 2)), sets: 4, volume: 3200),
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 9)), sets: 4, volume: 3000),
        ],
      ),
      'bench_press_barbell': _ExerciseData(
        name: 'Bench Press (Barbell)',
        category: 'Chest',
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Shoulders', 'Triceps'],
        equipment: 'Barbell',
        description: 'A compound exercise targeting the chest, shoulders, and triceps.',
        oneRM: 120.0,
        maxReps: 10,
        maxVolume: 1440.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 1)), sets: 4, volume: 480),
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 5)), sets: 4, volume: 460),
        ],
      ),
      'squat_barbell': _ExerciseData(
        name: 'Squat (Barbell)',
        category: 'Legs',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        equipment: 'Barbell',
        description: 'A fundamental compound exercise targeting the entire lower body.',
        oneRM: 180.0,
        maxReps: 8,
        maxVolume: 2160.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 3)), sets: 5, volume: 2700),
        ],
      ),
      'deadlift_barbell': _ExerciseData(
        name: 'Deadlift (Barbell)',
        category: 'Back',
        primaryMuscle: 'Upper Back',
        secondaryMuscles: ['Hamstrings', 'Glutes'],
        equipment: 'Barbell',
        description: 'A compound exercise targeting the posterior chain including back, glutes, and hamstrings.',
        oneRM: 220.0,
        maxReps: 6,
        maxVolume: 2640.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 4)), sets: 3, volume: 1980),
        ],
      ),
      'lat_pulldown_cable': _ExerciseData(
        name: 'Lat Pulldown (Cable)',
        category: 'Back',
        primaryMuscle: 'Lats',
        secondaryMuscles: ['Biceps', 'Upper Back'],
        equipment: 'Cable',
        description: 'A pulling exercise targeting the latissimus dorsi and biceps.',
        oneRM: 90.0,
        maxReps: 12,
        maxVolume: 1080.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 2)), sets: 4, volume: 1440),
        ],
      ),
      'shoulder_press_dumbbell': _ExerciseData(
        name: 'Shoulder Press (Dumbbell)',
        category: 'Shoulders',
        primaryMuscle: 'Shoulders',
        secondaryMuscles: ['Triceps'],
        equipment: 'Dumbbell',
        description: 'An overhead pressing movement targeting the shoulders and triceps.',
        oneRM: 45.0,
        maxReps: 10,
        maxVolume: 540.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 5)), sets: 4, volume: 720),
        ],
      ),
      'triceps_rope_pushdown': _ExerciseData(
        name: 'Triceps Rope Pushdown',
        category: 'Arms',
        primaryMuscle: 'Triceps',
        secondaryMuscles: [],
        equipment: 'Cable',
        description: 'An isolation exercise targeting the triceps muscles.',
        oneRM: 50.0,
        maxReps: 15,
        maxVolume: 750.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 1)), sets: 4, volume: 1000),
        ],
      ),
      'bicep_curl_dumbbell': _ExerciseData(
        name: 'Bicep Curl (Dumbbell)',
        category: 'Arms',
        primaryMuscle: 'Biceps',
        secondaryMuscles: [],
        equipment: 'Dumbbell',
        description: 'An isolation exercise targeting the biceps muscles.',
        oneRM: 25.0,
        maxReps: 12,
        maxVolume: 360.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 2)), sets: 4, volume: 480),
        ],
      ),
      'row_cable': _ExerciseData(
        name: 'Seated Cable Row',
        category: 'Back',
        primaryMuscle: 'Upper Back',
        secondaryMuscles: ['Biceps', 'Lats'],
        equipment: 'Cable',
        description: 'A horizontal pulling exercise targeting the upper back and biceps.',
        oneRM: 80.0,
        maxReps: 10,
        maxVolume: 960.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 3)), sets: 4, volume: 1280),
        ],
      ),
      'leg_extension_machine': _ExerciseData(
        name: 'Leg Extension (Machine)',
        category: 'Legs',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: [],
        equipment: 'Machine',
        description: 'An isolation exercise targeting the quadriceps muscles.',
        oneRM: 100.0,
        maxReps: 15,
        maxVolume: 1500.0,
        recentWorkouts: [
          _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 6)), sets: 3, volume: 900),
        ],
      ),
    };

    // Return exercise data or default to Bench Press
    return exercisesMap[exerciseId] ?? _ExerciseData(
      name: 'Bench Press',
      category: 'Chest',
      primaryMuscle: 'Chest',
      secondaryMuscles: ['Shoulders', 'Triceps'],
      equipment: 'Barbell',
      description: 'A compound exercise targeting the chest, shoulders, and triceps.',
      oneRM: 100.0,
      maxReps: 12,
      maxVolume: 1200.0,
      recentWorkouts: [
        _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 2)), sets: 3, volume: 630),
        _RecentWorkout(date: DateTime.now().subtract(const Duration(days: 5)), sets: 3, volume: 600),
      ],
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final exerciseData = _getExerciseData(exerciseId);
    
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: Text(
        exerciseData.name,
        style: const TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share_rounded),
          color: HevyColors.textPrimary,
          onPressed: () {
            // TODO: Share exercise
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: HevyColors.textPrimary,
          onPressed: () {
            // TODO: Show exercise options (edit, delete)
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final exerciseData = _getExerciseData(exerciseId);

    return CustomScrollView(
      slivers: [
        // Exercise info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseData.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Wrap(
                  spacing: DesignTokens.spacingS,
                  runSpacing: DesignTokens.spacingS,
                  children: [
                    _InfoChip(
                      icon: Icons.fitness_center,
                      label: exerciseData.primaryMuscle,
                    ),
                    if (exerciseData.secondaryMuscles.isNotEmpty)
                      _InfoChip(
                        icon: Icons.fitness_center_outlined,
                        label: exerciseData.secondaryMuscles.join(', '),
                      ),
                    _InfoChip(
                      icon: Icons.sports_gymnastics,
                      label: exerciseData.equipment,
                    ),
                    _InfoChip(
                      icon: Icons.category,
                      label: exerciseData.category,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingL),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Text(
                  exerciseData.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        // Personal records
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Records',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                _PRRow(label: '1RM', value: '${exerciseData.oneRM.toInt()} kg'),
                const SizedBox(height: DesignTokens.spacingS),
                _PRRow(label: 'Max Reps', value: exerciseData.maxReps.toString()),
                const SizedBox(height: DesignTokens.spacingS),
                _PRRow(label: 'Max Volume', value: '${exerciseData.maxVolume.toInt()} kg'),
              ],
            ),
          ),
        ),

        // Recent workouts
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Workouts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                ...exerciseData.recentWorkouts.map((workout) => Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                  child: _RecentWorkoutRow(
                    date: workout.date,
                    sets: '${workout.sets} sets',
                    volume: '${workout.volume.toInt()} kg',
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: DesignTokens.iconSmall, // 16dp
      ),
      label: Text(label),
      backgroundColor: HevyColors.surfaceElevated,
    );
  }
}

/// PR row widget
class _PRRow extends StatelessWidget {
  final String label;
  final String value;

  const _PRRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: HevyColors.accentOrange,
                  size: DesignTokens.iconSmall, // 16dp (small inline icon)
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HevyColors.accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent workout row
class _RecentWorkoutRow extends StatelessWidget {
  final DateTime date;
  final String sets;
  final String volume;

  const _RecentWorkoutRow({
    required this.date,
    required this.sets,
    required this.volume,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to workout detail
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                children: [
                  Text(
                    sets,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: DesignTokens.spacingM),
                  Text(
                    volume,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: DesignTokens.spacingS),
                  const Icon(
                    Icons.chevron_right,
                    size: DesignTokens.iconSmall, // 16dp
                    color: HevyColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exercise data model
class _ExerciseData {
  final String name;
  final String category;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final String description;
  final double oneRM;
  final int maxReps;
  final double maxVolume;
  final List<_RecentWorkout> recentWorkouts;

  _ExerciseData({
    required this.name,
    required this.category,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.description,
    required this.oneRM,
    required this.maxReps,
    required this.maxVolume,
    required this.recentWorkouts,
  });
}

/// Recent workout data model
class _RecentWorkout {
  final DateTime date;
  final int sets;
  final double volume;

  _RecentWorkout({
    required this.date,
    required this.sets,
    required this.volume,
  });
}
