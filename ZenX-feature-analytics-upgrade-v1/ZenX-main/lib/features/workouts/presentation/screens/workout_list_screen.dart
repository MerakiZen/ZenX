import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../providers/workout_providers.dart';

/// Workout list screen - Matches screenshot exactly
class WorkoutListScreen extends BaseScreen {
  const WorkoutListScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Workout',
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
    final workoutsAsync = ref.watch(workoutsProvider);

    return SafeArea(
      top: false,
      child: workoutsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          // Show empty state instead of error if it's a network/auth issue
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('linkexception') || 
              errorStr.contains('network') ||
              errorStr.contains('connection') ||
              errorStr.contains('unauthorized')) {
            return SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.paddingScreen,
                        DesignTokens.spacingXL,
                        DesignTokens.paddingScreen,
                        DesignTokens.spacingM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Start',
                            style: TextStyle(
                              fontSize: DesignTokens.titleLarge,
                              fontWeight: FontWeight.w600,
                              color: HevyColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacingM),
                          _QuickStartButton(
                            onTap: () => context.push('/workouts/create'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.paddingScreen,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Routines',
                                style: TextStyle(
                                  fontSize: DesignTokens.titleLarge,
                                  fontWeight: FontWeight.w600,
                                  color: HevyColors.textPrimary,
                                ),
                              ),
                              _IconSquareButton(
                                icon: Icons.refresh,
                                onTap: () => ref.invalidate(workoutsProvider),
                              ),
                            ],
                          ),
                          const SizedBox(height: DesignTokens.spacingM),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                            decoration: BoxDecoration(
                              color: HevyColors.surface,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                              border: Border.all(color: HevyColors.border),
                            ),
                            child: const Text(
                              'No workouts yet. Create one to get started!',
                              style: TextStyle(
                                color: HevyColors.textSecondary,
                                fontSize: DesignTokens.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // Show error for other issues
          return Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: HevyColors.error, size: 48),
                const SizedBox(height: DesignTokens.spacingM),
                const Text(
                  'Unable to load workouts',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: HevyColors.textSecondary),
                ),
                const SizedBox(height: DesignTokens.spacingL),
                OutlinedButton(
                  onPressed: () => ref.invalidate(workoutsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (workouts) {
          // Convert Workout to WorkoutListItem
          final workoutItems = workouts.map((w) {
            return WorkoutListItem(
              id: w.id,
              title: w.name?.trim().isNotEmpty == true ? w.name! : 'Untitled Workout',
              notes: w.notes?.trim().isEmpty == true ? null : w.notes,
              exerciseCount: 0, // Will be populated when workout details are fetched
              totalSets: 0, // Will be populated when workout details are fetched
            );
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.paddingScreen,
                    DesignTokens.spacingXL,
                    DesignTokens.paddingScreen,
                    DesignTokens.spacingM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Start',
                        style: TextStyle(
                          fontSize: DesignTokens.titleLarge,
                          fontWeight: FontWeight.w600,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacingM),
                      _QuickStartButton(
                        onTap: () => context.push('/workouts/active'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.paddingScreen,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Routines',
                            style: TextStyle(
                              fontSize: DesignTokens.titleLarge,
                              fontWeight: FontWeight.w600,
                              color: HevyColors.textPrimary,
                            ),
                          ),
                          _IconSquareButton(
                            icon: Icons.refresh,
                            onTap: () => ref.invalidate(workoutsProvider),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: _RoutineActionButton(
                              icon: Icons.assignment_outlined,
                              label: 'New Routine',
                              onTap: () => context.push('/workouts/create'),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingM),
                          Expanded(
                            child: _RoutineActionButton(
                              icon: Icons.search_rounded,
                              label: 'Explore',
                              onTap: () => context.push('/exercises'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spacingL),
                      _MyRoutinesSection(workouts: workoutItems),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.paddingScreen,
                    DesignTokens.spacingXL,
                    DesignTokens.paddingScreen,
                    DesignTokens.spacingXXXL,
                  ),
                  child: const _WorkoutProgressBanner(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickStartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickStartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingScreen,
          vertical: DesignTokens.spacingL,
        ),
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          border: Border.all(color: HevyColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: const Icon(
                Icons.add,
                color: HevyColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            const Expanded(
              child: Text(
                'Start Empty Workout',
                style: TextStyle(
                  fontSize: DesignTokens.titleLarge,
                  fontWeight: FontWeight.w600,
                  color: HevyColors.textPrimary,
                ),
              ),
            ),
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

class _RoutineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoutineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          border: Border.all(color: HevyColors.border),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingL,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingXS),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Icon(
                icon,
                color: HevyColors.textPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
            Text(
              label,
              style: const TextStyle(
                fontSize: DesignTokens.bodyLarge,
                fontWeight: FontWeight.w600,
                color: HevyColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRoutinesSection extends StatefulWidget {
  final List<WorkoutListItem> workouts;

  const _MyRoutinesSection({required this.workouts});

  @override
  State<_MyRoutinesSection> createState() => _MyRoutinesSectionState();
}

class _MyRoutinesSectionState extends State<_MyRoutinesSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                color: HevyColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              Text(
                'My Routines (${widget.workouts.length})',
                style: const TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w500,
                  color: HevyColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: DesignTokens.spacingM),
          if (widget.workouts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.paddingScreen),
              decoration: BoxDecoration(
                color: HevyColors.surface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                border: Border.all(color: HevyColors.border),
              ),
              child: const Text(
                'No workouts yet. Create one to get started!',
                style: TextStyle(
                  color: HevyColors.textSecondary,
                  fontSize: DesignTokens.bodyMedium,
                ),
              ),
            )
          else
            ...widget.workouts.map(
              (workout) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                child: _WorkoutCard(workout: workout),
              ),
            ),
        ],
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutListItem workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HevyColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(color: HevyColors.border),
      ),
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workout.title,
                  style: const TextStyle(
                    fontSize: DesignTokens.titleLarge,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/workouts/${workout.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
                color: HevyColors.textSecondary,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Text(
            '${workout.exerciseCount} exercises · ${workout.totalSets} sets',
            style: const TextStyle(
              fontSize: DesignTokens.bodyMedium,
              color: HevyColors.textSecondary,
            ),
          ),
          if (workout.notes != null) ...[
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              workout.notes!,
              style: const TextStyle(
                fontSize: DesignTokens.bodySmall,
                color: HevyColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: DesignTokens.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/workouts/${workout.id}/active'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HevyColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
              ),
              child: const Text(
                'Start Routine',
                style: TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/workouts/${workout.id}/edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spacingM,
                ),
                side: const BorderSide(color: HevyColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
              ),
              child: const Text(
                'Edit Routine',
                style: TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: HevyColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconSquareButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: HevyColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HevyColors.border),
          ),
          child: Icon(icon, size: 18, color: HevyColors.textPrimary),
        ),
      ),
    );
  }
}

class _WorkoutProgressBanner extends StatelessWidget {
  const _WorkoutProgressBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: HevyColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(color: HevyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout in Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacingM),
                    backgroundColor: HevyColors.surfaceElevated,
                    foregroundColor: HevyColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Resume',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacingM),
                    backgroundColor: HevyColors.surfaceElevated,
                    foregroundColor: HevyColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
