import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Main Exercises screen - Shows list of exercises you do most often
class MainExercisesScreen extends BaseScreen {
  const MainExercisesScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Main Exercises'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final mainExercises = _generateMockMainExercises();

    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      itemCount: mainExercises.length,
      itemBuilder: (context, index) {
        final exercise = mainExercises[index];
        return _MainExerciseListItem(
          exercise: exercise,
          onTap: () {
            // Navigate to exercise detail screen
            context.push('/exercises/${exercise.id}');
          },
        );
      },
    );
  }

  List<_MainExercise> _generateMockMainExercises() {
    return [
      _MainExercise(
        id: 'leg_press_machine',
        name: 'Leg Press (Machine)',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        totalSets: 45,
        heaviestWeight: 200.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _MainExercise(
        id: 'bench_press_barbell',
        name: 'Bench Press (Barbell)',
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Shoulders', 'Triceps'],
        totalSets: 52,
        heaviestWeight: 120.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _MainExercise(
        id: 'squat_barbell',
        name: 'Squat (Barbell)',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        totalSets: 38,
        heaviestWeight: 180.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      _MainExercise(
        id: 'deadlift_barbell',
        name: 'Deadlift (Barbell)',
        primaryMuscle: 'Upper Back',
        secondaryMuscles: ['Hamstrings', 'Glutes'],
        totalSets: 42,
        heaviestWeight: 220.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 4)),
      ),
      _MainExercise(
        id: 'lat_pulldown_cable',
        name: 'Lat Pulldown (Cable)',
        primaryMuscle: 'Lats',
        secondaryMuscles: ['Biceps', 'Upper Back'],
        totalSets: 48,
        heaviestWeight: 90.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _MainExercise(
        id: 'shoulder_press_dumbbell',
        name: 'Shoulder Press (Dumbbell)',
        primaryMuscle: 'Shoulders',
        secondaryMuscles: ['Triceps'],
        totalSets: 35,
        heaviestWeight: 45.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      _MainExercise(
        id: 'triceps_rope_pushdown',
        name: 'Triceps Rope Pushdown',
        primaryMuscle: 'Triceps',
        secondaryMuscles: [],
        totalSets: 40,
        heaviestWeight: 50.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _MainExercise(
        id: 'bicep_curl_dumbbell',
        name: 'Bicep Curl (Dumbbell)',
        primaryMuscle: 'Biceps',
        secondaryMuscles: [],
        totalSets: 44,
        heaviestWeight: 25.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _MainExercise(
        id: 'row_cable',
        name: 'Seated Cable Row',
        primaryMuscle: 'Upper Back',
        secondaryMuscles: ['Biceps', 'Lats'],
        totalSets: 41,
        heaviestWeight: 80.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      _MainExercise(
        id: 'leg_extension_machine',
        name: 'Leg Extension (Machine)',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: [],
        totalSets: 33,
        heaviestWeight: 100.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}

class _MainExercise {
  final String id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final int totalSets;
  final double heaviestWeight;
  final DateTime lastWorkoutDate;

  _MainExercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.totalSets,
    required this.heaviestWeight,
    required this.lastWorkoutDate,
  });
}

class _MainExerciseListItem extends StatelessWidget {
  final _MainExercise exercise;
  final VoidCallback onTap;

  const _MainExerciseListItem({
    required this.exercise,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          border: Border.all(color: HevyColors.border),
        ),
        child: Row(
          children: [
            // Exercise icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: HevyColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DesignTokens.spacingXXS),
                  Text(
                    'Primary: ${exercise.primaryMuscle}',
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                  if (exercise.secondaryMuscles.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Secondary: ${exercise.secondaryMuscles.join(", ")}',
                      style: const TextStyle(
                        fontSize: DesignTokens.bodySmall,
                        color: HevyColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spacingXXS),
                  Row(
                    children: [
                      Text(
                        '${exercise.heaviestWeight.toInt()} kg',
                        style: const TextStyle(
                          fontSize: DesignTokens.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: HevyColors.primary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacingS),
                      Text(
                        _formatDate(exercise.lastWorkoutDate),
                        style: const TextStyle(
                          fontSize: DesignTokens.bodySmall,
                          color: HevyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Total sets badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: HevyColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              child: Text(
                '${exercise.totalSets} sets',
                style: const TextStyle(
                  fontSize: DesignTokens.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: HevyColors.primary,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
            const Icon(
              Icons.chevron_right,
              color: HevyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

