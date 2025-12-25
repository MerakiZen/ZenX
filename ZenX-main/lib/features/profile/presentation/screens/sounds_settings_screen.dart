import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Sounds Settings screen (Hevy style)
class SoundsSettingsScreen extends BaseScreen {
  const SoundsSettingsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Sounds'),
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
    return ListView(
      children: [
        // Section header
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.paddingScreen,
            vertical: DesignTokens.spacingM,
          ),
          child: Text(
            'Sound Type',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              fontWeight: FontWeight.w600,
              color: HevyColors.textSecondary,
            ),
          ),
        ),

        // Timer Sound
        _SettingsListItem(
          title: 'Timer Sound',
          subtitle: 'Default',
          onTap: () {
            // TODO: Show sound picker
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Section header
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.paddingScreen,
            vertical: DesignTokens.spacingM,
          ),
          child: Text(
            'Sounds Volume',
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              fontWeight: FontWeight.w600,
              color: HevyColors.textSecondary,
            ),
          ),
        ),

        // Timer Volume
        _SettingsListItem(
          title: 'Timer Volume',
          subtitle: 'High',
          onTap: () {
            // TODO: Show volume picker
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Check Set
        _SettingsListItem(
          title: 'Check Set',
          subtitle: 'Off',
          onTap: () {
            // TODO: Show check set sound options
          },
        ),
        const Divider(color: HevyColors.border, height: 1),

        // Live Personal Record Volume
        _SettingsListItem(
          title: 'Live Personal Record Volume',
          subtitle: 'High',
          onTap: () {
            // TODO: Show volume picker
          },
        ),
        const SizedBox(height: DesignTokens.spacingL),
      ],
    );
  }
}

class _SettingsListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                color: HevyColors.textSecondary,
                fontSize: DesignTokens.bodyMedium,
              ),
            ),
          const SizedBox(width: DesignTokens.spacingXS),
          const Icon(
            Icons.chevron_right,
            color: HevyColors.textSecondary,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

