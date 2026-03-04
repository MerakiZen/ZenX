import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import '../providers/analytics_providers.dart';

/// Statistics main screen (Hevy style)
class StatisticsScreen extends BaseScreen {
  const StatisticsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Statistics'),
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
    final now = DateTime.now();
    // Start of current week (Monday)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final calendarAsync = ref.watch(workoutCalendarProvider(startDate: weekStart, endDate: weekEnd));
    final muscleStatsAsync = ref.watch(muscleGroupStatsProvider(startDate: weekStart, endDate: weekEnd));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last 7 days body graph section
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last 7 days body graph',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyLarge,
                        fontWeight: FontWeight.w600,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      color: HevyColors.textSecondary,
                      onPressed: () {
                        HelpDialogHelper.showStatisticsHelp(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingM),

                // Weekly calendar
                calendarAsync.when(
                  data: (calendar) {
                    final activeDays = calendar.workoutDays
                        .map((d) {
                          try {
                            return DateTime.parse(d).day;
                          } catch (e) {
                            return -1;
                          }
                        })
                        .where((day) => day != -1)
                        .toList();
                    return _WeeklyCalendar(
                      weekStart: weekStart,
                      activeDays: activeDays,
                      onDayTap: (day) {
                        // TODO: Filter by day
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading calendar: $e', 
                    style: const TextStyle(color: HevyColors.error),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),

                // Anatomical models
                muscleStatsAsync.when(
                  data: (stats) {
                    final highlightedMuscles = <String, Color>{};
                    for (var stat in stats) {
                      if (stat.volume > 0) {
                        highlightedMuscles[stat.muscleGroup] = HevyColors.primary;
                      }
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Front view
                        Expanded(
                          child: _AnatomicalModel(
                            isFront: true,
                            highlightedMuscles: highlightedMuscles,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacingM),
                        // Back view
                        Expanded(
                          child: _AnatomicalModel(
                            isFront: false,
                            highlightedMuscles: highlightedMuscles,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading muscle stats: $e'),
                ),
              ],
            ),
          ),

          const Divider(color: HevyColors.border, height: 32),

          // Advanced statistics section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Advanced statistics',
                  style: TextStyle(
                    fontSize: DesignTokens.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),

                // Set count per muscle group
                _StatisticCard(
                  icon: Icons.trending_up,
                  title: 'Set count per muscle group',
                  description: 'Number of sets logged for each muscle group.',
                  onTap: () => context.push('/analytics/set-count-per-muscle'),
                ),
                const SizedBox(height: DesignTokens.spacingS),

                // Muscle distribution (Chart)
                _StatisticCard(
                  icon: Icons.multiline_chart,
                  title: 'Muscle distribution (Chart)',
                  description: 'Compare your current and previous muscle distributions.',
                  onTap: () => context.push('/analytics/muscle-distribution'),
                ),
                const SizedBox(height: DesignTokens.spacingS),

                // Muscle distribution (Body)
                _StatisticCard(
                  icon: Icons.person,
                  title: 'Muscle distribution (Body)',
                  description: 'Weekly heat map of muscles worked.',
                  onTap: () => context.push('/analytics/body-distribution'),
                ),
                const SizedBox(height: DesignTokens.spacingS),

                // Main exercises
                _StatisticCard(
                  icon: Icons.fitness_center,
                  title: 'Main exercises',
                  description: 'List of exercises you do most often.',
                  onTap: () => context.push('/analytics/main-exercises'),
                ),
                const SizedBox(height: DesignTokens.spacingS),

                // Leaderboard Exercises
                _StatisticCard(
                  icon: Icons.emoji_events,
                  title: 'Leaderboard Exercises',
                  description: 'List of the leaderboard-eligible exercises.',
                  onTap: () => context.push('/exercises/leaderboard'),
                ),
                const SizedBox(height: DesignTokens.spacingS),

                // Monthly Report
                _StatisticCard(
                  icon: Icons.description,
                  title: 'Monthly Report',
                  description: 'Recap of your monthly workouts and statistics.',
                  onTap: () => context.push('/analytics/monthly-report'),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }
}

class _WeeklyCalendar extends StatelessWidget {
  final DateTime weekStart;
  final List<int> activeDays;
  final Function(int) onDayTap;

  const _WeeklyCalendar({
    required this.weekStart,
    required this.activeDays,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = weekStart.add(Duration(days: index));
        final isActive = activeDays.contains(day.day);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onDayTap(day.day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              ),
              child: Column(
                children: [
                  Text(
                    weekdays[index],
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingXXS),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? HevyColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: DesignTokens.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : HevyColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AnatomicalModel extends StatelessWidget {
  final bool isFront;
  final Map<String, Color> highlightedMuscles;

  const _AnatomicalModel({
    required this.isFront,
    required this.highlightedMuscles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(color: HevyColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Note: Placeholder for actual assets if they don't exist
            Image.asset(
              isFront 
                  ? 'assets/images/anatomy_front.png' 
                  : 'assets/images/anatomy_back.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: HevyColors.textTertiary.withOpacity(0.2),
                ),
              ),
            ),
            CustomPaint(
              painter: _AnatomicalModelPainter(
                isFront: isFront,
                highlightedMuscles: highlightedMuscles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnatomicalModelPainter extends CustomPainter {
  final bool isFront;
  final Map<String, Color> highlightedMuscles;

  _AnatomicalModelPainter({
    required this.isFront,
    required this.highlightedMuscles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    void drawPaintHighlight(Offset center, Size radius, Color color) {
      final paint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius.width * 1.2, height: radius.height * 1.2),
        paint,
      );
    }

    final w = size.width;
    final h = size.height;

    if (isFront) {
      if (highlightedMuscles.containsKey('Chest')) {
        drawPaintHighlight(Offset(w * 0.38, h * 0.28), Size(w * 0.16, h * 0.1), HevyColors.primary);
        drawPaintHighlight(Offset(w * 0.62, h * 0.28), Size(w * 0.16, h * 0.1), HevyColors.primary);
      }
      if (highlightedMuscles.containsKey('Shoulders')) {
        drawPaintHighlight(Offset(w * 0.22, h * 0.24), Size(w * 0.12, h * 0.1), HevyColors.primary);
        drawPaintHighlight(Offset(w * 0.78, h * 0.24), Size(w * 0.12, h * 0.1), HevyColors.primary);
      }
      // Add more as needed
    } else {
      if (highlightedMuscles.containsKey('Lats') || highlightedMuscles.containsKey('Back')) {
         drawPaintHighlight(Offset(w * 0.36, h * 0.35), Size(w * 0.1, h * 0.18), HevyColors.primary);
         drawPaintHighlight(Offset(w * 0.64, h * 0.35), Size(w * 0.1, h * 0.18), HevyColors.primary);
      }
      // Add more as needed
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _StatisticCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: HevyColors.surfaceElevated,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Icon(
                icon,
                color: HevyColors.primary,
                size: DesignTokens.iconMedium,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingXXS),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
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
    );
  }
}
