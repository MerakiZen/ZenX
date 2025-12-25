import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Volume analysis screen (Hevy style)
class VolumeAnalysisScreen extends BaseScreen {
  const VolumeAnalysisScreen({super.key});

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
        'Volume Analysis',
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
    // Realistic deployment mock data
    final weeklyVolume = [
      {'week': 'Week 1', 'volume': 12500.0},
      {'week': 'Week 2', 'volume': 15200.0},
      {'week': 'Week 3', 'volume': 13800.0},
      {'week': 'Week 4', 'volume': 16900.0},
    ];
    
    final totalVolume = weeklyVolume.fold<double>(0, (sum, week) => sum + (week['volume'] as double));
    final avgVolume = totalVolume / weeklyVolume.length;

    return CustomScrollView(
      slivers: [
        // Summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Month',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _VolumeStatCard(
                        label: 'Total Volume',
                        value: '${(totalVolume / 1000).toStringAsFixed(0)}k kg',
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: _VolumeStatCard(
                        label: 'Average',
                        value: '${(avgVolume / 1000).toStringAsFixed(1)}k kg',
                        icon: Icons.bar_chart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Card(
              child: Container(
                height: 250,
                padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume Over Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingM),
                    Expanded(
                      child: _VolumeChart(weeklyVolume: weeklyVolume),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Weekly breakdown
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
            ),
            child: Text(
              'Weekly Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final week = weeklyVolume[index];
              return _VolumeWeekCard(
                week: week['week'] as String,
                volume: week['volume'] as double,
              );
            },
            childCount: weeklyVolume.length,
          ),
        ),
      ],
    );
  }
}

/// Volume stat card
class _VolumeStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _VolumeStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: HevyColors.primary,
              size: DesignTokens.iconMedium, // 24dp
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: HevyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: DesignTokens.spacingXXS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Volume week card
class _VolumeWeekCard extends StatelessWidget {
  final String week;
  final double volume;

  const _VolumeWeekCard({
    required this.week,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.paddingScreen,
        vertical: DesignTokens.spacingXS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              week,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${(volume / 1000).toStringAsFixed(1)}k kg',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HevyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Volume chart widget
class _VolumeChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyVolume;

  const _VolumeChart({required this.weeklyVolume});

  @override
  Widget build(BuildContext context) {
    final maxVolume = weeklyVolume.map((w) => w['volume'] as double).reduce((a, b) => a > b ? a : b) * 1.1;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weeklyVolume.asMap().entries.map((entry) {
        final week = entry.value;
        final volume = week['volume'] as double;
        final heightFactor = (volume / maxVolume).clamp(0.0, 1.0);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: heightFactor,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: HevyColors.primary,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  week['week'] as String,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HevyColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(volume / 1000).toStringAsFixed(1)}k',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: HevyColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
