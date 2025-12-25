import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';

/// Edit workout screen (Hevy Pro style)
class EditWorkoutScreen extends BaseScreen {
  final String workoutId;

  const EditWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: TextButton(
        onPressed: () => context.pop(),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: HevyColors.primary,
            fontSize: DesignTokens.bodyMedium,
          ),
        ),
      ),
      title: const Text(
        'Edit Workout',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () {
            // TODO: Save workout
            context.pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingM,
              vertical: DesignTokens.spacingXS,
            ),
            decoration: BoxDecoration(
              color: HevyColors.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: DesignTokens.bodyMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 12.0 : DesignTokens.paddingScreen;
    
    // Mock data matching the screenshots
    const workoutName = 'Arms';
    final date = DateTime(2025, 11, 8, 21, 59);
    const duration = Duration(minutes: 51);
    const totalVolume = 4408.0;
    const setsCount = 15;
    
    final exercises = [
      _ExerciseEditDetail(
        name: 'Triceps Rope Pushdown',
        iconAsset: '',
        notes: '',
        restTimerEnabled: false,
        sets: [
          _SetEditDetail(
            isWarmup: true,
            isCompleted: true,
            reps: 16,
            weight: 14.0,
            previousReps: 16,
            previousWeight: 14.0,
          ),
          _SetEditDetail(
            isWarmup: false,
            isCompleted: true,
            reps: 15,
            weight: 24.0,
            previousReps: 15,
            previousWeight: 24.0,
          ),
        ],
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Workout summary
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        workoutName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : DesignTokens.headlineMedium,
                          fontWeight: FontWeight.bold,
                          color: HevyColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: isSmallScreen ? 20 : 24),
                      color: HevyColors.textSecondary,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 320) {
                      // Stack stats vertically on very small screens
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _EditStatColumn(
                                  label: 'Duration',
                                  value: _formatDuration(duration),
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                              Expanded(
                                child: _EditStatColumn(
                                  label: 'Volume',
                                  value: '${totalVolume.toStringAsFixed(0)} kg',
                                  isSmallScreen: isSmallScreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _EditStatColumn(
                            label: 'Sets',
                            value: setsCount.toString(),
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: _EditStatColumn(
                            label: 'Duration',
                            value: _formatDuration(duration),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        Expanded(
                          child: _EditStatColumn(
                            label: 'Volume',
                            value: '${totalVolume.toStringAsFixed(0)} kg',
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                        Expanded(
                          child: _EditStatColumn(
                            label: 'Sets',
                            value: setsCount.toString(),
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(color: HevyColors.border, height: 1),
          
          // When section
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'When',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                    color: HevyColors.textSecondary,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : DesignTokens.spacingXS),
                InkWell(
                  onTap: () {
                    // TODO: Show date/time picker
                  },
                  child: Text(
                    _formatEditDate(date),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                      color: HevyColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: HevyColors.border, height: 1),
          
          // Media section
          Padding(
            padding: EdgeInsets.all(padding),
            child: InkWell(
              onTap: () {
                // TODO: Add photo/video
              },
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : DesignTokens.spacingM),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: HevyColors.border,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  color: HevyColors.surfaceElevated,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: HevyColors.textSecondary,
                      size: isSmallScreen ? 24 : DesignTokens.iconLarge,
                    ),
                    SizedBox(width: isSmallScreen ? 10 : DesignTokens.spacingM),
                    Flexible(
                      child: Text(
                        'Add a photo / video',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const Divider(color: HevyColors.border, height: 1),
          
          // Description section
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                    color: HevyColors.textSecondary,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : DesignTokens.spacingXS),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'How did your workout go? Leave some notes here...',
                    hintStyle: TextStyle(
                      color: HevyColors.textTertiary,
                      fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      borderSide: const BorderSide(color: HevyColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      borderSide: const BorderSide(color: HevyColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      borderSide: const BorderSide(
                        color: HevyColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: HevyColors.surfaceElevated,
                    contentPadding: EdgeInsets.all(isSmallScreen ? 12 : DesignTokens.spacingM),
                  ),
                  maxLines: 3,
                  style: TextStyle(
                    color: HevyColors.textPrimary,
                    fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: HevyColors.border, height: 1),
          
          // Visibility section
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Visibility',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // TODO: Show visibility options
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Everyone',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                            color: HevyColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : DesignTokens.spacingXS),
                      Icon(
                        Icons.chevron_right,
                        color: HevyColors.textSecondary,
                        size: isSmallScreen ? 16 : DesignTokens.iconSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: HevyColors.border, height: 1),
          
          // Exercises list
          ...exercises.map((exercise) => _ExerciseEditCard(
            exercise: exercise,
            isSmallScreen: isSmallScreen,
            padding: padding,
          )),
        ],
      ),
    );
  }

  String _formatEditDate(DateTime date) {
    final day = date.day;
    final month = DateFormat('MMM').format(date);
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

class _EditStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isSmallScreen;

  const _EditStatColumn({
    required this.label,
    required this.value,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : DesignTokens.bodyLarge,
            fontWeight: FontWeight.w600,
            color: label == 'Duration' ? HevyColors.primary : HevyColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
            color: HevyColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Exercise edit detail model
class _ExerciseEditDetail {
  final String name;
  final String iconAsset;
  final String notes;
  final bool restTimerEnabled;
  final List<_SetEditDetail> sets;

  _ExerciseEditDetail({
    required this.name,
    required this.iconAsset,
    required this.notes,
    required this.restTimerEnabled,
    required this.sets,
  });
}

/// Set edit detail model
class _SetEditDetail {
  final bool isWarmup;
  final bool isCompleted;
  final int reps;
  final double weight;
  final int previousReps;
  final double previousWeight;

  _SetEditDetail({
    required this.isWarmup,
    required this.isCompleted,
    required this.reps,
    required this.weight,
    required this.previousReps,
    required this.previousWeight,
  });
}

/// Exercise edit card
class _ExerciseEditCard extends StatelessWidget {
  final _ExerciseEditDetail exercise;
  final bool isSmallScreen;
  final double padding;

  const _ExerciseEditCard({
    required this.exercise,
    this.isSmallScreen = false,
    this.padding = DesignTokens.paddingScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Exercise header
          Row(
            children: [
              // Exercise icon
              Container(
                width: isSmallScreen ? 40 : 48,
                height: isSmallScreen ? 40 : 48,
                decoration: const BoxDecoration(
                  color: HevyColors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: HevyColors.textSecondary,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : DesignTokens.spacingM),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : DesignTokens.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: isSmallScreen ? 20 : 24,
                ),
                color: HevyColors.textSecondary,
                onPressed: () {
                  // TODO: Show exercise options
                },
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
          
          // Notes field
          TextField(
            decoration: InputDecoration(
              hintText: 'Add notes here...',
              hintStyle: TextStyle(
                color: HevyColors.textTertiary,
                fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                borderSide: const BorderSide(color: HevyColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                borderSide: const BorderSide(color: HevyColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                borderSide: const BorderSide(
                  color: HevyColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: HevyColors.surfaceElevated,
              contentPadding: EdgeInsets.all(isSmallScreen ? 10 : DesignTokens.spacingS),
            ),
            maxLines: 1,
            style: TextStyle(
              color: HevyColors.textPrimary,
              fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : DesignTokens.spacingS),
          
          // Rest Timer
          InkWell(
            onTap: () {
              // TODO: Toggle rest timer
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  color: HevyColors.primary,
                  size: isSmallScreen ? 16 : 18,
                ),
                SizedBox(width: isSmallScreen ? 4 : DesignTokens.spacingXS),
                Text(
                  'Rest Timer:',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                    color: HevyColors.textSecondary,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 4 : DesignTokens.spacingXS),
                Text(
                  exercise.restTimerEnabled ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                    color: HevyColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
          
          // Sets table
          Container(
            decoration: BoxDecoration(
              color: HevyColors.surfaceElevated,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Table header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : DesignTokens.spacingS),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: HevyColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'SET',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: HevyColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'PREVIOUS',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: HevyColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: isSmallScreen ? 14 : 16,
                              color: HevyColors.textSecondary,
                            ),
                            SizedBox(width: isSmallScreen ? 2 : 4),
                            Flexible(
                              child: Text(
                                'KG',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
                                  fontWeight: FontWeight.w600,
                                  color: HevyColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'REPS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: HevyColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 32 : 40), // Space for checkmark
                    ],
                  ),
                ),
                
                // Sets rows
                ...exercise.sets.asMap().entries.map((entry) {
                  final set = entry.value;
                  int setNumber = 1;
                  for (int i = 0; i < entry.key; i++) {
                    if (!exercise.sets[i].isWarmup) {
                      setNumber++;
                    }
                  }
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: set.isCompleted
                          ? HevyColors.accent.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: const Border(
                        bottom: BorderSide(color: HevyColors.border),
                      ),
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 8 : DesignTokens.spacingS),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            set.isWarmup ? 'W' : setNumber.toString(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                              fontWeight: FontWeight.w500,
                              color: set.isWarmup
                                  ? HevyColors.accentOrange
                                  : HevyColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${set.previousWeight.toStringAsFixed(0)}kg x ${set.previousReps}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : DesignTokens.bodySmall,
                              color: HevyColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            set.weight.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                              fontWeight: FontWeight.w500,
                              color: HevyColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            set.reps.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                              fontWeight: FontWeight.w500,
                              color: HevyColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (set.isCompleted)
                          Container(
                            width: isSmallScreen ? 20 : 24,
                            height: isSmallScreen ? 20 : 24,
                            decoration: const BoxDecoration(
                              color: HevyColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: isSmallScreen ? 14 : 16,
                            ),
                          )
                        else
                          SizedBox(width: isSmallScreen ? 20 : 24),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : DesignTokens.spacingM),
          
          // Add Set button (green)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : DesignTokens.spacingM),
            decoration: BoxDecoration(
              color: HevyColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: HevyColors.accent,
                  size: isSmallScreen ? 16 : 18,
                ),
                SizedBox(width: isSmallScreen ? 4 : DesignTokens.spacingXS),
                Text(
                  'Add Set',
                  style: TextStyle(
                    color: HevyColors.accent,
                    fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
