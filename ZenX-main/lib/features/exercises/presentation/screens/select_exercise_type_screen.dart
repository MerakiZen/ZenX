import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Exercise type selection screen (Hevy style)
class SelectExerciseTypeScreen extends BaseScreen {
  const SelectExerciseTypeScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Select Exercise Type'),
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
    final exerciseTypes = [
      _ExerciseType(
        name: 'Weight & Reps',
        example: 'Bench Press, Dumbbell Curls',
        inputs: ['REPS', 'KG'],
      ),
      _ExerciseType(
        name: 'Bodyweight Reps',
        example: 'Pullups, Sit ups, Burpees',
        inputs: ['REPS'],
      ),
      _ExerciseType(
        name: 'Weighted Bodyweight',
        example: 'Weighted Pull Ups, Weighted Dips',
        inputs: ['REPS', '+KG'],
      ),
      _ExerciseType(
        name: 'Assisted Bodyweight',
        example: 'Assisted Pullups, Assisted Dips',
        inputs: ['REPS', '-KG'],
      ),
      _ExerciseType(
        name: 'Duration',
        example: 'Planks, Yoga, Stretching',
        inputs: ['TIME'],
      ),
      _ExerciseType(
        name: 'Duration & Weight',
        example: 'Weighted Plank, Wall Sit',
        inputs: ['KG', 'TIME'],
      ),
      _ExerciseType(
        name: 'Distance & Duration',
        example: 'Running, Cycling, Rowing',
        inputs: ['TIME', 'KM'],
      ),
      _ExerciseType(
        name: 'Weight & Distance',
        example: 'Farmers Walk, Suitcase Carry',
        inputs: ['KG', 'KM'],
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      itemCount: exerciseTypes.length,
      separatorBuilder: (context, index) => const Divider(
        color: HevyColors.border,
        height: 32,
      ),
      itemBuilder: (context, index) {
        final exerciseType = exerciseTypes[index];
        return InkWell(
          onTap: () {
            context.pop(exerciseType.name);
          },
          child: _ExerciseTypeItem(exerciseType: exerciseType),
        );
      },
    );
  }
}

class _ExerciseType {
  final String name;
  final String example;
  final List<String> inputs;

  _ExerciseType({
    required this.name,
    required this.example,
    required this.inputs,
  });
}

class _ExerciseTypeItem extends StatelessWidget {
  final _ExerciseType exerciseType;

  const _ExerciseTypeItem({required this.exerciseType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exerciseType.name,
          style: const TextStyle(
            fontSize: DesignTokens.bodyLarge,
            fontWeight: FontWeight.w600,
            color: HevyColors.textPrimary,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          exerciseType.example,
          style: const TextStyle(
            fontSize: DesignTokens.bodySmall,
            color: HevyColors.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingS),
        Wrap(
          spacing: DesignTokens.spacingXS,
          children: exerciseType.inputs.map((input) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingM,
                vertical: DesignTokens.spacingXS,
              ),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Text(
                input,
                style: const TextStyle(
                  fontSize: DesignTokens.bodySmall,
                  color: HevyColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

