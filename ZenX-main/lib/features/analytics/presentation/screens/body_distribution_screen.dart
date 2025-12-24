import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';

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
    // Mock data - in a real app, this would come from analytics
    final selectedWeek = DateTime(2025, 11, 4); // Week starting Nov 2
    final weekStart = selectedWeek.subtract(Duration(days: selectedWeek.weekday % 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final activeDays = [2, 3, 4, 5, 8]; // Days with workouts
    
    final muscleData = [
      _MuscleData(name: 'Total', sets: 72),
      _MuscleData(name: 'Abdominals', sets: 0),
      _MuscleData(name: 'Abductors', sets: 0),
      _MuscleData(name: 'Adductors', sets: 0),
      _MuscleData(name: 'Biceps', sets: 10),
      _MuscleData(name: 'Calves', sets: 0),
      _MuscleData(name: 'Cardio', sets: 2),
      _MuscleData(name: 'Chest', sets: 34),
      _MuscleData(name: 'Forearms', sets: 7),
      _MuscleData(name: 'Full Body', sets: 0),
      _MuscleData(name: 'Glutes', sets: 0),
      _MuscleData(name: 'Hamstrings', sets: 0),
      _MuscleData(name: 'Lats', sets: 8.5),
      _MuscleData(name: 'Lower Back', sets: 0),
      _MuscleData(name: 'Neck', sets: 1),
      _MuscleData(name: 'Quadriceps', sets: 0),
      _MuscleData(name: 'Shoulders', sets: 8),
      _MuscleData(name: 'Traps', sets: 2),
      _MuscleData(name: 'Triceps', sets: 14),
      _MuscleData(name: 'Upper Back', sets: 10.5),
      _MuscleData(name: 'Other', sets: 0),
    ];

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
                  onPressed: () {
                    // TODO: Previous week
                  },
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
                  onPressed: () {
                    // TODO: Next week
                  },
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
                // TODO: Filter by day
              },
            ),
          ),

          const SizedBox(height: DesignTokens.spacingL),

          // Anatomical models
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Front view
                Expanded(
                  child: _AnatomicalModel(
                    isFront: true,
                    highlightedMuscles: {
                      'Chest': HevyColors.primary,
                      'Shoulders': HevyColors.primary,
                      'Biceps': HevyColors.primary,
                      'Forearms': HevyColors.primary,
                    },
                  ),
                ),
                SizedBox(width: DesignTokens.spacingM),
                // Back view
                Expanded(
                  child: _AnatomicalModel(
                    isFront: false,
                    highlightedMuscles: {
                      'Lats': HevyColors.primary,
                      'Upper Back': HevyColors.primary,
                      'Shoulders': HevyColors.primary,
                      'Triceps': HevyColors.primary,
                      'Forearms': HevyColors.primary,
                    },
                  ),
                ),
              ],
            ),
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

