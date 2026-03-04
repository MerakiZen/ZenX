import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

import '../providers/analytics_providers.dart';

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
    final topExercisesAsync = ref.watch(topExercisesProvider(limit: 20));

    return topExercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return const Center(child: Text('No exercises found', style: TextStyle(color: HevyColors.textSecondary)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _MainExerciseListItem(
              exercise: _MainExercise(
                id: exercise.exerciseName,
                name: exercise.exerciseName,
                primaryMuscle: '', // Not available in this query
                secondaryMuscles: [], 
                totalSets: exercise.workoutCount, // Using workoutCount as proxy for frequency
                heaviestWeight: exercise.averageWeight ?? 0.0,
                lastWorkoutDate: exercise.lastPerformed,
              ),
              onTap: () {
                // Navigate to exercise detail screen
                context.push('/exercises/${exercise.exerciseId}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}

class _MainExercise {
  final String id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final int totalSets;
  final double heaviestWeight;
  final DateTime? lastWorkoutDate;

  _MainExercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.totalSets,
    required this.heaviestWeight,
    this.lastWorkoutDate,
  });
}

class _MainExerciseListItem extends StatelessWidget {
  final _MainExercise exercise;
  final VoidCallback onTap;

  const _MainExerciseListItem({
    required this.exercise,
    required this.onTap,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
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
                  if (exercise.primaryMuscle.isNotEmpty)
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
                        '${exercise.heaviestWeight.toInt()} kg (avg)',
                        style: const TextStyle(
                          fontSize: DesignTokens.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: HevyColors.primary,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacingS),
                      if (exercise.lastWorkoutDate != null)
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
                '${exercise.totalSets} workouts',
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

