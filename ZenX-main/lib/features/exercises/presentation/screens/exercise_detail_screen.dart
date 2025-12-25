import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

import '../../../analytics/presentation/providers/analytics_providers.dart';

/// Exercise detail screen (Hevy style)
class ExerciseDetailScreen extends BaseScreen {
  final String exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(exercisePerformanceProvider(exerciseId));
    final title = performanceAsync.value?.exerciseName ?? exerciseId;
    
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
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
    final performanceAsync = ref.watch(exercisePerformanceProvider(exerciseId));

    return performanceAsync.when(
      data: (performance) {
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
                      performance.exerciseName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: DesignTokens.spacingM),
                    // Metadata not available in analytics API yet
                    /*
                    Wrap(
                      spacing: DesignTokens.spacingS,
                      runSpacing: DesignTokens.spacingS,
                      children: [
                        _InfoChip(
                          icon: Icons.fitness_center,
                          label: 'Muscle',
                        ),
                      ],
                    ),
                    */
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
                    _PRRow(label: '1RM', value: '${(performance.projectedOneRM ?? 0).toInt()} kg'),
                    const SizedBox(height: DesignTokens.spacingS),
                    _PRRow(label: 'Max Reps', value: (performance.mostReps ?? 0).toString()),
                    const SizedBox(height: DesignTokens.spacingS),
                    _PRRow(label: 'Max Volume', value: '${(performance.bestSessionVolume ?? 0).toInt()} kg'),
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
                    if (performance.history.isEmpty)
                      const Text('No recent workouts', style: TextStyle(color: HevyColors.textSecondary)),
                    ...performance.history.map((workout) => Padding(
                      padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                      child: _RecentWorkoutRow(
                        date: DateTime.parse(workout.date),
                        sets: '-- sets', // Not available
                        volume: '${(workout.volume ?? 0).toInt()} kg',
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
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
