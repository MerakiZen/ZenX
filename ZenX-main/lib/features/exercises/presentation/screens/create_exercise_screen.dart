import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Create custom exercise screen (Hevy style)
class CreateExerciseScreen extends BaseScreen {
  const CreateExerciseScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Create Exercise'),
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
            // TODO: Save exercise
            context.pop();
          },
          child: const Text(
            'Save',
            style: TextStyle(
              color: HevyColors.primary,
              fontSize: DesignTokens.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    String? selectedEquipment;
    String? selectedPrimaryMuscle;
    String? selectedExerciseType;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add Asset section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showAddAssetModal(context);
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HevyColors.border,
                        width: 2,
                      ),
                      color: HevyColors.surfaceElevated,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                GestureDetector(
                  onTap: () {
                    _showAddAssetModal(context);
                  },
                  child: const Text(
                    'Add Asset',
                    style: TextStyle(
                      color: HevyColors.primary,
                      fontSize: DesignTokens.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Exercise Name
          const Text(
            'Exercise Name',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter exercise name',
              hintStyle: TextStyle(color: HevyColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HevyColors.border),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HevyColors.primary),
              ),
            ),
            style: TextStyle(color: HevyColors.textPrimary),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Equipment
          const Text(
            'Equipment',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          InkWell(
            onTap: () async {
              final result = await context.push('/exercises/select-equipment');
              if (result != null) {
                // TODO: Update selected equipment
                selectedEquipment = result as String?;
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedEquipment ?? 'Select',
                  style: TextStyle(
                    color: HevyColors.primary,
                    fontSize: DesignTokens.bodyLarge,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: HevyColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(color: HevyColors.border, height: 32),

          // Primary Muscle Group
          const Text(
            'Primary Muscle Group',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          InkWell(
            onTap: () async {
              final result = await context.push('/exercises/select-muscle');
              if (result != null) {
                // TODO: Update selected primary muscle
                selectedPrimaryMuscle = result as String?;
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPrimaryMuscle ?? 'Select',
                  style: TextStyle(
                    color: HevyColors.primary,
                    fontSize: DesignTokens.bodyLarge,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: HevyColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(color: HevyColors.border, height: 32),

          // Other Muscles
          const Text(
            'Other Muscles',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          InkWell(
            onTap: () async {
              await context.push('/exercises/select-secondary-muscles');
              // TODO: Handle multiple muscle selection
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select (optional)',
                  style: TextStyle(
                    color: HevyColors.primary,
                    fontSize: DesignTokens.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: HevyColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(color: HevyColors.border, height: 32),

          // Exercise Type
          const Text(
            'Exercise Type',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          InkWell(
            onTap: () async {
              final result = await context.push('/exercises/select-exercise-type');
              if (result != null) {
                // TODO: Update selected exercise type
                selectedExerciseType = result as String?;
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedExerciseType ?? 'Select',
                  style: TextStyle(
                    color: HevyColors.primary,
                    fontSize: DesignTokens.bodyLarge,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: HevyColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(color: HevyColors.border, height: 32),

          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }

  void _showAddAssetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HevyColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: HevyColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Add Asset',
              style: TextStyle(
                fontSize: DesignTokens.titleLarge,
                fontWeight: FontWeight.bold,
                color: HevyColors.textPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXS),
            const Text(
              'Select an image, video, or GIF',
              style: TextStyle(
                fontSize: DesignTokens.bodyMedium,
                color: HevyColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: HevyColors.textPrimary,
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(color: HevyColors.textPrimary),
              ),
              onTap: () {
                // TODO: Open camera
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: HevyColors.textPrimary,
              ),
              title: const Text(
                'Select Library Photo, Video or GIF',
                style: TextStyle(color: HevyColors.textPrimary),
              ),
              onTap: () {
                // TODO: Open photo library
                context.pop();
              },
            ),
            const SizedBox(height: DesignTokens.spacingM),
          ],
        ),
      ),
    );
  }
}
