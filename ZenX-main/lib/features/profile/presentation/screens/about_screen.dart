import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// About screen (Hevy style)
class AboutScreen extends BaseScreen {
  const AboutScreen({super.key});

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
        'About',
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
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
      children: [
        // App info
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: HevyColors.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: DesignTokens.iconXLarge, // 48dp
                  color: HevyColors.textPrimary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                'ZenX',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: DesignTokens.spacingXXS),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(height: DesignTokens.spacingXL),

        // Description
        Card(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About ZenX',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Text(
                  'ZenX is a comprehensive fitness tracking application inspired by Hevy. Track your workouts, monitor your progress, and achieve your fitness goals.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: DesignTokens.spacingL),

        // Links
        Card(
          child: Column(
            children: [
              _AboutListTile(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip,
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              const Divider(),
              _AboutListTile(
                title: 'Terms of Service',
                icon: Icons.description,
                onTap: () {
                  // TODO: Open terms
                },
              ),
              const Divider(),
              _AboutListTile(
                title: 'Contact Support',
                icon: Icons.support,
                onTap: () {
                  // TODO: Open support
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// About list tile
class _AboutListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AboutListTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
