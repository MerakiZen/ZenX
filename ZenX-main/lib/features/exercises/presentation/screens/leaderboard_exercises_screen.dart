import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/help_dialog_helper.dart';

/// Leaderboard Exercises screen - Shows list of barbell exercises
class LeaderboardExercisesScreen extends BaseScreen {
  const LeaderboardExercisesScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Leaderboard Exercises'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: HevyColors.textPrimary,
          onPressed: () {
            HelpDialogHelper.showLeaderboardExercisesHelp(context);
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final exercises = _getLeaderboardExercises();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _ExerciseListItem(
          exercise: exercise,
          onTap: () => context.push('/exercises/${exercise.id}'),
        );
      },
    );
  }

  List<_LeaderboardExercise> _getLeaderboardExercises() {
    return [
      _LeaderboardExercise(
        id: 'bench_press_barbell',
        name: 'Bench Press (Barbell)',
        primaryMuscle: 'Chest',
      ),
      _LeaderboardExercise(
        id: 'bent_over_row_barbell',
        name: 'Bent Over Row (Barbell)',
        primaryMuscle: 'Upper Back',
      ),
      _LeaderboardExercise(
        id: 'bicep_curl_barbell',
        name: 'Bicep Curl (Barbell)',
        primaryMuscle: 'Biceps',
      ),
      _LeaderboardExercise(
        id: 'deadlift_barbell',
        name: 'Deadlift (Barbell)',
        primaryMuscle: 'Glutes',
      ),
      _LeaderboardExercise(
        id: 'overhead_press_barbell',
        name: 'Overhead Press (Barbell)',
        primaryMuscle: 'Shoulders',
      ),
      _LeaderboardExercise(
        id: 'skullcrusher_barbell',
        name: 'Skullcrusher (Barbell)',
        primaryMuscle: 'Triceps',
      ),
      _LeaderboardExercise(
        id: 'squat_barbell',
        name: 'Squat (Barbell)',
        primaryMuscle: 'Quadriceps',
      ),
    ];
  }
}

class _LeaderboardExercise {
  final String id;
  final String name;
  final String primaryMuscle;

  _LeaderboardExercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
  });
}

class _ExerciseListItem extends StatelessWidget {
  final _LeaderboardExercise exercise;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingScreen,
          vertical: DesignTokens.spacingM,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: HevyColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Circular icon placeholder
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: HevyColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: HevyColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            // Exercise details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.primaryMuscle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HevyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: HevyColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
