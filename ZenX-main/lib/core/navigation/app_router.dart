import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/workouts/presentation/screens/workout_list_screen.dart';
import '../../features/workouts/presentation/screens/edit_workout_screen.dart';
import '../../features/workouts/presentation/screens/create_workout_screen.dart';
import '../../features/workouts/presentation/screens/active_workout_screen.dart';
import '../../features/exercises/presentation/screens/exercise_library_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/exercises/presentation/screens/create_exercise_screen.dart';
import '../../features/exercises/presentation/screens/exercise_categories_screen.dart';
import '../../features/exercises/presentation/screens/add_exercise_screen.dart';
import '../../features/exercises/presentation/screens/select_equipment_screen.dart';
import '../../features/exercises/presentation/screens/select_muscle_screen.dart';
import '../../features/exercises/presentation/screens/select_exercise_type_screen.dart';
import '../../features/exercises/presentation/screens/leaderboard_exercises_screen.dart';
import '../../features/analytics/presentation/screens/progress_dashboard_screen.dart';
import '../../features/analytics/presentation/screens/calendar_screen.dart';
import '../../features/analytics/presentation/screens/personal_records_screen.dart';
import '../../features/analytics/presentation/screens/volume_analysis_screen.dart';
import '../../features/analytics/presentation/screens/strength_progression_screen.dart';
import '../../features/analytics/presentation/screens/set_count_per_muscle_screen.dart';
import '../../features/analytics/presentation/screens/body_distribution_screen.dart';
import '../../features/analytics/presentation/screens/muscle_distribution_screen.dart';
import '../../features/analytics/presentation/screens/october_report_screen.dart';
import '../../features/analytics/presentation/screens/main_exercises_screen.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/body_measurements_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/workout_settings_screen.dart';
import '../../features/profile/presentation/screens/sounds_settings_screen.dart';
import '../../features/analytics/presentation/screens/statistics_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/notifications_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';
import 'route_guards.dart';

/// Application router configuration
class AppRouter {
  AppRouter._();

  /// Root navigator key
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Router configuration
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/auth/login',
    redirect: RouteGuards.globalRedirect,
    routes: [
      // Authentication Flow
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/auth/login',
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Flow (Requires Authentication)
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
                // Home Tab
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: '/notifications',
                  name: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: '/search',
                  name: 'search',
                  builder: (context, state) => const SearchScreen(),
                ),

          // Workouts Tab
          GoRoute(
            path: '/workouts',
            name: 'workouts',
            builder: (context, state) => const WorkoutListScreen(),
          ),
          GoRoute(
            path: '/workouts/:id/edit',
            name: 'editWorkout',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return EditWorkoutScreen(workoutId: id);
            },
          ),
          GoRoute(
            path: '/workouts/create',
            name: 'createWorkout',
            builder: (context, state) => const CreateWorkoutScreen(),
          ),
          GoRoute(
            path: '/workouts/active',
            name: 'activeWorkout',
            builder: (context, state) {
              return const ActiveWorkoutScreen(workoutId: 'new');
            },
          ),
          GoRoute(
            path: '/workouts/:id/active',
            name: 'activeWorkoutWithId',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ActiveWorkoutScreen(workoutId: id);
            },
          ),

          // Exercises Tab
          GoRoute(
            path: '/exercises',
            name: 'exercises',
            builder: (context, state) => const ExerciseLibraryScreen(),
          ),
          GoRoute(
            path: '/exercises/:id',
            name: 'exerciseDetail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return ExerciseDetailScreen(exerciseId: id);
            },
          ),
          GoRoute(
            path: '/exercises/create',
            name: 'createExercise',
            builder: (context, state) => const CreateExerciseScreen(),
          ),
          GoRoute(
            path: '/exercises/categories',
            name: 'exerciseCategories',
            builder: (context, state) => const ExerciseCategoriesScreen(),
          ),
          GoRoute(
            path: '/exercises/add',
            name: 'addExercise',
            builder: (context, state) => const AddExerciseScreen(),
          ),
          GoRoute(
            path: '/exercises/select-equipment',
            name: 'selectEquipment',
            builder: (context, state) => const SelectEquipmentScreen(),
          ),
          GoRoute(
            path: '/exercises/select-muscle',
            name: 'selectMuscle',
            builder: (context, state) => const SelectMuscleScreen(),
          ),
          GoRoute(
            path: '/exercises/select-exercise-type',
            name: 'selectExerciseType',
            builder: (context, state) => const SelectExerciseTypeScreen(),
          ),
          GoRoute(
            path: '/exercises/select-secondary-muscles',
            name: 'selectSecondaryMuscles',
            builder: (context, state) => const SelectMuscleScreen(), // Reuse for now
          ),
          GoRoute(
            path: '/exercises/leaderboard',
            name: 'leaderboardExercises',
            builder: (context, state) => const LeaderboardExercisesScreen(),
          ),

          // Analytics Tab
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            redirect: (context, state) => '/analytics/statistics',
          ),
          GoRoute(
            path: '/analytics/dashboard',
            name: 'analyticsDashboard',
            builder: (context, state) => const ProgressDashboardScreen(),
          ),
          GoRoute(
            path: '/analytics/personal-records',
            name: 'personalRecords',
            builder: (context, state) => const PersonalRecordsScreen(),
          ),
          GoRoute(
            path: '/analytics/volume-analysis',
            name: 'volumeAnalysis',
            builder: (context, state) => const VolumeAnalysisScreen(),
          ),
          GoRoute(
            path: '/analytics/strength-progression',
            name: 'strengthProgression',
            builder: (context, state) => const StrengthProgressionScreen(),
          ),
          GoRoute(
            path: '/analytics/set-count-per-muscle',
            name: 'setCountPerMuscle',
            builder: (context, state) => const SetCountPerMuscleScreen(),
          ),
          GoRoute(
            path: '/analytics/body-distribution',
            name: 'bodyDistribution',
            builder: (context, state) => const BodyDistributionScreen(),
          ),
          GoRoute(
            path: '/analytics/muscle-distribution',
            name: 'muscleDistribution',
            builder: (context, state) => const MuscleDistributionScreen(),
          ),
          GoRoute(
            path: '/analytics/monthly-report',
            name: 'monthlyReport',
            builder: (context, state) => const OctoberReportScreen(),
          ),
          GoRoute(
            path: '/analytics/statistics',
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          GoRoute(
            path: '/analytics/main-exercises',
            name: 'mainExercises',
            builder: (context, state) => const MainExercisesScreen(),
          ),
          GoRoute(
            path: '/analytics/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
          ),

          // Profile Tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/profile/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/sounds',
            name: 'sounds',
            builder: (context, state) => const SoundsSettingsScreen(),
          ),
          GoRoute(
            path: '/profile/measurements',
            name: 'bodyMeasurements',
            builder: (context, state) => const BodyMeasurementsScreen(),
          ),
          GoRoute(
            path: '/profile/about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/workout-settings',
            name: 'workoutSettings',
            builder: (context, state) => const WorkoutSettingsScreen(),
          ),
          GoRoute(
            path: '/profile/sounds-settings',
            name: 'soundsSettings',
            builder: (context, state) => const SoundsSettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}

