import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Equipment selection screen (Hevy style)
class SelectEquipmentScreen extends BaseScreen {
  const SelectEquipmentScreen({super.key});

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
    const selectedEquipment = 'All Equipment'; // In real app, this would come from state

    final equipmentList = [
      _EquipmentItem(name: 'All Equipment', icon: Icons.grid_view, isSelected: selectedEquipment == 'All Equipment'),
      _EquipmentItem(name: 'None', icon: Icons.person_outline, isSelected: selectedEquipment == 'None'),
      _EquipmentItem(name: 'Barbell', icon: Icons.fitness_center, isSelected: selectedEquipment == 'Barbell'),
      _EquipmentItem(name: 'Dumbbell', icon: Icons.sports_gymnastics, isSelected: selectedEquipment == 'Dumbbell'),
      _EquipmentItem(name: 'Kettlebell', icon: Icons.sports_handball, isSelected: selectedEquipment == 'Kettlebell'),
      _EquipmentItem(name: 'Machine', icon: Icons.settings_applications, isSelected: selectedEquipment == 'Machine'),
      _EquipmentItem(name: 'Plate', icon: Icons.circle, isSelected: selectedEquipment == 'Plate'),
      _EquipmentItem(name: 'Resistance Band', icon: Icons.cable, isSelected: selectedEquipment == 'Resistance Band'),
      _EquipmentItem(name: 'Suspension Band', icon: Icons.horizontal_rule, isSelected: selectedEquipment == 'Suspension Band'),
      _EquipmentItem(name: 'Other', icon: Icons.more_horiz, isSelected: selectedEquipment == 'Other'),
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
              'Equipment',
              style: TextStyle(
                fontSize: DesignTokens.bodyMedium,
                fontWeight: FontWeight.w600,
                color: HevyColors.textPrimary,
              ),
            ),
          ),
        ),

        // Equipment list
        Expanded(
          child: ListView.builder(
            itemCount: equipmentList.length,
            itemBuilder: (context, index) {
              final equipment = equipmentList[index];
              return _EquipmentListItem(
                equipment: equipment,
                onTap: () {
                  // TODO: Update selected equipment filter
                  context.pop(equipment.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EquipmentItem {
  final String name;
  final IconData icon;
  final bool isSelected;

  _EquipmentItem({
    required this.name,
    required this.icon,
    required this.isSelected,
  });
}

class _EquipmentListItem extends StatelessWidget {
  final _EquipmentItem equipment;
  final VoidCallback onTap;

  const _EquipmentListItem({
    required this.equipment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingScreen,
          vertical: DesignTokens.spacingS,
        ),
        child: Row(
          children: [
            // Equipment icon
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: HevyColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                equipment.icon,
                color: HevyColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            // Equipment name
            Expanded(
              child: Text(
                equipment.name,
                style: const TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  color: HevyColors.textPrimary,
                ),
              ),
            ),
            // Selection indicator
            if (equipment.isSelected)
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

