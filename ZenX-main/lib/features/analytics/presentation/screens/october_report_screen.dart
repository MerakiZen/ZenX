import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// October Report screen (Hevy style)
class OctoberReportScreen extends BaseScreen {
  const OctoberReportScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('October Report'),
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: HevyColors.border, width: 1),
              ),
            ),
            child: const TabBar(
              labelColor: HevyColors.primary,
              unselectedLabelColor: HevyColors.textSecondary,
              indicatorColor: HevyColors.primary,
              tabs: [
                Tab(text: 'Summary'),
                Tab(text: 'Personal Records'),
                Tab(text: 'Workout Days Log'),
              ],
            ),
          ),
          
          // Tab views
          Expanded(
            child: TabBarView(
              children: [
                _SummaryTab(),
                _PersonalRecordsTab(),
                _WorkoutDaysLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data
    const month = 'October 2025';
    const selectedMetric = 'Workouts'; // Can be Workouts, Duration, Volume, Sets
    const mainValue = '14';
    const mainIncrease = '↑ 8';
    
    final summaryData = [
      _SummaryMetric(
        label: 'Workouts',
        value: '14',
        change: '+8',
        isSelected: selectedMetric == 'Workouts',
      ),
      _SummaryMetric(
        label: 'Duration',
        value: '17h 5min',
        change: '+7h 58min',
        isSelected: selectedMetric == 'Duration',
      ),
      _SummaryMetric(
        label: 'Volume',
        value: '63k kg',
        change: '+31k kg',
        isSelected: selectedMetric == 'Volume',
      ),
      _SummaryMetric(
        label: 'Sets',
        value: '161',
        change: '+74',
        isSelected: selectedMetric == 'Sets',
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: DesignTokens.headlineLarge,
                    fontWeight: FontWeight.bold,
                    color: HevyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Row(
                  children: [
                    Text(
                      mainValue,
                      style: const TextStyle(
                        fontSize: DesignTokens.headlineMedium,
                        fontWeight: FontWeight.bold,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingXS),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: DesignTokens.iconSmall, // 16dp
                          color: HevyColors.success,
                        ),
                        Text(
                          mainIncrease,
                          style: const TextStyle(
                            fontSize: DesignTokens.bodyMedium,
                            color: HevyColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bar chart
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            padding: const EdgeInsets.all(DesignTokens.spacingM),
            decoration: BoxDecoration(
              color: HevyColors.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            ),
            child: _MonthlyBarChart(selectedMetric: selectedMetric),
          ),

          const SizedBox(height: DesignTokens.spacingM),

          // Metric filter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Row(
              children: summaryData.map((metric) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _MetricFilterButton(
                      label: metric.label,
                      isSelected: metric.isSelected,
                      onTap: () {
                        // TODO: Update metric
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Summary cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Wrap(
                  spacing: DesignTokens.spacingM,
                  runSpacing: DesignTokens.spacingM,
                  children: summaryData.map((metric) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 
                              DesignTokens.paddingScreen * 2 - DesignTokens.spacingM) / 2,
                      child: _SummaryCard(
                        label: metric.label,
                        value: metric.value,
                        change: metric.change,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Share button
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share report
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HevyColors.primary,
                  foregroundColor: HevyColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingL),
        ],
      ),
    );
  }
}

class _PersonalRecordsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prs = [
      _PersonalRecord(
        exerciseName: 'Reverse Bar Grip Triceps',
        iconAsset: '',
        records: [
          _PRDetail(type: '1RM', value: '38.1 kg'),
          _PRDetail(type: 'Volume', value: '432 kg'),
        ],
      ),
      _PersonalRecord(
        exerciseName: 'Overhead Triceps Extension (Cable)',
        iconAsset: '',
        records: [
          _PRDetail(type: 'Weight', value: '24 kg'),
          _PRDetail(type: '1RM', value: '35.82 kg'),
          _PRDetail(type: 'Volume', value: '360 kg'),
        ],
      ),
      _PersonalRecord(
        exerciseName: 'Bicep Curl (Dumbbell)',
        iconAsset: '',
        records: [
          _PRDetail(type: '1RM', value: '37.31 kg'),
          _PRDetail(type: 'Volume', value: '375 kg'),
        ],
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PR header
          const Padding(
            padding: EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: DesignTokens.iconXLarge, // 48dp (max size)
                  color: Color(0xFFFFC107), // Gold/yellow
                ),
                SizedBox(height: DesignTokens.spacingS),
                Text(
                  '12 new PRs',
                  style: TextStyle(
                    fontSize: DesignTokens.titleLarge,
                    fontWeight: FontWeight.bold,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // PR list
          ...prs.map((pr) => _PRCard(pr: pr)),

          const SizedBox(height: DesignTokens.spacingM),

          // See more link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to full PR list
              },
              child: const Text('See 5 more'),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Share button
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share report
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HevyColors.primary,
                  foregroundColor: HevyColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingL),
        ],
      ),
    );
  }
}

class _WorkoutDaysLogTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock calendar data for October 2025
    final activeDays = [1, 2, 3, 4, 6, 7, 8, 10, 12, 13, 14, 15, 24, 25, 28, 29, 31];
    const streakCount = 5;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Days Log header
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout Days Log',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: DesignTokens.iconSmall, // 16dp (closest to 20)
                    ),
                    const SizedBox(width: DesignTokens.spacingXS),
                    Text(
                      '$streakCount Week Streak',
                      style: const TextStyle(
                        fontSize: DesignTokens.bodyMedium,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _OctoberCalendar(activeDays: activeDays),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Muscle Distribution section (from muscle_distribution_screen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Muscle Distribution',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(DesignTokens.spacingL),
                  decoration: BoxDecoration(
                    color: HevyColors.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                  ),
                  child: const _MuscleDistributionChart(),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Share button
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share report
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HevyColors.primary,
                  foregroundColor: HevyColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingL),
        ],
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final String selectedMetric;

  const _MonthlyBarChart({required this.selectedMetric});

  @override
  Widget build(BuildContext context) {
    final months = ['N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O'];
    // Mock data - in real app this would come from analytics
    final values = [0, 2, 15, 8, 18, 5, 12, 6, 10, 7, 6, 14];

    return CustomPaint(
      painter: _BarChartPainter(
        months: months,
        values: values,
        maxValue: 20,
        selectedMonthIndex: 11, // October (O)
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<String> months;
  final List<int> values;
  final int maxValue;
  final int selectedMonthIndex;

  _BarChartPainter({
    required this.months,
    required this.values,
    required this.maxValue,
    required this.selectedMonthIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final barWidth = chartWidth / months.length * 0.7;
    final spacing = chartWidth / months.length * 0.3;

    // Draw Y-axis labels
    const textStyle = TextStyle(
      color: HevyColors.textSecondary,
      fontSize: 10,
    );
    
    for (int i = 0; i <= 2; i++) {
      final value = maxValue ~/ 2 * i;
      final y = size.height - padding - (chartHeight / 2) * i;
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

    // Draw bars
    for (int i = 0; i < months.length; i++) {
      final x = padding + (chartWidth / months.length) * i + spacing / 2;
      final barHeight = (values[i] / maxValue) * chartHeight;
      final y = size.height - padding - barHeight;
      
      final isSelected = i == selectedMonthIndex;
      final paint = Paint()
        ..color = isSelected ? HevyColors.primary : HevyColors.textTertiary.withValues(alpha: 0.6) // Make unselected bars more visible
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw month label
      final monthTextPainter = TextPainter(
        text: TextSpan(
          text: months[i],
          style: const TextStyle(
            color: HevyColors.textSecondary,
            fontSize: 10,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      monthTextPainter.layout();
      monthTextPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - monthTextPainter.width / 2, size.height - padding + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MetricFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MetricFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingM,
          vertical: DesignTokens.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? HevyColors.primary : HevyColors.surfaceElevated,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTokens.bodySmall,
              color: isSelected ? HevyColors.textPrimary : HevyColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric {
  final String label;
  final String value;
  final String change;
  final bool isSelected;

  _SummaryMetric({
    required this.label,
    required this.value,
    required this.change,
    required this.isSelected,
  });
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
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: DesignTokens.iconSmall, // 16dp (closest to 14)
                color: HevyColors.success,
              ),
              const SizedBox(width: DesignTokens.spacingXXS),
              Text(
                change,
                style: const TextStyle(
                  fontSize: DesignTokens.bodySmall,
                  color: HevyColors.success,
                ),
              ),
            ],
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

class _PersonalRecord {
  final String exerciseName;
  final String iconAsset;
  final List<_PRDetail> records;

  _PersonalRecord({
    required this.exerciseName,
    required this.iconAsset,
    required this.records,
  });
}

class _PRDetail {
  final String type;
  final String value;

  _PRDetail({
    required this.type,
    required this.value,
  });
}

class _PRCard extends StatelessWidget {
  final _PersonalRecord pr;

  const _PRCard({required this.pr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.paddingScreen,
        vertical: DesignTokens.spacingXS,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to exercise detail
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacingM),
          decoration: BoxDecoration(
            color: HevyColors.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          child: Row(
            children: [
              // Exercise icon
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: HevyColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: HevyColors.textSecondary,
                  size: DesignTokens.iconMedium, // 24dp
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              // Exercise name and records
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pr.exerciseName,
                      style: const TextStyle(
                        fontSize: DesignTokens.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    ...pr.records.map((record) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DesignTokens.spacingXXS),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: DesignTokens.iconSmall, // 16dp
                              color: Color(0xFFFFC107),
                            ),
                            const SizedBox(width: DesignTokens.spacingXXS),
                            Text(
                              '${record.type} - ${record.value}',
                              style: const TextStyle(
                                fontSize: DesignTokens.bodySmall,
                                color: HevyColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: HevyColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OctoberCalendar extends StatelessWidget {
  final List<int> activeDays;

  const _OctoberCalendar({required this.activeDays});

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final startDate = DateTime(2025, 10, 1);
    final daysInMonth = DateTime(2025, 10, 31).day;
    final firstWeekday = startDate.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingM),
      decoration: BoxDecoration(
        color: HevyColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          
          // Calendar grid
          ...List.generate(5, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacingXS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }
                  
                  final isActive = activeDays.contains(dayNumber);
                  
                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive ? HevyColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              fontSize: DesignTokens.bodySmall,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? HevyColors.textPrimary
                                  : HevyColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MuscleDistributionChart extends StatelessWidget {
  const _MuscleDistributionChart();

  @override
  Widget build(BuildContext context) {
    // Mock data
    final currentData = {
      'Back': 0.4,
      'Chest': 0.9,
      'Core': 0.5,
      'Shoulders': 0.7,
      'Arms': 1.0,
      'Legs': 0.3,
    };
    
    final previousData = {
      'Back': 0.4,
      'Chest': 0.7,
      'Core': 0.5,
      'Shoulders': 0.5,
      'Arms': 0.8,
      'Legs': 0.3,
    };

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
    
    final axes = ['Back', 'Chest', 'Core', 'Shoulders', 'Arms', 'Legs'];
    final angleStep = (2 * 3.14159) / axes.length;
    
    // Draw grid circles - make more visible on black background
    final gridPaint = Paint()
      ..color = HevyColors.textTertiary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), gridPaint);
    }
    
    // Draw axes and labels
    const labelTextStyle = TextStyle(
      color: HevyColors.textPrimary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (3.14159 / 2);
      final labelRadius = radius * 1.25;
      
      // Calculate end point using proper trigonometry
      final endX = center.dx + radius * 1.1 * math.cos(angle);
      final endY = center.dy + radius * 1.1 * math.sin(angle);
      final endPoint = Offset(endX, endY);
      
      // Draw axis line - make more visible
      final axisPaint = Paint()
        ..color = HevyColors.textTertiary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(center, endPoint, axisPaint);
      
      // Draw label using proper trigonometry
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(text: axes[i], style: labelTextStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }
    
    // Draw previous polygon (light grey) - make more visible
    final previousPath = Path();
    final previousFill = Paint()
      ..color = HevyColors.textTertiary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final previousStroke = Paint()
      ..color = HevyColors.textTertiary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    bool firstPoint = true;
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (3.14159 / 2);
      final value = previousData[axes[i]] ?? 0.0;
      final distance = radius * value;
      // Use proper trigonometry for positioning
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
    canvas.drawPath(previousPath, previousFill);
    canvas.drawPath(previousPath, previousStroke);
    
    // Draw current polygon (blue) - make more visible
    final currentPath = Path();
    final currentFill = Paint()
      ..color = HevyColors.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final currentStroke = Paint()
      ..color = HevyColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Thicker for visibility
    
    firstPoint = true;
    for (int i = 0; i < axes.length; i++) {
      final angle = (i * angleStep) - (3.14159 / 2);
      final value = currentData[axes[i]] ?? 0.0;
      final distance = radius * value;
      // Use proper trigonometry for positioning
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
    canvas.drawPath(currentPath, currentFill);
    canvas.drawPath(currentPath, currentStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


