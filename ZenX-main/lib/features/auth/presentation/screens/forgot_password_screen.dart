import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Forgot password screen (Hevy style)
class ForgotPasswordScreen extends BaseScreen {
  const ForgotPasswordScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Reset Password',
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: DesignTokens.spacingXXL),
            // Title
            Text(
              'Forgot Password?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              'Enter your email and we\'ll send you a link to reset your password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spacingXXXL),
            
            // Email field
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: DesignTokens.spacingXL),
            
            // Send reset link button
            ElevatedButton(
              onPressed: () {
                // TODO: Send reset link
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset link sent to your email'),
                  ),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.paddingButtonVertical,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Reset Link'),
            ),
            const SizedBox(height: DesignTokens.spacingM),
            
            // Back to login
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
