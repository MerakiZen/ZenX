import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import '../providers/analytics_providers.dart';

final selectedWeekProvider = StateProvider.autoDispose<DateTime>((ref) {
  // Default to current week
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday % 7));
});

/// Body distribution screen (Hevy style)
class BodyDistributionScreen extends BaseScreen {
  const BodyDistributionScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Body distribution'),
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
          color: HevyColors.textSecondary,
          onPressed: () {
            HelpDialogHelper.showBodyDistributionHelp(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          color: HevyColors.textSecondary,
          onPressed: () async {
            final shareService = ShareService();
            await shareService.shareReport(
              reportTitle: 'Body Distribution',
              reportContent: 'View my body distribution statistics on ZenX',
            );
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final weekStart = selectedWeek;
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // Fetch muscle group stats for the selected week
    final muscleStatsAsync = ref.watch(muscleGroupStatsProvider(
      startDate: weekStart,
      endDate: weekEnd.add(const Duration(days: 1)), // Include end day
    ));

    return muscleStatsAsync.when(
      data: (muscleStats) {
        // Calculate which days had workouts (we could get this from workout calendar)
        // For now, just show the data we have
        final activeDays = <int>[]; // TODO: Get from workout calendar if needed
        
        // Convert to display format with "Total" as first item
        final totalSets = muscleStats.fold<int>(0, (sum, stat) => sum + stat.setCount);
        final muscleData = <_MuscleData>[
          _MuscleData(name: 'Total', sets: totalSets.toDouble()),
          ...muscleStats.map((stat) => _MuscleData(
            name: stat.muscleGroup,
            sets: stat.setCount.toDouble(),
          )),
        ];

        return _BodyDistributionContent(
          weekStart: weekStart,
          weekEnd: weekEnd,
          activeDays: activeDays,
          muscleData: muscleData,
          onPreviousWeek: () {
            ref.read(selectedWeekProvider.notifier).state = 
              weekStart.subtract(const Duration(days: 7));
          },
          onNextWeek: () {
            ref.read(selectedWeekProvider.notifier).state = 
              weekStart.add(const Duration(days: 7));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading muscle stats: $error',
          style: const TextStyle(color: HevyColors.textSecondary),
        ),
      ),
    );
  }
}

class _BodyDistributionContent extends StatelessWidget {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<int> activeDays;
  final List<_MuscleData> muscleData;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const _BodyDistributionContent({
    required this.weekStart,
    required this.weekEnd,
    required this.activeDays,
    required this.muscleData,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
              vertical: DesignTokens.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: HevyColors.textPrimary,
                  onPressed: onPreviousWeek,
                ),
                Text(
                  '${DateFormat('dd').format(weekStart)}-${DateFormat('dd MMMM yyyy').format(weekEnd)}',
                  style: const TextStyle(
                    fontSize: DesignTokens.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: HevyColors.textPrimary,
                  onPressed: onNextWeek,
                ),
              ],
            ),
          ),

          // Weekly calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _WeeklyCalendar(
              weekStart: weekStart,
              activeDays: activeDays,
              onDayTap: (day) {
                // TODO: Filter by day if needed
              },
            ),
          ),

          const SizedBox(height: DesignTokens.spacingL),

          // Anatomical models - simplified version
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _SimplifiedAnatomicalView(muscleData: muscleData),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Muscle list header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Muscle',
                  style: TextStyle(
                    fontSize: DesignTokens.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                Text(
                  'Sets',
                  style: TextStyle(
                    fontSize: DesignTokens.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingS),

          // Muscle groups list
          ...muscleData.map((muscle) => _MuscleListItem(muscle: muscle)),
          
          const SizedBox(height: DesignTokens.spacingL),
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
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
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
                              ? HevyColors.textPrimary
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

/// Simplified anatomical view showing muscle groups with color intensity based on work
class _SimplifiedAnatomicalView extends StatelessWidget {
  final List<_MuscleData> muscleData;

  const _SimplifiedAnatomicalView({required this.muscleData});

  @override
  Widget build(BuildContext context) {
    // Create a map of muscle names to their set counts for easy lookup
    final muscleMap = {
      for (var muscle in muscleData) muscle.name: muscle.sets
    };
    
    // Get max sets for color intensity scaling (excluding "Total")
    final maxSets = muscleData
        .where((m) => m.name != 'Total')
        .fold<double>(0, (max, m) => m.sets > max ? m.sets : max);

    // Helper to get color intensity for a muscle
    Color getMuscleColor(String muscleName) {
      final sets = muscleMap[muscleName] ?? 0.0;
      if (sets == 0 || maxSets == 0) return HevyColors.textTertiary.withValues(alpha: 0.2);
      final intensity = (sets / maxSets).clamp(0.0, 1.0);
      return HevyColors.primary.withValues(alpha: 0.3 + (intensity * 0.7));
    }

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: HevyColors.surfaceElevated,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(color: HevyColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Muscle Groups Worked',
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontWeight: FontWeight.w600,
              color: HevyColors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          // Simple grid showing muscles with color coding
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: muscleData
                .where((m) => m.name != 'Total' && m.sets > 0)
                .map((muscle) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: getMuscleColor(muscle.name),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                        border: Border.all(color: HevyColors.border),
                      ),
                      child: Text(
                        '${muscle.name} (${muscle.sets.toInt()})',
                        style: const TextStyle(
                          fontSize: DesignTokens.labelMedium,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
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
        color: Colors.black, // Match the asset's black background
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
            // Base 3D Anatomy Model
            Image.asset(
              isFront 
                  ? 'assets/images/anatomy_front.png' 
                  : 'assets/images/anatomy_back.png',
              fit: BoxFit.contain,
            ),
            // Highlight Layer - "Painted" Effect
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
    // Helper to draw "blue paint" highlight
    void drawPaintHighlight(Offset center, Size radius, Color color) {
      final paint = Paint()
        ..color = Colors.blue.withOpacity(0.6) // User asked for BLUE paint
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen // Screen blend mode lights up the clay model
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15); // Soft airbrush look
      
      // Draw larger soft glow
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius.width * 1.2, height: radius.height * 1.2),
        paint,
      );
      
      // Draw tighter core
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius.width * 0.8, height: radius.height * 0.8),
        Paint()
          ..color = Colors.cyanAccent.withOpacity(0.4)
          ..blendMode = BlendMode.overlay
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    final w = size.width;
    final h = size.height;

    // Adjust coordinates for the new 3D clay model
    if (isFront) {
      // FRONT VIEW MAPPINGS
      if (highlightedMuscles.containsKey('Chest')) {
        drawPaintHighlight(Offset(w * 0.38, h * 0.28), Size(w * 0.16, h * 0.1), Colors.blue);
        drawPaintHighlight(Offset(w * 0.62, h * 0.28), Size(w * 0.16, h * 0.1), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Shoulders')) {
        drawPaintHighlight(Offset(w * 0.22, h * 0.24), Size(w * 0.12, h * 0.1), Colors.blue);
        drawPaintHighlight(Offset(w * 0.78, h * 0.24), Size(w * 0.12, h * 0.1), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Biceps')) {
        drawPaintHighlight(Offset(w * 0.20, h * 0.36), Size(w * 0.09, h * 0.11), Colors.blue);
        drawPaintHighlight(Offset(w * 0.80, h * 0.36), Size(w * 0.09, h * 0.11), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Abs') || highlightedMuscles.containsKey('Core')) {
        drawPaintHighlight(Offset(w * 0.5, h * 0.45), Size(w * 0.14, h * 0.2), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Forearms')) {
        drawPaintHighlight(Offset(w * 0.15, h * 0.52), Size(w * 0.07, h * 0.12), Colors.blue);
        drawPaintHighlight(Offset(w * 0.85, h * 0.52), Size(w * 0.07, h * 0.12), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Quads') || highlightedMuscles.containsKey('Legs')) {
         drawPaintHighlight(Offset(w * 0.38, h * 0.70), Size(w * 0.13, h * 0.25), Colors.blue);
         drawPaintHighlight(Offset(w * 0.62, h * 0.70), Size(w * 0.13, h * 0.25), Colors.blue);
      }
    } else {
      // BACK VIEW MAPPINGS
      if (highlightedMuscles.containsKey('Upper Back') || highlightedMuscles.containsKey('Traps')) {
        drawPaintHighlight(Offset(w * 0.5, h * 0.22), Size(w * 0.22, h * 0.12), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Lats') || highlightedMuscles.containsKey('Back')) {
         drawPaintHighlight(Offset(w * 0.36, h * 0.35), Size(w * 0.1, h * 0.18), Colors.blue);
         drawPaintHighlight(Offset(w * 0.64, h * 0.35), Size(w * 0.1, h * 0.18), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Triceps')) {
        drawPaintHighlight(Offset(w * 0.24, h * 0.35), Size(w * 0.08, h * 0.11), Colors.blue);
        drawPaintHighlight(Offset(w * 0.76, h * 0.35), Size(w * 0.08, h * 0.11), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Glutes')) {
        drawPaintHighlight(Offset(w * 0.5, h * 0.56), Size(w * 0.22, h * 0.14), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Hamstrings') || highlightedMuscles.containsKey('Legs')) {
         drawPaintHighlight(Offset(w * 0.38, h * 0.72), Size(w * 0.11, h * 0.22), Colors.blue);
         drawPaintHighlight(Offset(w * 0.62, h * 0.72), Size(w * 0.11, h * 0.22), Colors.blue);
      }
      if (highlightedMuscles.containsKey('Calves')) {
         drawPaintHighlight(Offset(w * 0.38, h * 0.88), Size(w * 0.09, h * 0.14), Colors.blue);
         drawPaintHighlight(Offset(w * 0.62, h * 0.88), Size(w * 0.09, h * 0.14), Colors.blue);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MuscleData {
  final String name;
  final double sets;

  _MuscleData({
    required this.name,
    required this.sets,
  });
}

class _MuscleListItem extends StatelessWidget {
  final _MuscleData muscle;

  const _MuscleListItem({required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.paddingScreen,
        vertical: DesignTokens.spacingXXS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            muscle.name,
            style: const TextStyle(
              fontSize: DesignTokens.bodyMedium,
              color: HevyColors.textPrimary,
            ),
          ),
          Text(
            muscle.sets == muscle.sets.toInt()
                ? muscle.sets.toInt().toString()
                : muscle.sets.toString(),
            style: const TextStyle(
              fontSize: DesignTokens.bodyMedium,
              color: HevyColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

