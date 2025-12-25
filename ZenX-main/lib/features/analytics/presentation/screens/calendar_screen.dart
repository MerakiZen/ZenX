import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_providers.dart';

/// Calendar screen - Shows workout calendar with months
class CalendarScreen extends BaseScreen {
  const CalendarScreen({super.key});

  @override
<<<<<<< Updated upstream
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
=======
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const List<String> _timeFilters = ['All Workouts', 'Strength', 'Cardio', 'Rest Days'];
  final List<DateTime> _availableMonths = List.generate(
    12,
    (index) => DateTime(2025, 12 - index),
  );

  late DateTime _selectedMonth;
  String _selectedFilter = _timeFilters.first;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate range for current view (selected month + next month)
    // Actually, let's just fetch for the selected month and the next one to match UI
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 2, 0);

    final calendarAsync = ref.watch(workoutCalendarProvider(startDate: start, endDate: end));

    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: _buildAppBar(),
      body: calendarAsync.when(
        data: (calendar) {
          final workoutsByMonth = _processWorkouts(calendar.workoutDays);
          return _buildBody(workoutsByMonth);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Map<String, Map<int, String>> _processWorkouts(List<String> workoutDays) {
    final Map<String, Map<int, String>> result = {};
    
    for (final dateStr in workoutDays) {
      final date = DateTime.parse(dateStr);
      final monthKey = _formatMonthKey(date);
      
      if (!result.containsKey(monthKey)) {
        result[monthKey] = {};
      }
      
      // We don't have workout names, so just use "Workout"
      result[monthKey]![date.day] = 'Workout';
    }
    
    return result;
  }

  PreferredSizeWidget _buildAppBar() {
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
=======
  Widget _buildBody(Map<String, Map<int, String>> workoutsByMonth) {
    // Always show current month and next month
    final monthsToDisplay = <DateTime>[
      _selectedMonth,
      DateTime(_selectedMonth.year, _selectedMonth.month + 1),
    ];

>>>>>>> Stashed changes
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          Padding(
<<<<<<< Updated upstream
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
              vertical: DesignTokens.spacingM,
=======
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
            child: _MonthCalendar(
              year: monthsToDisplay[0].year,
              month: monthsToDisplay[0].month,
              workouts: _filterWorkouts(workoutsByMonth[_formatMonthKey(monthsToDisplay[0])] ?? {}),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
                const SizedBox(height: DesignTokens.spacingM),
                _MonthCalendar(
                  year: monthsToDisplay[1].year,
                  month: monthsToDisplay[1].month,
                  workouts: _filterWorkouts(workoutsByMonth[_formatMonthKey(monthsToDisplay[1])] ?? {}),
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
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
=======
  // Removed _loadWorkouts

  String _formatMonthKey(DateTime date) => DateFormat('yyyy-MM').format(date);

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HevyColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingL,
                  vertical: DesignTokens.spacingM,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Month',
                        style: TextStyle(
                          fontSize: DesignTokens.titleMedium,
                          fontWeight: FontWeight.w600,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: HevyColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: HevyColors.border),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _availableMonths.length,
                itemBuilder: (context, index) {
                  final month = _availableMonths[index];
                  final title = DateFormat('MMMM yyyy').format(month);
                  final isSelected =
                      month.year == _selectedMonth.year && month.month == _selectedMonth.month;
                  return ListTile(
                    title: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? HevyColors.primary : HevyColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: HevyColors.primary) : null,
                    onTap: () {
                      setState(() {
                        _selectedMonth = month;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.paddingScreen,
        vertical: DesignTokens.spacingM,
      ),
      color: HevyColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Show',
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontWeight: FontWeight.w600,
              color: HevyColors.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Wrap(
            spacing: DesignTokens.spacingS,
            runSpacing: DesignTokens.spacingS,
            children: _timeFilters.map((filter) {
              final isSelected = filter == _selectedFilter;
              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : HevyColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: HevyColors.primary,
                backgroundColor: HevyColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Padding(
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
    );
  }

  Map<int, String> _filterWorkouts(Map<int, String> workouts) {
    if (_selectedFilter == 'All Workouts') return Map.from(workouts);

    final filter = _selectedFilter.toLowerCase();
    return Map.fromEntries(
      workouts.entries.where((entry) {
        final value = entry.value.toLowerCase();
        if (_selectedFilter == 'Rest Days') {
          return value.contains('rest');
        }
        return value.contains(filter);
      }),
    );
>>>>>>> Stashed changes
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
