import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../providers/workout_providers.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../../exercises/domain/models/exercise.dart';

/// Create workout screen (Hevy style)
class CreateWorkoutScreen extends ConsumerStatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  ConsumerState<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends ConsumerState<CreateWorkoutScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Exercise> _selectedExercises = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startWorkout() async {
    final workoutName = _nameController.text.trim();
    if (workoutName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a workout name'),
          backgroundColor: HevyColors.error,
        ),
      );
      return;
    }

    // Navigate to active workout screen
    context.push('/workouts/active');
  }

  void _addExercise() async {
    final selectedExercise = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExerciseSelectorBottomSheet(),
    );

    if (selectedExercise != null) {
      setState(() {
        if (!_selectedExercises.any((e) => e.id == selectedExercise.id)) {
          _selectedExercises.add(selectedExercise);
        }
      });
    }
  }

  void _removeExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.removeWhere((e) => e.id == exercise.id);
    });
  }

  void _loadTemplate(String templateName) {
    // Load template exercises based on template name
    // For now, just show a message - templates can be implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$templateName template will be available soon'),
        backgroundColor: HevyColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: _buildBody(context, ref),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'New Workout',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _startWorkout,
          child: const Text(
            'Start',
            style: TextStyle(
              color: HevyColors.primary,
              fontSize: DesignTokens.bodyMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final recentWorkouts = ref.watch(workoutsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Workout name input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Workout Name',
              hintText: 'e.g., Push Day, Leg Day',
              prefixIcon: const Icon(Icons.fitness_center),
              filled: true,
              fillColor: HevyColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                borderSide: BorderSide(color: HevyColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                borderSide: BorderSide(color: HevyColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                borderSide: BorderSide(color: HevyColors.primary, width: 2),
              ),
              labelStyle: TextStyle(color: HevyColors.textSecondary),
              hintStyle: TextStyle(color: HevyColors.textTertiary),
            ),
            style: TextStyle(color: HevyColors.textPrimary),
          ),
          const SizedBox(height: DesignTokens.spacingL),

          // Selected exercises
          if (_selectedExercises.isNotEmpty) ...[
            Text(
              'Selected Exercises',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HevyColors.textPrimary,
                  ),
            ),
            const SizedBox(height: DesignTokens.spacingM),
            ..._selectedExercises.map((exercise) {
              return Card(
                margin: const EdgeInsets.only(bottom: DesignTokens.spacingS),
                color: HevyColors.surface,
                child: ListTile(
                  leading: Icon(Icons.fitness_center, color: HevyColors.primary),
                  title: Text(
                    exercise.name,
                    style: TextStyle(color: HevyColors.textPrimary),
                  ),
                  subtitle: Text(
                    exercise.primaryMuscleGroup ?? 'Unknown',
                    style: TextStyle(color: HevyColors.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    color: HevyColors.textSecondary,
                    onPressed: () => _removeExercise(exercise),
                  ),
                ),
              );
            }),
            const SizedBox(height: DesignTokens.spacingL),
          ],

          // Quick templates section
          Text(
            'Quick Start',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HevyColors.textPrimary,
                ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Wrap(
            spacing: DesignTokens.spacingS,
            runSpacing: DesignTokens.spacingS,
            children: [
              _TemplateChip(
                label: 'Push',
                icon: Icons.trending_up,
                onTap: () => _loadTemplate('Push'),
              ),
              _TemplateChip(
                label: 'Pull',
                icon: Icons.trending_down,
                onTap: () => _loadTemplate('Pull'),
              ),
              _TemplateChip(
                label: 'Legs',
                icon: Icons.directions_walk,
                onTap: () => _loadTemplate('Legs'),
              ),
              _TemplateChip(
                label: 'Full Body',
                icon: Icons.accessibility_new,
                onTap: () => _loadTemplate('Full Body'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingXL),

          // Add exercise button
          OutlinedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: HevyColors.border),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingL),

          // Recent workouts section
          Text(
            'Recent Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: HevyColors.textPrimary,
                ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          recentWorkouts.when(
            data: (workouts) {
              if (workouts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                  child: Text(
                    'No recent workouts',
                    style: TextStyle(color: HevyColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: workouts.take(3).map((workout) {
                  return _RecentWorkoutCard(
                    name: workout.name ?? 'Untitled Workout',
                    date: workout.createdAt,
                    onTap: () {
                      context.push('/workouts/${workout.id}/active');
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(DesignTokens.paddingScreen),
              child: Text(
                'Error loading workouts',
                style: TextStyle(color: HevyColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exercise selector bottom sheet
class _ExerciseSelectorBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider(query: null, category: null));
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
      decoration: BoxDecoration(
        color: HevyColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXL),
          topRight: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HevyColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
              vertical: DesignTokens.spacingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Exercise',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: HevyColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: HevyColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: HevyColors.border, height: 1),
          // Exercise list
          Flexible(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                      child: Text(
                        'No exercises found',
                        style: TextStyle(color: HevyColors.textSecondary),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      leading: Icon(Icons.fitness_center, color: HevyColors.primary),
                      title: Text(
                        exercise.name,
                        style: TextStyle(color: HevyColors.textPrimary),
                      ),
                      subtitle: Text(
                        exercise.primaryMuscleGroup ?? 'Unknown',
                        style: TextStyle(color: HevyColors.textSecondary),
                      ),
                      onTap: () => Navigator.pop(context, exercise),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                  child: Text(
                    'Error loading exercises',
                    style: TextStyle(color: HevyColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Template chip widget
class _TemplateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TemplateChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingM,
          vertical: DesignTokens.spacingS,
        ),
        decoration: BoxDecoration(
          color: HevyColors.surfaceElevated,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          border: Border.all(color: HevyColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSmall,
              color: HevyColors.primary,
            ),
            const SizedBox(width: DesignTokens.spacingXS),
            Text(
              label,
              style: TextStyle(color: HevyColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent workout card
class _RecentWorkoutCard extends StatelessWidget {
  final String name;
  final DateTime date;
  final VoidCallback onTap;

  const _RecentWorkoutCard({
    required this.name,
    required this.date,
    required this.onTap,
  });

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      color: HevyColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HevyColors.textPrimary,
                      ),
                ),
              ),
              Text(
                _getTimeAgo(date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HevyColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
