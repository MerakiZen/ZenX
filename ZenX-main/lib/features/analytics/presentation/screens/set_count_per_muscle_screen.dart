import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';

/// Set count per muscle screen - Exact clone from screenshots
class SetCountPerMuscleScreen extends BaseScreen {
  const SetCountPerMuscleScreen({super.key});

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
      centerTitle: true,
      title: const Text(
        'Set count per muscle',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: HevyColors.textPrimary,
          onPressed: () {
            HelpDialogHelper.showSetCountPerMuscleHelp(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          color: HevyColors.textPrimary,
          onPressed: () async {
            final shareService = ShareService();
            await shareService.shareReport(
              reportTitle: 'Set Count per Muscle Group',
              reportContent: 'View my set count per muscle group statistics on ZenX',
            );
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    const padding = DesignTokens.paddingScreen;
    
    // Real data calculation
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final workoutsAsync = ref.watch(workoutsProvider);
    
    // UI strings
    const selectedDateRange = 'Last 30 days';
    const selectedTimeGranularity = 'Week';
    final dateFormat = DateFormat('d MMM');
    final dateRange = '${dateFormat.format(startDate)} - ${dateFormat.format(now)}';
    
    return workoutsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (workouts) {
        // Filter workouts for last 30 days
        final recentWorkouts = workouts.where((w) {
          final date = w.completedAt ?? w.createdAt;
          return date.isAfter(startDate) && date.isBefore(now.add(const Duration(days: 1)));
        }).toList();

        // Calculate total sets per muscle
        final muscleSets = <String, double>{};
        final muscleColors = {
          'Chest': Colors.blue,
          'Back': Colors.purple,
          'Legs': Colors.orange,
          'Shoulders': Colors.red,
          'Arms': Colors.yellow,
          'Core': Colors.green,
          'Cardio': Colors.cyan,
        };

        for (var w in recentWorkouts) {
          for (var e in w.exercises) {
            final muscle = e.exercise?.primaryMuscleGroup ?? 'Other';
            // Normalize muscle name
            final key = muscle.isEmpty ? 'Other' : muscle;
            // Count sets
            muscleSets[key] = (muscleSets[key] ?? 0) + e.sets.length;
          }
        }

        // Convert to list and sort
        final muscleGroups = muscleSets.entries.map((e) {
          return _MuscleGroupData(
            name: e.key,
            color: muscleColors[e.key] ?? Colors.grey,
            isSelected: true, // Default to selected
            totalSets: e.value,
          );
        }).toList()..sort((a, b) => b.totalSets.compareTo(a.totalSets));

        // If no data, show empty state
        if (muscleGroups.isEmpty) {
           return const Center(child: Text('No workout data in last 30 days'));
        }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: padding),
          
          // Filter buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: selectedDateRange,
                    isSelected: true,
                    onTap: () {
                      // TODO: Show date range picker
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: _FilterButton(
                    label: selectedTimeGranularity,
                    isSelected: false,
                    onTap: () {
                      // TODO: Show time granularity picker
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: padding),
          
          // Graph section
          Container(
            height: 300,
            margin: EdgeInsets.symmetric(horizontal: padding),
            padding: const EdgeInsets.all(DesignTokens.spacingM),
            decoration: BoxDecoration(
              color: HevyColors.surfaceElevated,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              border: Border.all(
                color: HevyColors.border,
                width: 0.5,
              ),
            ),
            child: _MuscleGroupGraph(
              muscleGroups: muscleGroups.where((m) => m.isSelected).toList(),
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacingM),
          
          // Date range label
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Center(
                child: Text(
                'Sets: $dateRange',
                style: const TextStyle(
                  fontSize: DesignTokens.bodySmall,
                  color: HevyColors.textSecondary,
                  letterSpacing: -0.08,
                  height: 1.29,
                ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacingL),
          
          // Muscle list
          ...muscleGroups.map((muscle) => _MuscleGroupListItem(
            muscle: muscle,
            onToggle: () {
              // TODO: Toggle muscle group visibility
            },
          )),
          
          SizedBox(height: padding),
        ],
      ),
    );
      },
    );
  }
}

/// Filter button
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? HevyColors.primary : HevyColors.surfaceElevated,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            border: Border.all(
              color: isSelected ? HevyColors.primary : HevyColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: DesignTokens.bodyMedium,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : HevyColors.textPrimary,
                  letterSpacing: -0.41,
                  height: 1.29,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: isSelected ? Colors.white : HevyColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Muscle group graph
class _MuscleGroupGraph extends StatelessWidget {
  final List<_MuscleGroupData> muscleGroups;

  const _MuscleGroupGraph({
    required this.muscleGroups,
  });

  @override
  Widget build(BuildContext context) {
    // Mock graph data matching screenshot
    final dates = [
      DateTime(2025, 10, 19),
      DateTime(2025, 10, 28),
      DateTime(2025, 11, 7),
      DateTime(2025, 11, 16),
    ];
    
    // Mock data points matching screenshot
    final chestData = [12.0, 0.0, 9.0, 0.0]; // Blue line
    final bicepsData = [0.0, 12.0, 6.0, 6.0]; // Yellow line
    final tricepsData = [3.0, 10.5, 13.5, 7.5]; // Purple line
    
    return CustomPaint(
      painter: _MuscleGroupGraphPainter(
        dates: dates,
        chestData: chestData,
        bicepsData: bicepsData,
        tricepsData: tricepsData,
      ),
      child: Container(),
    );
  }
}

/// Muscle group graph painter
class _MuscleGroupGraphPainter extends CustomPainter {
  final List<DateTime> dates;
  final List<double> chestData;
  final List<double> bicepsData;
  final List<double> tricepsData;

  _MuscleGroupGraphPainter({
    required this.dates,
    required this.chestData,
    required this.bicepsData,
    required this.tricepsData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding * 2;
    const maxValue = 15.0;
    
    // Draw grid lines (dashed)
    final gridPaint = Paint()
      ..color = HevyColors.textTertiary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Horizontal grid lines at 3, 6, 9, 12, 15
    for (int i = 1; i <= 5; i++) {
      final value = i * 3;
      final y = padding + graphHeight - (value / maxValue) * graphHeight;
      final path = Path()
        ..moveTo(padding, y)
        ..lineTo(size.width - padding, y);
      canvas.drawPath(path, gridPaint);
    }
    
    // Y-axis labels
    const textStyle = TextStyle(
      color: HevyColors.textSecondary,
      fontSize: DesignTokens.labelSmall,
      letterSpacing: -0.08,
      height: 1.29,
    );
    for (int i = 0; i <= 5; i++) {
      final value = i * 3;
      final y = padding + graphHeight - (value / maxValue) * graphHeight;
      final textPainter = TextPainter(
        text: TextSpan(text: value.toString(), style: textStyle),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
    
    // X-axis labels
    final dateFormat = DateFormat('MMM d');
    for (int i = 0; i < dates.length; i++) {
      final x = padding + (graphWidth / (dates.length - 1)) * i;
      final dateText = dateFormat.format(dates[i]);
      final textPainter = TextPainter(
        text: TextSpan(
          text: dateText,
          style: textStyle,
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - padding + 8),
      );
    }
    
    // Draw lines for each muscle group
    final lineData = [
      {'data': chestData, 'color': Colors.blue},
      {'data': bicepsData, 'color': Colors.yellow},
      {'data': tricepsData, 'color': Colors.purple},
    ];
    
    for (var line in lineData) {
      final data = line['data'] as List<double>;
      final color = line['color'] as Color;
      
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final points = <Offset>[];
      for (int i = 0; i < data.length; i++) {
        final x = padding + (graphWidth / (dates.length - 1)) * i;
        final y = padding + graphHeight - (data[i] / maxValue) * graphHeight;
        points.add(Offset(x, y));
      }
      
      // Draw line
      if (points.length > 1) {
        final path = Path();
        path.moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(path, linePaint);
      }
      
      // Draw points
      for (final point in points) {
        canvas.drawCircle(point, 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Muscle group data
class _MuscleGroupData {
  final String name;
  final Color color;
  final bool isSelected;
  final double totalSets;

  _MuscleGroupData({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.totalSets,
  });
}

/// Muscle group list item
class _MuscleGroupListItem extends StatelessWidget {
  final _MuscleGroupData muscle;
  final VoidCallback onToggle;

  const _MuscleGroupListItem({
    required this.muscle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.paddingScreen,
            vertical: DesignTokens.spacingM,
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: muscle.isSelected ? muscle.color : Colors.transparent,
                  border: Border.all(
                    color: muscle.isSelected ? muscle.color : HevyColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: muscle.isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: DesignTokens.spacingM),
              // Muscle name
              Expanded(
                child: Text(
                  muscle.name,
                  style: const TextStyle(
                    fontSize: DesignTokens.bodyLarge,
                    color: HevyColors.textPrimary,
                    letterSpacing: -0.41,
                    height: 1.29,
                  ),
                ),
              ),
              // Set count
              Text(
                muscle.totalSets == muscle.totalSets.toInt()
                    ? '${muscle.totalSets.toInt()}'
                    : muscle.totalSets.toString(),
                style: const TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  color: HevyColors.textPrimary,
                  letterSpacing: -0.41,
                  height: 1.29,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
