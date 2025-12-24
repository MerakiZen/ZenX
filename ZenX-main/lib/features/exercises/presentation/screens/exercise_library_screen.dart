import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/presentation/widgets/loading_widget.dart';
import '../providers/exercise_providers.dart';
import '../../domain/entities/exercise.dart';

/// Exercise library screen with search and categories (Hevy style)
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, ref),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      title: const Text(
        'Exercise Library',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          color: HevyColors.textPrimary,
          onPressed: () {
            context.push('/exercises/create');
          },
          tooltip: 'Create Custom Exercise',
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
              hintText: 'Search exercises...',
              hintStyle: TextStyle(color: HevyColors.textTertiary),
              prefixIcon: Icon(Icons.search, color: HevyColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: HevyColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.filter_list, color: HevyColors.textSecondary),
                      onPressed: () {
                        // TODO: Show filter dialog
                      },
                    ),
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
            ),
            style: TextStyle(color: HevyColors.textPrimary),
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
              _CategoryChip(
                label: 'All',
                isSelected: _selectedCategory == 'All',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'All';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Chest',
                isSelected: _selectedCategory == 'Chest',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Chest';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Back',
                isSelected: _selectedCategory == 'Back',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Back';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Legs',
                isSelected: _selectedCategory == 'Legs',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Legs';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Shoulders',
                isSelected: _selectedCategory == 'Shoulders',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Shoulders';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Arms',
                isSelected: _selectedCategory == 'Arms',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Arms';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Core',
                isSelected: _selectedCategory == 'Core',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Core';
                  });
                },
              ),
              const SizedBox(width: DesignTokens.spacingXS),
              _CategoryChip(
                label: 'Cardio',
                isSelected: _selectedCategory == 'Cardio',
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = 'Cardio';
                  });
                },
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Exercise list
        Expanded(
          child: _ExerciseList(
            searchQuery: _searchQuery,
            category: _selectedCategory == 'All' ? null : _selectedCategory,
          ),
        ),
      ],
    );
  }
}

/// Category chip widget
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

/// Exercise list widget
class _ExerciseList extends ConsumerWidget {
  final String searchQuery;
  final String? category;

  const _ExerciseList({
    required this.searchQuery,
    this.category,
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
                Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: HevyColors.textTertiary,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Text(
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
                  style: TextStyle(
                    color: HevyColors.textTertiary,
                    fontSize: DesignTokens.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _ExerciseCard(
              exercise: exercise,
              onTap: () {
                context.push('/exercises/${exercise.id}');
              },
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: HevyColors.error,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
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

/// Exercise card widget
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  Color _getCategoryColor(String? category) {
    if (category == null) return HevyColors.textTertiary;
    switch (category.toLowerCase()) {
      case 'chest':
        return HevyColors.categoryChest;
      case 'back':
        return HevyColors.categoryBack;
      case 'legs':
        return HevyColors.categoryLegs;
      case 'shoulders':
        return HevyColors.categoryShoulders;
      case 'arms':
        return HevyColors.categoryArms;
      case 'core':
        return HevyColors.categoryCore;
      default:
        return HevyColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(exercise.category);
    final muscleGroup = exercise.primaryMuscleGroup ?? 'Unknown';
    final equipment = exercise.equipmentRequired ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      color: HevyColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        side: BorderSide(color: HevyColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Row(
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: HevyColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXXS),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: DesignTokens.iconSmall,
                          color: HevyColors.textSecondary,
                        ),
                        const SizedBox(width: DesignTokens.spacingXXS),
                        Text(
                          muscleGroup,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: HevyColors.textSecondary,
                              ),
                        ),
                        const SizedBox(width: DesignTokens.spacingS),
                        Icon(
                          Icons.sports_gymnastics,
                          size: DesignTokens.iconSmall,
                          color: HevyColors.textSecondary,
                        ),
                        const SizedBox(width: DesignTokens.spacingXXS),
                        Text(
                          equipment,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: HevyColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: HevyColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
