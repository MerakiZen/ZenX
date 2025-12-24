import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Strength progression screen (Hevy style)
class StrengthProgressionScreen extends BaseScreen {
  const StrengthProgressionScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Strength Progression',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    // Realistic deployment mock data
    final exercises = [
      _ExerciseProgression(
        name: 'Bench Press',
        current1RM: 120.0,
        previous1RM: 115.0,
        progress: 5.0,
      ),
      _ExerciseProgression(
        name: 'Squat',
        current1RM: 180.0,
        previous1RM: 175.0,
        progress: 5.0,
      ),
      _ExerciseProgression(
        name: 'Deadlift',
        current1RM: 220.0,
        previous1RM: 210.0,
        progress: 10.0,
      ),
      _ExerciseProgression(
        name: 'Overhead Press',
        current1RM: 75.0,
        previous1RM: 72.5,
        progress: 2.5,
      ),
      _ExerciseProgression(
        name: 'Barbell Row',
        current1RM: 130.0,
        previous1RM: 125.0,
        progress: 5.0,
      ),
    ];
    
    final avgProgress = exercises.map((e) => e.progress).reduce((a, b) => a + b) / exercises.length;

    return ListView(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      children: [
        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressionStat(
                        label: 'Exercises',
                        value: '${exercises.length}',
                        icon: Icons.fitness_center,
                      ),
                    ),
                    Expanded(
                      child: _ProgressionStat(
                        label: 'Avg Progress',
                        value: '+${avgProgress.toStringAsFixed(1)} kg',
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: DesignTokens.spacingXL),

        // Exercise progressions
        Text(
          'Exercise Progressions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DesignTokens.spacingM),
        ...exercises.map((exercise) {
          return _ExerciseProgressionCard(exercise: exercise);
        }),
      ],
    );
  }
}

/// Exercise progression model
class _ExerciseProgression {
  final String name;
  final double current1RM;
  final double previous1RM;
  final double progress;

  _ExerciseProgression({
    required this.name,
    required this.current1RM,
    required this.previous1RM,
    required this.progress,
  });
}

/// Progression stat widget
class _ProgressionStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProgressionStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: HevyColors.accent,
          size: DesignTokens.iconMedium, // 24dp
        ),
        const SizedBox(height: DesignTokens.spacingS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: HevyColors.accent,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Exercise progression card
class _ExerciseProgressionCard extends StatelessWidget {
  final _ExerciseProgression exercise;

  const _ExerciseProgressionCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final isPositive = exercise.progress > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS,
                    vertical: DesignTokens.spacingXXS,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? HevyColors.accent.withValues(alpha: 0.2)
                        : HevyColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${exercise.progress.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPositive ? HevyColors.accent : HevyColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingM),
            Row(
              children: [
                Expanded(
                  child: _ProgressionValue(
                    label: 'Current',
                    value: '${exercise.current1RM.toStringAsFixed(1)} kg',
                  ),
                ),
                Expanded(
                  child: _ProgressionValue(
                    label: 'Previous',
                    value: '${exercise.previous1RM.toStringAsFixed(1)} kg',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Progression value widget
class _ProgressionValue extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressionValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
