import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import '../providers/analytics_providers.dart';

final distributionRangeProvider = StateProvider.autoDispose<String>((ref) => 'Last 30 days');

/// Muscle distribution screen with radar chart (Hevy style)
class MuscleDistributionScreen extends BaseScreen {
  const MuscleDistributionScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Muscle distribution'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: HevyColors.textPrimary,
          onPressed: () {
            HelpDialogHelper.showMuscleDistributionHelp(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.upload),
          color: HevyColors.textPrimary,
          onPressed: () async {
            final shareService = ShareService();
            await shareService.shareReport(
              reportTitle: 'Muscle Distribution',
              reportContent: 'View my muscle distribution statistics on ZenX',
            );
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final selectedDateRange = ref.watch(distributionRangeProvider);
    
    final now = DateTime.now();
    DateTime start;
    switch (selectedDateRange) {
      case 'Last 7 days': start = now.subtract(const Duration(days: 7)); break;
      case 'Last 30 days': start = now.subtract(const Duration(days: 30)); break;
      case 'Last 3 months': start = now.subtract(const Duration(days: 90)); break;
      case 'Last year': start = now.subtract(const Duration(days: 365)); break;
      case 'All time': start = DateTime(2000); break;
      default: start = now.subtract(const Duration(days: 30));
    }

    final statsAsync = ref.watch(muscleGroupStatsProvider(startDate: start, endDate: now));
    final calendarAsync = ref.watch(workoutCalendarProvider(startDate: start, endDate: now));

    return statsAsync.when(
      data: (stats) {
        // Normalize data for radar chart (0.0 to 1.0)
        final maxVolume = stats.fold(0.0, (max, s) => s.volume > max ? s.volume : max);
        final currentData = <String, double>{};
        
        // Map specific muscles to broad categories for radar chart
        final categories = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];
        for (var cat in categories) {
          currentData[cat] = 0.0;
        }
        
        double totalVolume = 0;
        int totalSets = 0;

        for (var s in stats) {
          totalVolume += s.volume;
          totalSets += s.setCount;

          // Simple mapping logic
          String cat = 'Other';
          if (s.muscleGroup.contains('Back') || s.muscleGroup == 'Lats' || s.muscleGroup == 'Traps') cat = 'Back';
          else if (s.muscleGroup.contains('Chest')) cat = 'Chest';
          else if (s.muscleGroup.contains('Abs') || s.muscleGroup == 'Core') cat = 'Core';
          else if (s.muscleGroup.contains('Shoulder')) cat = 'Shoulders';
          else if (s.muscleGroup.contains('Bicep') || s.muscleGroup.contains('Tricep') || s.muscleGroup == 'Forearms') cat = 'Arms';
          else if (s.muscleGroup.contains('Leg') || s.muscleGroup.contains('Calf') || s.muscleGroup.contains('Glute') || s.muscleGroup == 'Quads' || s.muscleGroup == 'Hamstrings') cat = 'Legs';
          
          if (currentData.containsKey(cat)) {
            currentData[cat] = (currentData[cat] ?? 0) + s.volume;
          }
        }
        
        // Normalize
        if (maxVolume > 0) {
          currentData.forEach((key, value) {
            currentData[key] = value / maxVolume;
            // Cap at 1.0 just in case
            if (currentData[key]! > 1.0) currentData[key] = 1.0;
          });
        }

        // For previous period comparison, we'd need to fetch data for the previous time period
        // For now, showing empty previous data (can be enhanced to query previous period)
        final previousData = <String, double>{
          'Back': 0.0, 'Chest': 0.0, 'Core': 0.0, 'Shoulders': 0.0, 'Arms': 0.0, 'Legs': 0.0,
        };

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              Padding(
                padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                child: _FilterButton(
                  label: selectedDateRange,
                  onTap: () => _showRangePicker(context, ref, selectedDateRange),
                ),
              ),

              // Radar chart with black background
              Container(
                height: 350,
                margin: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                ),
                child: CustomPaint(
                  painter: _RadarChartPainter(
                    currentData: currentData,
                    previousData: previousData,
                  ),
                  size: const Size(double.infinity, 350),
                ),
              ),
              
              const SizedBox(height: DesignTokens.spacingM),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: HevyColors.primary,
                      label: 'Current',
                    ),
                    const SizedBox(width: DesignTokens.spacingL),
                    _LegendItem(
                      color: HevyColors.textSecondary,
                      label: 'Previous',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.spacingXL),

              // Summary cards
              calendarAsync.when(
                data: (calendar) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Workouts',
                              value: '${calendar.totalWorkouts}',
                              change: '', // Change calculation requires previous period data
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingM),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Duration',
                              value: '--', // Duration not available in API yet
                              change: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Volume',
                              value: '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
                              change: '',
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingM),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Sets',
                              value: '$totalSets',
                              change: '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: DesignTokens.spacingXL),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showRangePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          'Last 7 days', 'Last 30 days', 'Last 3 months', 'Last year', 'All time'
        ].map((range) => ListTile(
          title: Text(range),
          trailing: range == current ? const Icon(Icons.check) : null,
          onTap: () {
            ref.read(distributionRangeProvider.notifier).state = range;
            context.pop();
          },
        )).toList(),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingM,
          vertical: DesignTokens.spacingS,
        ),
        decoration: BoxDecoration(
          color: HevyColors.surfaceElevated,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: DesignTokens.bodyMedium,
                color: HevyColors.textPrimary,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingXS),
            const Icon(
              Icons.keyboard_arrow_down,
              color: HevyColors.textSecondary,
              size: DesignTokens.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarChart extends StatelessWidget {
  final Map<String, double> currentData;
  final Map<String, double> previousData;

  const _RadarChart({
    required this.currentData,
    required this.previousData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarChartPainter(
        currentData: currentData,
        previousData: previousData,
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> currentData;
  final Map<String, double> previousData;

  _RadarChartPainter({
    required this.currentData,
    required this.previousData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.7;
    
    // Muscle groups in specific order: Back, Chest, Core, Shoulders, Arms, Legs
    final axes = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];
    final angleStep = (2 * math.pi) / axes.length;
    
    // Draw hexagonal grid lines
    final gridPaint = Paint()
      ..color = HevyColors.textSecondary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw multiple hexagonal grids
    for (int level = 1; level <= 5; level++) {
      final gridPath = Path();
      final gridRadius = radius * (level / 5);
      bool firstPoint = true;
      
      for (int i = 0; i < axes.length; i++) {
        final angle = (i * angleStep) - (math.pi / 2); // Start from top
        final x = center.dx + gridRadius * math.cos(angle);
        final y = center.dy + gridRadius * math.sin(angle);
        
        if (firstPoint) {
          gridPath.moveTo(x, y);
          firstPoint = false;
        } else {
          gridPath.lineTo(x, y);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }
    
    // Draw axes lines
    final axisPaint = Paint()
      ..color = HevyColors.textSecondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final endX = center.dx + radius * 1.15 * math.cos(angle);
      final endY = center.dy + radius * 1.15 * math.sin(angle);
      final endPoint = Offset(endX, endY);
      
      canvas.drawLine(center, endPoint, axisPaint);
      
      // Draw axis labels
      final labelRadius = radius * 1.25;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: axes[i],
          style: const TextStyle(
            color: HevyColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }
    
    // Draw previous data polygon (grey, semi-transparent)
    final previousPath = Path();
    final previousPaint = Paint()
      ..color = HevyColors.textSecondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final previousStroke = Paint()
      ..color = HevyColors.textSecondary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    bool firstPoint = true;
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final value = previousData[axes[i]] ?? 0.0;
      final distance = radius * value;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      if (firstPoint) {
        previousPath.moveTo(x, y);
        firstPoint = false;
      } else {
        previousPath.lineTo(x, y);
      }
    }
    previousPath.close();
    canvas.drawPath(previousPath, previousPaint);
    canvas.drawPath(previousPath, previousStroke);
    
    // Draw current data polygon (blue, solid)
    final currentPath = Path();
    final currentPaint = Paint()
      ..color = HevyColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final currentStroke = Paint()
      ..color = HevyColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    firstPoint = true;
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final value = currentData[axes[i]] ?? 0.0;
      final distance = radius * value;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      if (firstPoint) {
        currentPath.moveTo(x, y);
        firstPoint = false;
      } else {
        currentPath.lineTo(x, y);
      }
    }
    currentPath.close();
    canvas.drawPath(currentPath, currentPaint);
    canvas.drawPath(currentPath, currentStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DesignTokens.spacingXS),
        Text(
          label,
          style: const TextStyle(
            fontSize: DesignTokens.bodySmall,
            color: HevyColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingM),
      decoration: BoxDecoration(
        color: HevyColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: DesignTokens.titleLarge,
              fontWeight: FontWeight.bold,
              color: HevyColors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXXS),
          Text(
            change,
            style: const TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXXS),
          Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: HevyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}