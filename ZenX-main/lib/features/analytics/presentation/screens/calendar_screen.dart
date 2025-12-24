import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import 'package:intl/intl.dart';

/// Calendar screen - Shows workout calendar with months
class CalendarScreen extends BaseScreen {
  const CalendarScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Month'),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // TODO: Show month picker
            },
          ),
        ],
      ),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.upload),
          color: HevyColors.textPrimary,
          onPressed: () async {
            final shareService = ShareService();
            await shareService.shareReport(
              reportTitle: 'Workout Calendar',
              reportContent: 'View my workout calendar on ZenX',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: HevyColors.textPrimary,
          onPressed: () {
            // TODO: Show filter options
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
              vertical: DesignTokens.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.spacingXS),
                    const Text(
                      '9 week streak',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyMedium,
                        fontWeight: FontWeight.w500,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.nightlight_round,
                      color: HevyColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.spacingXS),
                    const Text(
                      '1 rest day',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyMedium,
                        fontWeight: FontWeight.w500,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // October Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _MonthCalendar(
              year: 2025,
              month: 10,
              workouts: _getOctoberWorkouts(),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // November 2025 label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: const Text(
              'November 2025',
              style: TextStyle(
                fontSize: DesignTokens.titleLarge,
                fontWeight: FontWeight.w600,
                color: HevyColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingM),

          // November Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _MonthCalendar(
              year: 2025,
              month: 11,
              workouts: _getNovemberWorkouts(),
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }

  Map<int, String> _getOctoberWorkouts() {
    return {
      6: 'Let workout',
      7: 'Chest',
      8: 'Back workou',
      10: 'Late night wo',
      12: 'Arms workou',
      13: 'Cardio',
      14: 'Chest and sh',
      15: 'Cardio',
      24: 'Leg day work',
      25: 'Chest',
      28: 'Back workou',
      29: 'Legs',
      31: 'Arms',
    };
  }

  Map<int, String> _getNovemberWorkouts() {
    return {
      4: 'Push',
      5: 'Cardio',
      6: 'Back workou',
      8: 'Arms',
      10: 'Leg',
      13: 'Push',
      14: 'Back workou',
      16: 'Arms',
      17: 'Legs',
      20: 'Push',
      22: 'Back workou',
      24: 'Legs',
    };
  }
}

class _MonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<int, String> workouts;

  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final startDate = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = startDate.weekday % 7;

    // Calculate number of weeks needed
    final totalDays = daysInMonth + firstWeekday;
    final weeksNeeded = (totalDays / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: DesignTokens.spacingS),

        // Calendar grid
        ...List.generate(weeksNeeded, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }

                final hasWorkout = workouts.containsKey(dayNumber);
                final workoutName = workouts[dayNumber];

                return Expanded(
                  child: Column(
                    children: [
                      // Date number
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasWorkout ? HevyColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              fontSize: DesignTokens.bodySmall,
                              fontWeight: FontWeight.w500,
                              color: hasWorkout
                                  ? Colors.white
                                  : HevyColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      // Workout label
                      if (hasWorkout && workoutName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          workoutName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: HevyColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}
