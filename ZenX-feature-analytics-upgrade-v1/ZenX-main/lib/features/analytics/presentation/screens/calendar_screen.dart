import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_providers.dart';

/// Calendar screen - Shows workout calendar with months
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
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

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate range for current view (selected month + next month)
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 2, 0);

    final calendarAsync = ref.watch(workoutCalendarProvider(startDate: start, endDate: end));

    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: _buildAppBar(),
      body: calendarAsync.when(
        data: (calendar) {
          final workoutsByDate = _processWorkouts(calendar.workoutDays);
          return _buildBody(workoutsByDate);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Map<String, Map<int, String>> _processWorkouts(List<String> workoutDays) {
    final Map<String, Map<int, String>> result = {};
    
    for (final dateStr in workoutDays) {
      try {
        final date = DateTime.parse(dateStr);
        final monthKey = _formatMonthKey(date);
        
        if (!result.containsKey(monthKey)) {
          result[monthKey] = {};
        }
        
        result[monthKey]![date.day] = 'Workout';
      } catch (e) {
        debugPrint('Error parsing workout date: $dateStr');
      }
    }
    
    return result;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: InkWell(
        onTap: _showMonthPicker,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
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
            _showFilterOptions();
          },
        ),
      ],
    );
  }

  Widget _buildBody(Map<String, Map<int, String>> workoutsByMonth) {
    final monthsToDisplay = <DateTime>[
      _selectedMonth,
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBar(),
          
          const Divider(height: 1),
          
          ...monthsToDisplay.map((month) {
            final monthKey = _formatMonthKey(month);
            final monthWorkouts = workoutsByMonth[monthKey] ?? {};
            
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.paddingScreen,
                vertical: DesignTokens.spacingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: const TextStyle(
                      fontSize: DesignTokens.titleLarge,
                      fontWeight: FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingM),
                  _MonthCalendar(
                    year: month.year,
                    month: month.month,
                    workouts: _filterWorkouts(monthWorkouts),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: DesignTokens.spacingXL),
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
                'Workout Hot Streak',
                style: TextStyle(
                  fontSize: DesignTokens.bodyMedium,
                  fontWeight: FontWeight.w500,
                  color: HevyColors.textPrimary,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: HevyColors.textSecondary,
                size: 20,
              ),
              SizedBox(width: DesignTokens.spacingXS),
              Text(
                'Rest Days',
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
    // Note: Actual filtering by type (Strength/Cardio) isn't implemented in the dummy logic
    // but the UI structure remains to support it
    return Map.from(workouts);
  }

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
              SizedBox(
                height: 300,
                child: ListView.builder(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: const Text(
                  'Show',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ),
              ..._timeFilters.map((filter) => ListTile(
                title: Text(filter),
                trailing: _selectedFilter == filter ? const Icon(Icons.check, color: HevyColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: DesignTokens.spacingL),
            ],
          ),
        ),
      ),
    );
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
