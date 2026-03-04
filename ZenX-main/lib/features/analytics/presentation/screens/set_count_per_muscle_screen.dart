import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/utils/share_service.dart';
import '../../../../core/utils/help_dialog_helper.dart';
import '../providers/analytics_providers.dart';

final selectedRangeProvider = StateProvider.autoDispose<String>((ref) => 'Last 30 days');
final selectedMusclesProvider = StateProvider.autoDispose<Set<String>>((ref) => {});

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
    final selectedRange = ref.watch(selectedRangeProvider);
    final selectedMuscles = ref.watch(selectedMusclesProvider);
    
    final now = DateTime.now();
    DateTime start;
    switch (selectedRange) {
      case 'Last 7 days':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 days':
        start = now.subtract(const Duration(days: 30));
        break;
      case 'Last 3 months':
        start = now.subtract(const Duration(days: 90));
        break;
      case 'Last year':
        start = now.subtract(const Duration(days: 365));
        break;
      case 'All time':
        start = DateTime(2000);
        break;
      default:
        start = now.subtract(const Duration(days: 30));
    }
    
    final statsAsync = ref.watch(muscleGroupStatsProvider(startDate: start, endDate: now));
    
    return statsAsync.when(
      data: (stats) {
        // Filter and map stats to UI model
        final muscleGroups = stats.map((s) => _MuscleGroupData(
          name: s.muscleGroup,
          color: _getMuscleColor(s.muscleGroup),
          isSelected: selectedMuscles.contains(s.muscleGroup) || selectedMuscles.isEmpty,
          totalSets: s.setCount.toDouble(),
        )).toList();
        
        // Sort by sets desc
        muscleGroups.sort((a, b) => b.totalSets.compareTo(a.totalSets));

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: padding),
              
              // Filter buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterButton(
                        label: selectedRange,
                        isSelected: true,
                        onTap: () => _showRangePicker(context, ref, selectedRange),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: _FilterButton(
                        label: 'Week', 
                        isSelected: false,
                        onTap: () {}, // TODO: Implement granularity picker
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: padding),
              
              // Graph section
              Container(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: padding),
                padding: const EdgeInsets.all(DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: HevyColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                  border: Border.all(color: HevyColors.border),
                ),
                child: muscleGroups.isEmpty 
                  ? const Center(child: Text('No data for selected period', style: TextStyle(color: HevyColors.textSecondary)))
                  : _MuscleGroupChart(muscleGroups: muscleGroups.take(5).toList()),
              ),
              
              const SizedBox(height: padding),
              
              // Muscle list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: muscleGroups.map((muscle) => _MuscleListItem(
                    muscle: muscle,
                    onTap: () {
                      final current = ref.read(selectedMusclesProvider);
                      final newSet = Set<String>.from(current);
                      if (newSet.contains(muscle.name)) {
                        newSet.remove(muscle.name);
                      } else {
                        newSet.add(muscle.name);
                      }
                      ref.read(selectedMusclesProvider.notifier).state = newSet;
                    },
                  )).toList(),
                ),
              ),
              const SizedBox(height: padding),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXL)),
      ),
      backgroundColor: HevyColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingL),
              child: Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: DesignTokens.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: HevyColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ...['Last 7 days', 'Last 30 days', 'Last 3 months', 'Last year', 'All time'].map((range) => ListTile(
              title: Text(range),
              trailing: range == current ? const Icon(Icons.check, color: HevyColors.primary) : null,
              onTap: () {
                ref.read(selectedRangeProvider.notifier).state = range;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
  
  Color _getMuscleColor(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest': return HevyColors.categoryChest;
      case 'back': return HevyColors.categoryBack;
      case 'legs': return HevyColors.categoryLegs;
      case 'shoulders': return HevyColors.categoryShoulders;
      case 'arms': return HevyColors.categoryArms;
      case 'core': return HevyColors.categoryCore;
      default: return HevyColors.textTertiary;
    }
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
class _MuscleGroupChart extends StatelessWidget {
  final List<_MuscleGroupData> muscleGroups;

  const _MuscleGroupChart({
    required this.muscleGroups,
  });

  @override
  Widget build(BuildContext context) {
    if (muscleGroups.isEmpty) return const SizedBox.shrink();

    final maxSets = muscleGroups.map((m) => m.totalSets).reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Count by Muscle Group',
          style: TextStyle(
            fontSize: DesignTokens.bodyMedium,
            color: HevyColors.textSecondary,
            letterSpacing: -0.41,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingM),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: muscleGroups.map((muscle) {
              final heightFraction = (maxSets > 0) ? (muscle.totalSets / maxSets) : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        muscle.totalSets.toInt().toString(),
                        style: const TextStyle(
                          fontSize: DesignTokens.labelSmall,
                          color: HevyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: 180 * heightFraction,
                        decoration: BoxDecoration(
                          color: muscle.color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _abbreviateMuscle(muscle.name),
                        style: const TextStyle(
                          fontSize: DesignTokens.labelSmall,
                          color: HevyColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _abbreviateMuscle(String name) {
    final abbreviations = {
      'Chest': 'Chest',
      'Back': 'Back',
      'Shoulders': 'Shld',
      'Biceps': 'Bi',
      'Triceps': 'Tri',
      'Forearms': 'Fore',
      'Abs': 'Abs',
      'Quads': 'Quad',
      'Hamstrings': 'Ham',
      'Glutes': 'Glute',
      'Calves': 'Calf',
      'Cardio': 'Card',
      'Full Body': 'Full',
    };
    return abbreviations[name] ?? (name.length > 4 ? name.substring(0, 4) : name);
  }
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
class _MuscleListItem extends StatelessWidget {
  final _MuscleGroupData muscle;
  final VoidCallback onTap;

  const _MuscleListItem({
    required this.muscle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacingM,
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Text(
                  muscle.name,
                  style: const TextStyle(
                    fontSize: DesignTokens.bodyLarge,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ),
              Text(
                muscle.totalSets.toInt().toString(),
                style: const TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  color: HevyColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
