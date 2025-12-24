import 'package:flutter/material.dart';
import '../design/design_tokens.dart';
import '../design/hevy_colors.dart';

/// Helper class for showing help dialogs across the app
class HelpDialogHelper {
  HelpDialogHelper._();

  /// Show a help dialog with title and content
  static void showHelpDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HevyColors.surface,
        title: Text(
          title,
          style: const TextStyle(
            color: HevyColors.textPrimary,
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: HevyColors.textSecondary,
            fontSize: DesignTokens.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: HevyColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Show muscle distribution help
  static void showMuscleDistributionHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Muscle Distribution Chart',
      content: 'This radar chart shows how your workouts are distributed across different muscle groups. The blue area represents your current period, and the grey area shows the previous period for comparison.',
    );
  }

  /// Show statistics help
  static void showStatisticsHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Statistics',
      content: 'View detailed statistics about your workouts, including body graphs, muscle distribution, set counts, and exercise analytics.',
    );
  }

  /// Show leaderboard exercises help
  static void showLeaderboardExercisesHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Leaderboard Exercises',
      content: 'These are exercises that are eligible for leaderboard rankings. Compare your performance with other users and track your progress on these standardized exercises.',
    );
  }

  /// Show set count per muscle help
  static void showSetCountPerMuscleHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Set Count per Muscle Group',
      content: 'This shows the total number of sets performed for each muscle group during the selected time period. Use this to identify imbalances in your training.',
    );
  }

  /// Show body distribution help
  static void showBodyDistributionHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Body Distribution',
      content: 'This weekly heat map shows which muscles you worked on each day. The darker colors indicate more sets performed for that muscle group.',
    );
  }

  /// Show calendar help
  static void showCalendarHelp(BuildContext context) {
    showHelpDialog(
      context,
      title: 'Workout Calendar',
      content: 'View your workout history on a calendar. Days with workouts are marked with circles and show the workout type. Track your consistency and plan your training schedule.',
    );
  }
}

