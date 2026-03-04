import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';
import '../providers/exercise_providers.dart';
import '../../domain/models/exercise.dart';

/// Add Exercise screen (Hevy style)
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

        // Category chips
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            children: [
              'All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio'
            ].map((cat) => Padding(
              padding: const EdgeInsets.only(right: DesignTokens.spacingXS),
              child: _CategoryChip(
                label: cat,
                isSelected: _selectedCategory == cat,
                onSelected: (selected) => setState(() => _selectedCategory = cat),
              ),
            )).toList(),
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
               context.pop({
                 'name': exercise.name,
                 'muscleGroup': exercise.primaryMuscleGroup ?? 'Other',
                 'exerciseId': exercise.id,
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
          color: isSelected ? Colors.white : HevyColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: HevyColors.primary,
      checkmarkColor: Colors.white,
      backgroundColor: HevyColors.surfaceElevated,
      side: BorderSide(
        color: isSelected ? HevyColors.primary : HevyColors.border,
        width: 1,
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
            : ref.watch(exercisesProvider(query: null, category: null));

    return exercisesAsync.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return const Center(
            child: Text(
              'No exercises found',
              style: TextStyle(color: HevyColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
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
      error: (error, stack) => Center(child: Text('Error: $error')),
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
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: HevyColors.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.fitness_center, color: HevyColors.primary),
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(
          color: HevyColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        exercise.primaryMuscleGroup ?? 'Other',
        style: const TextStyle(color: HevyColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: HevyColors.textTertiary),
    );
  }
}
