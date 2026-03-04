import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Muscle group selection screen (Hevy style)
class SelectMuscleScreen extends BaseScreen {
  const SelectMuscleScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: TextButton(
        onPressed: () => context.pop(),
        child: const Text(
          'Cancel',
          style: TextStyle(color: HevyColors.primary),
        ),
      ),
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
            // TODO: Create exercise
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

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    const selectedMuscle = 'All Muscles'; // In real app, this would come from state

    final muscleList = [
      _MuscleItem(name: 'All Muscles', iconAsset: 'grid', isSelected: selectedMuscle == 'All Muscles'),
      _MuscleItem(name: 'Abdominals', iconAsset: 'abdominals', isSelected: selectedMuscle == 'Abdominals'),
      _MuscleItem(name: 'Abductors', iconAsset: 'abductors', isSelected: selectedMuscle == 'Abductors'),
      _MuscleItem(name: 'Adductors', iconAsset: 'adductors', isSelected: selectedMuscle == 'Adductors'),
      _MuscleItem(name: 'Biceps', iconAsset: 'biceps', isSelected: selectedMuscle == 'Biceps'),
      _MuscleItem(name: 'Calves', iconAsset: 'calves', isSelected: selectedMuscle == 'Calves'),
      _MuscleItem(name: 'Cardio', iconAsset: 'cardio', isSelected: selectedMuscle == 'Cardio'),
      _MuscleItem(name: 'Chest', iconAsset: 'chest', isSelected: selectedMuscle == 'Chest'),
      _MuscleItem(name: 'Forearms', iconAsset: 'forearms', isSelected: selectedMuscle == 'Forearms'),
      _MuscleItem(name: 'Full Body', iconAsset: 'full_body', isSelected: selectedMuscle == 'Full Body'),
      _MuscleItem(name: 'Glutes', iconAsset: 'glutes', isSelected: selectedMuscle == 'Glutes'),
      _MuscleItem(name: 'Hamstrings', iconAsset: 'hamstrings', isSelected: selectedMuscle == 'Hamstrings'),
      _MuscleItem(name: 'Lats', iconAsset: 'lats', isSelected: selectedMuscle == 'Lats'),
      _MuscleItem(name: 'Lower Back', iconAsset: 'lower_back', isSelected: selectedMuscle == 'Lower Back'),
      _MuscleItem(name: 'Neck', iconAsset: 'neck', isSelected: selectedMuscle == 'Neck'),
      _MuscleItem(name: 'Quadriceps', iconAsset: 'quadriceps', isSelected: selectedMuscle == 'Quadriceps'),
      _MuscleItem(name: 'Shoulders', iconAsset: 'shoulders', isSelected: selectedMuscle == 'Shoulders'),
      _MuscleItem(name: 'Traps', iconAsset: 'traps', isSelected: selectedMuscle == 'Traps'),
      _MuscleItem(name: 'Triceps', iconAsset: 'triceps', isSelected: selectedMuscle == 'Triceps'),
      _MuscleItem(name: 'Upper Back', iconAsset: 'upper_back', isSelected: selectedMuscle == 'Upper Back'),
      _MuscleItem(name: 'Other', iconAsset: 'other', isSelected: selectedMuscle == 'Other'),
    ];

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search exercise',
              hintStyle: const TextStyle(color: HevyColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: HevyColors.textSecondary,
              ),
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
          ),
        ),

        // Divider and section header
        const Divider(color: HevyColors.border, height: 1),
        const Padding(
          padding: EdgeInsets.all(DesignTokens.paddingScreen),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Muscle Group',
              style: TextStyle(
                fontSize: DesignTokens.bodyMedium,
                fontWeight: FontWeight.w600,
                color: HevyColors.textPrimary,
              ),
            ),
          ),
        ),

        // Muscle list
        Expanded(
          child: ListView.builder(
            itemCount: muscleList.length,
            itemBuilder: (context, index) {
              final muscle = muscleList[index];
              return _MuscleListItem(
                muscle: muscle,
                onTap: () {
                  // TODO: Update selected muscle filter
                  context.pop(muscle.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MuscleItem {
  final String name;
  final String iconAsset;
  final bool isSelected;

  _MuscleItem({
    required this.name,
    required this.iconAsset,
    required this.isSelected,
  });
}

class _MuscleListItem extends StatelessWidget {
  final _MuscleItem muscle;
  final VoidCallback onTap;

  const _MuscleListItem({
    required this.muscle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine icon based on muscle name
    IconData icon = Icons.fitness_center;
    if (muscle.iconAsset == 'grid') {
      icon = Icons.grid_view;
    } else if (muscle.name == 'Cardio') {
      icon = Icons.directions_run;
    } else if (muscle.name == 'Full Body') {
      icon = Icons.person;
    } else if (muscle.name == 'Other') {
      icon = Icons.more_horiz;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingScreen,
          vertical: DesignTokens.spacingS,
        ),
        child: Row(
          children: [
            // Muscle icon (placeholder - in real app would show anatomical diagram)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: HevyColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: HevyColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            // Muscle name
            Expanded(
              child: Text(
                muscle.name,
                style: const TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  color: HevyColors.textPrimary,
                ),
              ),
            ),
            // Selection indicator
            if (muscle.isSelected)
              const Icon(
                Icons.check,
                color: HevyColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

