import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../providers/profile_providers.dart';

/// User profile screen (pixel-perfect Hevy style)
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewProvider);
    return profileAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(context, null),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: _buildAppBar(context, null),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: HevyColors.textTertiary,
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Text(
                  'Profile not available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Text(
                  'Please log in to view your profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HevyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),
                ElevatedButton(
                  onPressed: () => ref.refresh(profileViewProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) => Scaffold(
        appBar: _buildAppBar(context, data.profile.displayName),
        body: _buildBody(context, data),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String? username) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      toolbarHeight: 56,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: DesignTokens.paddingScreen),
        child: TextButton(
          onPressed: () => context.push('/profile/edit'),
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
            foregroundColor: HevyColors.primary,
            textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          child: const Text('Edit Profile'),
        ),
      ),
      title: Text(
        username?.isNotEmpty == true ? username! : 'Profile',
        style: const TextStyle(
          color: HevyColors.textPrimary,
          fontSize: DesignTokens.titleMedium,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share_rounded),
          tooltip: 'Share profile',
          onPressed: () async {
            final handle =
                username?.isNotEmpty == true ? username! : 'ZenX athlete';
            final shareService = ShareService();
            await shareService.shareText(
              text:
                  'Check out my fitness profile on ZenX!\n\nProfile: https://zenx.app/profile/$handle',
              subject: 'My Fitness Profile',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.push('/profile/settings'),
        ),
        const SizedBox(width: DesignTokens.spacingXS),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ProfileViewData data) {
    final chartData = _buildChartData(data.measurements);
    final dashboardItems = [
      _DashboardItem(
        icon: Icons.bar_chart_rounded,
        label: 'Statistics',
        route: '/analytics/statistics',
      ),
      _DashboardItem(
        icon: Icons.fitness_center_rounded,
        label: 'Exercises',
        route: '/exercises',
      ),
      _DashboardItem(
        icon: Icons.straighten_rounded,
        label: 'Measures',
        route: '/profile/measurements',
      ),
      _DashboardItem(
        icon: Icons.calendar_today_rounded,
        label: 'Calendar',
        route: '/analytics/calendar',
      ),
    ];

    final workouts = data.recentWorkouts;

    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.paddingScreen,
                vertical: DesignTokens.spacingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    profile: data.profile,
                    measurementCount: data.measurements.length,
                    latestWeight: chartData.latestValue,
                  ),
                  const SizedBox(height: DesignTokens.spacingXL),
                  _SectionHeader(
                    title: chartData.title,
                    subtitle: chartData.subtitle,
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  _WeeklyBarChart(
                    values: chartData.values,
                    labels: chartData.labels,
                    maxValue: chartData.maxValue,
                    unit: chartData.unit,
                  ),
                  const SizedBox(height: DesignTokens.spacingXL),
                  const _SectionHeader(
                    title: 'Dashboard',
                    subtitle: null,
                  ),
                  const SizedBox(height: DesignTokens.spacingM),
                  _DashboardGrid(
                    items: dashboardItems,
                    onTap: (route) {
                      if (route == '/profile/settings') {
                        context.push('/profile/settings');
                      } else {
                        context.push(route);
                      }
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacingXL),
                  const _SectionHeader(
                    title: 'Workouts',
                    subtitle: null,
                  ),
                  const SizedBox(height: DesignTokens.spacingM),
                  _WorkoutList(workouts: workouts),
                  const SizedBox(height: DesignTokens.spacingXL),
                  const SizedBox(height: DesignTokens.spacingXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  _ChartData _buildChartData(List<MeasurementPoint> measurements) {
    if (measurements.isEmpty) {
      return _ChartData(
        values: List<double>.filled(8, 0),
        labels: const ['-', '-', '-', '-', '-', '-', '-', '-'],
        maxValue: 1,
        unit: 'kg',
        title: 'No measurements yet',
        subtitle: 'Add your first measurement',
        latestValue: null,
      );
    }

    final recent = measurements.reversed.take(8).toList().reversed.toList();
    final values = recent.map((m) => m.weightKg ?? 0).toList();
    final labels =
        recent.map((m) => _formatShortLabel(m.measurementDate)).toList();
    final maxValue = values.reduce(math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue * 1.2;
    final latest = recent.last.weightKg;
    final title =
        latest != null ? '${latest.toStringAsFixed(1)} kg' : 'Weight trend';
    final subtitle = 'Updated ${_formatLongLabel(recent.last.measurementDate)}';

    return _ChartData(
      values: values,
      labels: labels,
      maxValue: safeMax,
      unit: 'kg',
      title: title,
      subtitle: subtitle,
      latestValue: latest,
    );
  }

  String _formatShortLabel(DateTime date) {
    return '${_monthAbbrev(date.month)} ${date.day}';
  }

  String _formatLongLabel(DateTime date) {
    return '${_monthAbbrev(date.month)} ${date.day}, ${date.year}';
  }

  String _monthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month < 1 || month > 12) {
      return '';
    }
    return months[month - 1];
  }
}

class _ChartData {
  const _ChartData({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.unit,
    required this.title,
    required this.subtitle,
    required this.latestValue,
  });

  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final String unit;
  final String title;
  final String subtitle;
  final double? latestValue;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.measurementCount,
    this.latestWeight,
  });

  final ProfileDetails profile;
  final int measurementCount;
  final double? latestWeight;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.displayName ?? 'ZenX Athlete';
    final avatarUrl = profile.avatarUrl;
    final gender = profile.gender ?? '—';
    final dateOfBirth = profile.dateOfBirth ?? '—';
    final latestWeightText =
        latestWeight != null ? '${latestWeight!.toStringAsFixed(1)} kg' : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: HevyColors.surfaceElevated,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: HevyColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: DesignTokens.spacingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacingXS),
                    Text(
                      profile.bio!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: HevyColors.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spacingS),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileStat(
                              label: 'Workouts',
                              value: profile.workoutCount?.toString() ?? '0',
                            ),
                          ),
                          Expanded(
                            child: _ProfileStat(
                              label: 'Volume',
                              value: profile.totalVolumeKg != null 
                                  ? '${(profile.totalVolumeKg! / 1000).toStringAsFixed(1)}k' 
                                  : '0',
                            ),
                          ),
                          Expanded(
                            child: _ProfileStat(
                              label: 'Streak',
                              value: '${profile.streakDays ?? 0} d',
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: HevyColors.textSecondary,
              ),
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HevyColors.textSecondary,
                ),
          ),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final String unit;

  const _WeeklyBarChart({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingL,
      ),
      decoration: BoxDecoration(
        color: HevyColors.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(color: HevyColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AxisLabel(_formatAxisLabel(safeMax)),
                      _AxisLabel(_formatAxisLabel(safeMax / 2)),
                      const _AxisLabel('0'),
                    ],
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth =
                          constraints.maxWidth / (values.length * 1.6);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < values.length; i++)
                            _ChartBar(
                              value: values[i],
                              maxValue: safeMax,
                              label: labels[i],
                              width: barWidth,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAxisLabel(double value) {
    if (unit.isEmpty) {
      return value.toStringAsFixed(1);
    }
    return '${value.toStringAsFixed(1)} $unit';
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;

  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HevyColors.textSecondary,
          ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final double width;

  const _ChartBar({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final heightFactor = (value / maxValue).clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
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
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HevyColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final List<_DashboardItem> items;
  final ValueChanged<String> onTap;

  const _DashboardGrid({
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: DesignTokens.spacingM,
            mainAxisSpacing: DesignTokens.spacingM,
            childAspectRatio: isCompact ? 1.4 : 1.9,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _DashboardButton(
              icon: item.icon,
              label: item.label,
              onTap: () => onTap(item.route),
            );
          },
        );
      },
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          border: Border.all(color: HevyColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: HevyColors.textPrimary, size: DesignTokens.iconLarge),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutList extends StatelessWidget {
  final List<Workout> workouts;

  const _WorkoutList({required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: workouts
          .map(
            (workout) => Padding(
              padding: EdgeInsets.only(
                bottom: workout == workouts.last ? 0 : DesignTokens.spacingM,
              ),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: HevyColors.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                  border: Border.all(color: HevyColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: HevyColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                      ),
                      child: const Icon(Icons.fitness_center, color: HevyColors.textSecondary),
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(workout.startedAt ?? DateTime.now()),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HevyColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: DesignTokens.spacingXXS),
                          Text(
                            workout.name ?? 'Untitled Workout',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: DesignTokens.spacingXXS),
                          Text(
                            '${workout.exercises.length} Exercises · ${workout.totalVolumeKg?.toStringAsFixed(0) ?? 0} kg',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HevyColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz,
                          color: HevyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String label;
  final String route;

  _DashboardItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _WorkoutSummary {
  final String title;
  final String subtitle;
  final String username;
  final String imageUrl;

  _WorkoutSummary({
    required this.title,
    required this.subtitle,
    required this.username,
    required this.imageUrl,
  });
}
