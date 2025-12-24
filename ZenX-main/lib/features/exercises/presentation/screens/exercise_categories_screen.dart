import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Exercise categories screen (Hevy style)
class ExerciseCategoriesScreen extends BaseScreen {
  const ExerciseCategoriesScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      title: const Text(
        'Exercise Categories',
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
    final categories = [
      _Category(
        name: 'Chest',
        icon: Icons.fitness_center,
        color: HevyColors.categoryChest,
        count: 15,
      ),
      _Category(
        name: 'Back',
        icon: Icons.fitness_center,
        color: HevyColors.categoryBack,
        count: 20,
      ),
      _Category(
        name: 'Legs',
        icon: Icons.directions_walk,
        color: HevyColors.categoryLegs,
        count: 18,
      ),
      _Category(
        name: 'Shoulders',
        icon: Icons.fitness_center,
        color: HevyColors.categoryShoulders,
        count: 12,
      ),
      _Category(
        name: 'Arms',
        icon: Icons.fitness_center,
        color: HevyColors.categoryArms,
        count: 16,
      ),
      _Category(
        name: 'Core',
        icon: Icons.fitness_center,
        color: HevyColors.categoryCore,
        count: 14,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DesignTokens.spacingM,
        mainAxisSpacing: DesignTokens.spacingM,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () {
            // TODO: Filter exercises by category
            context.pop();
          },
        );
      },
    );
  }
}

/// Category model
class _Category {
  final String name;
  final IconData icon;
  final Color color;
  final int count;

  _Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });
}

/// Category card widget
class _CategoryCard extends StatelessWidget {
  final _Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: DesignTokens.iconLarge, // 32dp
                ),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DesignTokens.spacingXXS),
              Text(
                '${category.count} exercises',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
