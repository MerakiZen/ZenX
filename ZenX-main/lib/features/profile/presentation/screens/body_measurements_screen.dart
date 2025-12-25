import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../providers/profile_providers.dart';

/// Body measurements screen (Hevy style)
class BodyMeasurementsScreen extends BaseScreen {
  const BodyMeasurementsScreen({super.key});

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
        'Body Measurements',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          color: HevyColors.textPrimary,
          onPressed: () {
            context.push('/profile/measurements/add');
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(profileViewProvider);

    return profileData.when(
      data: (data) {
        final measurements = data.measurements;
        final latest = measurements.isNotEmpty ? measurements.last : null;

        return ListView(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          children: [
            // Current stats
            if (latest != null)
              Card(
                color: HevyColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                  child: Column(
                    children: [
                      Text(
                        'Current',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: HevyColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: DesignTokens.spacingM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (latest.weightKg != null)
                            _StatItem(
                              label: 'Weight',
                              value: '${latest.weightKg!.toStringAsFixed(1)} kg',
                              icon: Icons.monitor_weight,
                            ),
                          if (latest.bodyFatPercentage != null)
                            _StatItem(
                              label: 'Body Fat',
                              value: '${latest.bodyFatPercentage!.toStringAsFixed(1)}%',
                              icon: Icons.percent,
                            ),
                          if (latest.muscleMassKg != null)
                            _StatItem(
                              label: 'Muscle Mass',
                              value: '${latest.muscleMassKg!.toStringAsFixed(1)} kg',
                              icon: Icons.fitness_center,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: DesignTokens.spacingXL),

            // History
            Text(
              'History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HevyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: DesignTokens.spacingM),
            if (measurements.isEmpty)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 64,
                        color: HevyColors.textTertiary,
                      ),
                      const SizedBox(height: DesignTokens.spacingM),
                      Text(
                        'No measurements yet',
                        style: TextStyle(color: HevyColors.textSecondary),
                      ),
                      const SizedBox(height: DesignTokens.spacingS),
                      Text(
                        'Tap + to add your first measurement',
                        style: TextStyle(color: HevyColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...measurements.reversed.map((measurement) {
                return Card(
                  margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                  color: HevyColors.surface,
                  child: ListTile(
                    title: Text(
                      _formatDate(measurement.measurementDate),
                      style: TextStyle(
                        color: HevyColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (measurement.weightKg != null)
                          Text(
                            'Weight: ${measurement.weightKg!.toStringAsFixed(1)} kg',
                            style: TextStyle(color: HevyColors.textSecondary),
                          ),
                        if (measurement.bodyFatPercentage != null)
                          Text(
                            'Body Fat: ${measurement.bodyFatPercentage!.toStringAsFixed(1)}%',
                            style: TextStyle(color: HevyColors.textSecondary),
                          ),
                        if (measurement.muscleMassKg != null)
                          Text(
                            'Muscle Mass: ${measurement.muscleMassKg!.toStringAsFixed(1)} kg',
                            style: TextStyle(color: HevyColors.textSecondary),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: HevyColors.textTertiary,
                    ),
                    onTap: () {
                      // TODO: View/edit measurement
                    },
                  ),
                );
              }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: HevyColors.error,
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                'Error loading measurements',
                style: TextStyle(color: HevyColors.error),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              ElevatedButton(
                onPressed: () => ref.refresh(profileViewProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Stat item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: HevyColors.primary,
          size: DesignTokens.iconMedium,
        ),
        const SizedBox(height: DesignTokens.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: HevyColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HevyColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
