import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/hevy_colors.dart';
import '../design/design_tokens.dart';

/// Base screen widget with common functionality
abstract class BaseScreen extends ConsumerWidget {
  const BaseScreen({super.key});

  /// Build the screen content
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(context, ref),
      body: buildBody(context, ref),
      bottomNavigationBar: buildBottomNavigationBar(context, ref),
      floatingActionButton: buildFloatingActionButton(context, ref),
    );
  }

  /// Build the app bar (override if needed)
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Build the main body content
  Widget buildBody(BuildContext context, WidgetRef ref);

  /// Build bottom navigation bar (override if needed)
  Widget? buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Build floating action button (override if needed)
  Widget? buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return null;
  }

  /// Show loading indicator
  void showLoading(BuildContext context) {
    // TODO: Implement loading overlay
  }

  /// Hide loading indicator
  void hideLoading(BuildContext context) {
    // TODO: Implement loading overlay
  }

  /// Show error message
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: HevyColors.textPrimary,
            fontSize: DesignTokens.bodyMedium,
          ),
        ),
        backgroundColor: HevyColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
    );
  }

  /// Show success message
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: HevyColors.textPrimary,
            fontSize: DesignTokens.bodyMedium,
          ),
        ),
        backgroundColor: HevyColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
    );
  }
}

