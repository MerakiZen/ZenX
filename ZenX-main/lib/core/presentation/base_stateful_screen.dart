import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/hevy_colors.dart';
import '../design/design_tokens.dart';

/// Base stateful screen widget with common functionality
abstract class BaseStatefulScreen extends ConsumerStatefulWidget {
  const BaseStatefulScreen({super.key});
}

abstract class BaseStatefulScreenState<T extends BaseStatefulScreen>
    extends ConsumerState<T> {
  /// Show loading indicator
  void showLoading() {
    // TODO: Implement loading overlay
  }

  /// Hide loading indicator
  void hideLoading() {
    // TODO: Implement loading overlay
  }

  /// Show error message
  void showError(String message) {
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
  void showSuccess(String message) {
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

  /// Navigate to a route
  void navigateTo(String route, {Object? arguments}) {
    // TODO: Implement navigation using go_router
  }

  /// Navigate back
  void navigateBack() {
    Navigator.of(context).pop();
  }
}

