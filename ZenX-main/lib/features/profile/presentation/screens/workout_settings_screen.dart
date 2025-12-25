import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Workout Settings screen (Hevy style)
class WorkoutSettingsScreen extends BaseScreen {
  const WorkoutSettingsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Workout Settings'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Done',
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
    // Mock state - in real app, this would come from state management
    // bool warmupCalculatorEnabled = false; // TODO: Use when implementing warmup calculator
    bool keepAwakeEnabled = false;
    bool plateCalculatorEnabled = true;
    bool rpeTrackingEnabled = false;
    bool smartSupersetScrollingEnabled = false;
    bool inlineTimerEnabled = true;
    bool livePRNotificationEnabled = true;

    return ListView(
      children: [
        // Sounds
        _SettingsListItem(
          icon: Icons.volume_up,
          title: 'Sounds',
          onTap: () => context.push('/profile/sounds-settings'),
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Default Rest Timer
        _SettingsListItem(
          icon: Icons.timer,
          title: 'Default Rest Timer',
          subtitle: 'Off',
          onTap: () {
            // TODO: Show rest timer picker
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Previous Workout Values
        _SettingsListItem(
          icon: Icons.history,
          title: 'Previous Workout Values',
          subtitle: 'Default',
          onTap: () {
            // TODO: Show previous workout values options
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Warm-up Calculator
        _SettingsListItem(
          icon: Icons.calculate,
          title: 'Warm-up Calculator',
          subtitle: 'Off',
          onTap: () {
            // TODO: Show warm-up calculator options
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Warm-up Sets
        _SettingsListItem(
          icon: Icons.fitness_center,
          title: 'Warm-up Sets',
          onTap: () {
            // TODO: Show warm-up sets options
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Keep Awake During Workout
        _SettingsToggleItem(
          icon: Icons.phone_android,
          title: 'Keep Awake During Workout',
          description: 'Enable this if you don\'t want your phone to sleep while you\'re in a workout',
          value: keepAwakeEnabled,
          onChanged: (value) {
            // TODO: Update setting
            keepAwakeEnabled = value;
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Plate Calculator
        _SettingsToggleItem(
          icon: Icons.calculate,
          title: 'Plate Calculator',
          description: 'A plate calculator calculates the plates needed on a bar to achieve a specific weight. When enabled, a Calculator button will appear when inputting weight for barbell exercises.',
          value: plateCalculatorEnabled,
          onChanged: (value) {
            // TODO: Update setting
            plateCalculatorEnabled = value;
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // RPE Tracking
        _SettingsToggleItem(
          icon: Icons.linear_scale,
          title: 'RPE Tracking',
          description: 'RPE (Rated Perceived Exertion) is a measure of the intensity an exercise. Enabling RPE tracking will allow you to log it for each set in your workouts.',
          value: rpeTrackingEnabled,
          onChanged: (value) {
            // TODO: Update setting
            rpeTrackingEnabled = value;
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Smart Superset Scrolling
        _SettingsToggleItem(
          icon: Icons.swap_vert,
          title: 'Smart Superset Scrolling',
          description: 'When you complete a set, it\'ll automatically scroll to the next exercise in the superset.',
          value: smartSupersetScrollingEnabled,
          onChanged: (value) {
            // TODO: Update setting
            smartSupersetScrollingEnabled = value;
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Inline Timer
        _SettingsToggleItem(
          icon: Icons.timer,
          title: 'Inline Timer',
          description: 'Duration exercises have a built-in stopwatch for tracking time for each set',
          value: inlineTimerEnabled,
          onChanged: (value) {
            // TODO: Update setting
            inlineTimerEnabled = value;
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Live Personal Record Notification
        _SettingsToggleItem(
          icon: Icons.notifications_active,
          title: 'Live Personal Record Notification',
          description: 'When enabled, it\'ll notify you when you achieve a Personal Record upon checking the set.',
          value: livePRNotificationEnabled,
          onChanged: (value) {
            // TODO: Update setting
            livePRNotificationEnabled = value;
          },
        ),
        const SizedBox(height: DesignTokens.spacingL),
      ],
    );
  }
}

class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HevyColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: HevyColors.textPrimary,
          fontSize: DesignTokens.bodyLarge,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: HevyColors.textSecondary,
                fontSize: DesignTokens.bodySmall,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: HevyColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HevyColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: HevyColors.textPrimary,
          fontSize: DesignTokens.bodyLarge,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          color: HevyColors.textSecondary,
          fontSize: DesignTokens.bodySmall,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: HevyColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.paddingScreen,
        vertical: DesignTokens.spacingXS,
      ),
    );
  }
}

