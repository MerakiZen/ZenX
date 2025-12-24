import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import '../../../../core/presentation/base_screen.dart'; // Removing BaseScreen to use Stateful
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';
import '../providers/exercise_providers.dart';
import '../../domain/entities/exercise.dart';

/// Add Exercise screen (Hevy style) - Refactored to use real data
class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(context, ref),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    return AppBar(
      leading: TextButton(
        onPressed: () => context.pop(),
        child: const Text(
          'Cancel',
          style: TextStyle(color: HevyColors.primary),
        ),
      ),
      leadingWidth: 80, 
      title: const Text('Add Exercise'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () {
            context.push('/exercises/create');
          },
          child: const Text(
            'Create',
            style: TextStyle(color: HevyColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exercise',
              hintStyle: const TextStyle(color: HevyColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: HevyColors.textSecondary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: HevyColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: HevyColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingS,
              ),
            ),
            style: const TextStyle(color: HevyColors.textPrimary),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Filter buttons (Category) -> Reusing logic similar to ExerciseLibraryScreen
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            children: [
              _CategoryChip(
                label: 'All',
                isSelected: _selectedCategory == 'All',
                onSelected: (selected) => setState(() => _selectedCategory = 'All'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Chest',
                isSelected: _selectedCategory == 'Chest',
                onSelected: (selected) => setState(() => _selectedCategory = 'Chest'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Back',
                isSelected: _selectedCategory == 'Back',
                onSelected: (selected) => setState(() => _selectedCategory = 'Back'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Legs',
                isSelected: _selectedCategory == 'Legs',
                onSelected: (selected) => setState(() => _selectedCategory = 'Legs'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Shoulders',
                isSelected: _selectedCategory == 'Shoulders',
                onSelected: (selected) => setState(() => _selectedCategory = 'Shoulders'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Arms',
                isSelected: _selectedCategory == 'Arms',
                onSelected: (selected) => setState(() => _selectedCategory = 'Arms'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Core',
                isSelected: _selectedCategory == 'Core',
                onSelected: (selected) => setState(() => _selectedCategory = 'Core'),
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Cardio',
                isSelected: _selectedCategory == 'Cardio',
                onSelected: (selected) => setState(() => _selectedCategory = 'Cardio'),
              ),
            ],
          ),
        ),

        const SizedBox(height: DesignTokens.spacingS),
        const Divider(height: 1, color: HevyColors.border),

        // Exercise list
        Expanded(
          child: _ExerciseList(
            searchQuery: _searchQuery,
            category: _selectedCategory == 'All' ? null : _selectedCategory,
            onExerciseSelected: (exercise) {
               // Return exercise data as a map so it can be used in workout screen
               // We need to return map because the caller expects a map to create a new exercise entry
               // Or ideally we should return the Exercise object causing less coupling to Map structure.
               // Checking usage in active_workout_screen.dart might be needed, but for now sticking to the Map protocol established in previous code.
               context.pop({
                 'name': exercise.name,
                 'muscleGroup': exercise.primaryMuscleGroup ?? 'Other',
                 'exerciseId': exercise.id, // Adding ID is crucial for real backend linking
                 'equipment': exercise.equipmentRequired ?? 'Other',
               });
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? HevyColors.primary : HevyColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: HevyColors.primary.withValues(alpha: 0.2),
      checkmarkColor: HevyColors.primary,
      backgroundColor: HevyColors.surface,
      side: BorderSide(
        color: isSelected ? HevyColors.primary : HevyColors.border,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}


class _ExerciseList extends ConsumerWidget {
  final String searchQuery;
  final String? category;
  final Function(Exercise) onExerciseSelected;

  const _ExerciseList({
    required this.searchQuery,
    this.category,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = searchQuery.isNotEmpty
        ? ref.watch(searchExercisesProvider(searchQuery))
        : category != null
            ? ref.watch(exercisesByCategoryProvider(category!))
            : ref.watch(exercisesProvider);

    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: HevyColors.textTertiary,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                const Text(
                  'No exercises found',
                  style: TextStyle(
                    color: HevyColors.textSecondary,
                    fontSize: DesignTokens.bodyLarge,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'Create your first exercise',
                  style: const TextStyle(
                    color: HevyColors.textTertiary,
                    fontSize: DesignTokens.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _ExerciseListItem(
              exercise: exercise,
              onTap: () => onExerciseSelected(exercise),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingWidget()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: HevyColors.error,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              const Text(
                'Error loading exercises',
                style: TextStyle(color: HevyColors.error),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              ElevatedButton(
                onPressed: () => ref.refresh(exercisesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        child: Row(
          children: [
            // Exercise icon
            Container(
              width: 48,
              height: 48,
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
            // Exercise name and muscle group
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      fontWeight: FontWeight.w500,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.primaryMuscleGroup ?? 'Other',
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Chart icon
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: HevyColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                color: HevyColors.textSecondary,
                size: DesignTokens.iconSmall, // 16dp (closest to 18)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
