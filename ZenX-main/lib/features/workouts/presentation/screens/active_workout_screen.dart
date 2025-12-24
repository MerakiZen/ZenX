import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../providers/workout_providers.dart';
import '../../../exercises/presentation/providers/exercise_providers.dart';
import '../../../exercises/domain/entities/exercise.dart';

/// Active workout screen - Log Workout (matches screenshot exactly)
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  DateTime? _pausedAt;
  Duration _pausedDuration = Duration.zero;
  bool _isPaused = false;
  bool _isTimerMode = false; // false = Stopwatch (default), true = Timer
  Duration _timerDuration = const Duration(minutes: 1); // Default 1 minute
  bool _timerRunning = false;
  
  final List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startStopwatch();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    if (widget.workoutId == 'new') return;

    try {
      final workout = await ref.read(workoutRepositoryProvider).fetchWorkout(widget.workoutId);
      if (workout != null && mounted) {
        setState(() {
          _exercises.clear();
          for (final ex in workout.exercises) {
            _exercises.add(
              WorkoutExercise(
                id: ex.exerciseId,
                name: ex.exercise?.name ?? 'Unknown Exercise',
                sets: ex.sets.map((s) => WorkoutSet(
                  reps: s.reps,
                  weight: s.weightKg ?? 0.0,
                  completed: false, // Start with uncompleted sets if it's a routine
                )).toList(),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load routine: ${e.toString()}'),
            backgroundColor: HevyColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    if (_timer != null) return; // Already running
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPaused) {
        setState(() {
          if (_isTimerMode && _timerRunning) {
            // Countdown timer
            final remaining = _timerDuration - _elapsed;
            if (remaining.inSeconds <= 0) {
              _timer?.cancel();
              _timerRunning = false;
              _elapsed = _timerDuration;
            } else {
              _elapsed = _elapsed + const Duration(seconds: 1);
            }
          } else {
            // Stopwatch mode
            _elapsed = DateTime.now().difference(_startTime!) + _pausedDuration;
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      if (_isPaused) {
        // Resume
        if (_pausedAt != null) {
          _pausedDuration += DateTime.now().difference(_pausedAt!);
        }
        _pausedAt = null;
        _isPaused = false;
        if (_timer == null) {
          _startStopwatch();
        }
      } else {
        // Pause
        _pausedAt = DateTime.now();
        _isPaused = true;
      }
    });
  }

  String formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _adjustTimer(int seconds) {
    setState(() {
      _timerDuration = Duration(
        seconds: (_timerDuration.inSeconds + seconds).clamp(0, 3600),
      );
    });
  }

  void _addExercise() async {
    try {
      // Show exercise selector bottom sheet with real exercises
      final selectedExercise = await showModalBottomSheet<Exercise>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _ExerciseSelectorBottomSheet(
          onExerciseSelected: (exercise) {
            Navigator.pop(context, exercise);
          },
        ),
      );
      
      // Handle the selected exercise
      if (selectedExercise != null) {
        setState(() {
          _exercises.add(
            WorkoutExercise(
              id: selectedExercise.id,
              name: selectedExercise.name,
              sets: [
                // Add initial empty set
                WorkoutSet(
                  reps: null,
                  weight: 0.0,
                  completed: false,
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add exercise: ${e.toString()}'),
            backgroundColor: HevyColors.error,
          ),
        );
      }
    }
  }

  void _showTimerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _TimerBottomSheet(
          isTimerMode: _isTimerMode,
          timerDuration: _timerDuration,
          onToggleMode: () {
            setState(() {
              _isTimerMode = !_isTimerMode;
            });
          },
          onAdjustTimer: _adjustTimer,
        ),
      ),
    );
  }

  Future<void> _finishWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise before finishing.'),
          backgroundColor: HevyColors.error,
        ),
      );
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HevyColors.surface,
        title: Text(
          'Finish Workout',
          style: TextStyle(color: HevyColors.textPrimary),
        ),
        content: Text(
          'Duration: ${formatDuration(_elapsed)}\n\nSave this workout?',
          style: TextStyle(color: HevyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: HevyColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: HevyColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: HevyColors.primary),
      ),
    );

    try {
      // Convert exercises to input format
      final exercisesInput = _exercises.asMap().entries.map((entry) {
        final index = entry.key;
        final exercise = entry.value;
        return WorkoutExerciseInput(
          exerciseId: exercise.id,
          order: index,
          sets: exercise.sets.asMap().entries.map((setEntry) {
            final setIndex = setEntry.key;
            final set = setEntry.value;
            return WorkoutSetInput(
              setNumber: setIndex + 1,
              reps: set.reps,
              weightKg: set.weight,
              completed: set.completed,
            );
          }).toList(),
        );
      }).toList();

      // Create workout
      await ref.read(workoutRepositoryProvider).createWorkout(
        name: 'Workout ${DateTime.now().toString().split(' ')[0]}',
        notes: 'Duration: ${formatDuration(_elapsed)}',
        exercises: exercisesInput,
      );

      // Refresh workout list
      ref.invalidate(workoutsProvider);

      if (!mounted) return;
      Navigator.pop(context); // Close loading
      context.pop(); // Close workout screen
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Workout saved successfully!'),
          backgroundColor: HevyColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save workout: ${e.toString()}'),
          backgroundColor: HevyColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalVolume = _exercises.fold<double>(
      0.0,
      (sum, exercise) => sum + exercise.sets.fold<double>(
        0.0,
        (setSum, set) => setSum + (set.weight * (set.reps ?? 0)),
      ),
    );
    final totalSets = _exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );

    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: AppBar(
        backgroundColor: HevyColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          color: HevyColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Log Workout',
          style: TextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w600,
            color: HevyColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showTimerBottomSheet(context),
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: HevyColors.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    border: Border.all(color: HevyColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.timer_outlined,
                      color: HevyColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: DesignTokens.paddingScreen,
              left: DesignTokens.spacingS,
              top: DesignTokens.spacingS,
              bottom: DesignTokens.spacingS,
            ),
            child: ElevatedButton(
              onPressed: _finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: HevyColors.primary,
                foregroundColor: HevyColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Finish',
                style: TextStyle(
                  fontSize: DesignTokens.bodyLarge,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _exercises.isEmpty
          ? _EmptyWorkoutState(
              onAddExercise: _addExercise,
              duration: _elapsed,
              volume: totalVolume,
              sets: totalSets,
            )
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.paddingScreen),
              children: [
                // Metrics
                _WorkoutMetrics(
                  duration: _elapsed,
                  volume: totalVolume,
                  sets: totalSets,
                ),
                const SizedBox(height: DesignTokens.spacingXL),
                // Clock section
                _ClockSection(
                  isTimerMode: _isTimerMode,
                  timerDuration: _timerDuration,
                  onToggleMode: () {
                    setState(() {
                      _isTimerMode = !_isTimerMode;
                    });
                  },
                  onAdjustTimer: _adjustTimer,
                ),
                const SizedBox(height: DesignTokens.spacingXL),
                // Exercise list
                ..._exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return _ExerciseCard(
                    exercise: exercise,
                    exerciseIndex: index,
                    onAddSet: () => _addSet(index),
                    onUpdateSet: (setIndex, reps, weight) =>
                        _updateSet(index, setIndex, reps, weight),
                    onToggleComplete: (setIndex) =>
                        _toggleSetComplete(index, setIndex),
                  );
                }),
                const SizedBox(height: DesignTokens.spacingM),
                OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
    );
  }

  void _addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    
    setState(() {
      final exercise = _exercises[exerciseIndex];
      final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
      exercise.sets.add(WorkoutSet(
        reps: lastSet?.reps,
        weight: lastSet?.weight ?? 0.0,
        completed: false,
      ));
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    if (setIndex < 0 || setIndex >= _exercises[exerciseIndex].sets.length) return;
    
    setState(() {
      _exercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, int? reps, double? weight) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    if (setIndex < 0 || setIndex >= _exercises[exerciseIndex].sets.length) return;
    
    setState(() {
      final set = _exercises[exerciseIndex].sets[setIndex];
      if (reps != null) set.reps = reps;
      if (weight != null) set.weight = weight;
    });
  }

  void _toggleSetComplete(int exerciseIndex, int setIndex) {
    setState(() {
      _exercises[exerciseIndex].sets[setIndex].completed =
          !_exercises[exerciseIndex].sets[setIndex].completed;
    });
  }
}

class _WorkoutMetrics extends StatelessWidget {
  final Duration duration;
  final double volume;
  final int sets;

  const _WorkoutMetrics({
    required this.duration,
    required this.volume,
    required this.sets,
  });

  String formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingL),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: HevyColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              label: 'Duration',
              value: formatDuration(duration),
              valueColor: HevyColors.primary,
              alignStart: true,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: HevyColors.border,
          ),
          Expanded(
            child: _MetricItem(
              label: 'Volume',
              value: '${volume.toStringAsFixed(0)} kg',
              alignStart: true,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: HevyColors.border,
          ),
          Expanded(
            child: _MetricItem(
              label: 'Sets',
              value: sets.toString(),
              alignStart: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignStart;

  const _MetricItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: DesignTokens.bodySmall,
            color: HevyColors.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXXS),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTokens.titleMedium,
            fontWeight: FontWeight.w600,
            color: valueColor ?? HevyColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ClockSection extends StatelessWidget {
  final bool isTimerMode;
  final Duration timerDuration;
  final VoidCallback onToggleMode;
  final Function(int) onAdjustTimer;

  const _ClockSection({
    required this.isTimerMode,
    required this.timerDuration,
    required this.onToggleMode,
    required this.onAdjustTimer,
  });

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HevyColors.surfaceElevated,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 18,
                  color: HevyColors.textSecondary,
                ),
                const SizedBox(width: DesignTokens.spacingS),
                const Text(
                  'Clock',
                  style: TextStyle(
                    fontSize: DesignTokens.titleMedium,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingM),
            // Timer/Stopwatch toggle
            Row(
              children: [
                Expanded(
                  child: _ModeToggle(
                    label: 'Timer',
                    isSelected: isTimerMode,
                    onTap: () {
                      if (!isTimerMode) onToggleMode();
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: _ModeToggle(
                    label: 'Stopwatch',
                    isSelected: !isTimerMode,
                    onTap: () {
                      if (isTimerMode) onToggleMode();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingXL),
            // Circular timer
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HevyColors.primary,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatTimer(timerDuration),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),
            // Adjust buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => onAdjustTimer(-15),
                  child: const Text(
                    '-15s',
                    style: TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      color: HevyColors.primary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Start timer
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HevyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onAdjustTimer(15),
                  child: const Text(
                    '+15s',
                    style: TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      color: HevyColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        decoration: BoxDecoration(
          color: isSelected ? HevyColors.primary : HevyColors.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: DesignTokens.bodyMedium,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : HevyColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty workout state - matches screenshot exactly
class _EmptyWorkoutState extends StatelessWidget {
  final VoidCallback onAddExercise;
  final Duration duration;
  final double volume;
  final int sets;

  const _EmptyWorkoutState({
    required this.onAddExercise,
    required this.duration,
    required this.volume,
    required this.sets,
  });

  String formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
      child: Column(
        children: [
          _WorkoutMetrics(
            duration: duration,
            volume: volume,
            sets: sets,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HevyColors.surfaceElevated,
                    border: Border.all(
                      color: HevyColors.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: HevyColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXL),
                const Text(
                  'Get started',
                  style: TextStyle(
                    fontSize: DesignTokens.titleLarge,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                Text(
                  'Add an exercise to start your workout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: DesignTokens.bodyMedium,
                    color: HevyColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddExercise,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add Exercise',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: DesignTokens.bodyLarge,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HevyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacingL,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXL),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to workout settings
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text(
                    'Settings',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                    foregroundColor: HevyColors.textPrimary,
                    side: const BorderSide(color: HevyColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Discard Workout?'),
                        content: const Text(
                          'Are you sure you want to discard this workout? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Navigate back and discard workout
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: HevyColors.error,
                            ),
                            child: const Text('Discard'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
                    foregroundColor: HevyColors.error,
                    side: const BorderSide(color: HevyColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }
}

/// Exercise card widget
class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final int exerciseIndex;
  final VoidCallback onAddSet;
  final Function(int, int?, double?) onUpdateSet;
  final Function(int) onToggleComplete;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HevyColors.surfaceElevated,
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: DesignTokens.titleMedium,
                fontWeight: FontWeight.w600,
                color: HevyColors.textPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingM),
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _SetRow(
                set: set,
                setIndex: index,
                onUpdate: (reps, weight) => onUpdateSet(index, reps, weight),
                onToggleComplete: () => onToggleComplete(index),
              );
            }),
            const SizedBox(height: DesignTokens.spacingS),
            OutlinedButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Set'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final WorkoutSet set;
  final int setIndex;
  final Function(int?, double?) onUpdate;
  final VoidCallback onToggleComplete;

  const _SetRow({
    required this.set,
    required this.setIndex,
    required this.onUpdate,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                fontSize: DesignTokens.bodyMedium,
                color: HevyColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Reps',
                hintStyle: const TextStyle(color: HevyColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final reps = int.tryParse(value);
                onUpdate(reps, set.weight);
              },
            ),
          ),
          const SizedBox(width: DesignTokens.spacingS),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Weight',
                hintStyle: const TextStyle(color: HevyColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final weight = double.tryParse(value);
                onUpdate(set.reps, weight);
              },
            ),
          ),
          const SizedBox(width: DesignTokens.spacingS),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: set.completed,
              onChanged: (_) => onToggleComplete(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data models (temporary - will be replaced with actual entities)
class WorkoutExercise {
  final String id;
  final String name;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
  });
}

class WorkoutSet {
  int? reps;
  double weight;
  bool completed;

  WorkoutSet({
    this.reps,
    required this.weight,
    required this.completed,
  });
}

/// Timer bottom sheet widget
class _TimerBottomSheet extends StatelessWidget {
  final bool isTimerMode;
  final Duration timerDuration;
  final VoidCallback onToggleMode;
  final Function(int) onAdjustTimer;

  const _TimerBottomSheet({
    required this.isTimerMode,
    required this.timerDuration,
    required this.onToggleMode,
    required this.onAdjustTimer,
  });

  String _formatTimer(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HevyColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXL),
          topRight: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HevyColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Clock section card
                Card(
                  color: HevyColors.surfaceElevated,
                  margin: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clock header with gear icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings,
                              size: 18,
                              color: HevyColors.textSecondary,
                            ),
                            const SizedBox(width: DesignTokens.spacingS),
                            const Text(
                              'Clock',
                              style: TextStyle(
                                fontSize: DesignTokens.titleMedium,
                                fontWeight: FontWeight.w600,
                                color: HevyColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacingM),
                        // Timer/Stopwatch toggle
                        Row(
                          children: [
                            Expanded(
                              child: _ModeToggle(
                                label: 'Timer',
                                isSelected: isTimerMode,
                                onTap: () {
                                  if (!isTimerMode) onToggleMode();
                                },
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spacingS),
                            Expanded(
                              child: _ModeToggle(
                                label: 'Stopwatch',
                                isSelected: !isTimerMode,
                                onTap: () {
                                  if (isTimerMode) onToggleMode();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacingXL),
                        // Circular timer display with adjustment buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // -15s button on the left
                            TextButton(
                              onPressed: () => onAdjustTimer(-15),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingM),
                              ),
                              child: const Text(
                                '-15s',
                                style: TextStyle(
                                  fontSize: DesignTokens.bodyLarge,
                                  color: HevyColors.primary,
                                ),
                              ),
                            ),
                            // Circular timer
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: HevyColors.primary,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _formatTimer(timerDuration),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w300,
                                    color: HevyColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            // +15s button on the right
                            TextButton(
                              onPressed: () => onAdjustTimer(15),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingM),
                              ),
                              child: const Text(
                                '+15s',
                                style: TextStyle(
                                  fontSize: DesignTokens.bodyLarge,
                                  color: HevyColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacingXL),
                        // Start button - full width
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Timer functionality can be added here
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HevyColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingL),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: DesignTokens.bodyLarge,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.paddingScreen),
              ],
            ),
      ),
    );
  }
}

/// Exercise selector bottom sheet widget
class _ExerciseSelectorBottomSheet extends ConsumerStatefulWidget {
  final Function(Exercise) onExerciseSelected;

  const _ExerciseSelectorBottomSheet({
    required this.onExerciseSelected,
  });

  @override
  ConsumerState<_ExerciseSelectorBottomSheet> createState() => _ExerciseSelectorBottomSheetState();
}

class _ExerciseSelectorBottomSheetState extends ConsumerState<_ExerciseSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final exercisesAsync = _searchQuery.isNotEmpty
        ? ref.watch(searchExercisesProvider(_searchQuery))
        : ref.watch(exercisesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8,
      ),
      decoration: BoxDecoration(
        color: HevyColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXL),
          topRight: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HevyColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingScreen,
              vertical: DesignTokens.spacingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Exercise',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: HevyColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            color: HevyColors.border,
            height: 1,
            thickness: 0.5,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(DesignTokens.paddingScreen),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(color: HevyColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(color: HevyColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  borderSide: BorderSide(color: HevyColors.primary, width: 2),
                ),
                filled: true,
                fillColor: HevyColors.surface,
              ),
            ),
          ),
          // Exercise list
          Flexible(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                      child: Text(
                        'No exercises found',
                        style: TextStyle(color: HevyColors.textSecondary),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.paddingScreen),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return InkWell(
                      onTap: () {
                        widget.onExerciseSelected(exercise);
                      },
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.spacingM,
                          horizontal: DesignTokens.spacingS,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: HevyColors.border,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: HevyColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: HevyColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: HevyColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise.primaryMuscleGroup ?? 'Unknown',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HevyColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: HevyColors.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignTokens.paddingScreen),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.paddingScreen),
                  child: Text(
                    'Error loading exercises: ${error.toString()}',
                    style: TextStyle(color: HevyColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
