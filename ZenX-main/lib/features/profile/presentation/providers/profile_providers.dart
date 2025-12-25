import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';

class ProfileDetails {
  const ProfileDetails({
    required this.id,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.workoutCount,
    this.totalVolumeKg,
    this.streakDays,
  });

  final String id;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final int? workoutCount;
  final double? totalVolumeKg;
  final int? streakDays;
}

class MeasurementPoint {
  const MeasurementPoint({
    required this.measurementDate,
    this.weightKg,
    this.bodyFatPercentage,
    this.muscleMassKg,
    this.extra,
  });

  final DateTime measurementDate;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? muscleMassKg;
  final Map<String, dynamic>? extra;
}

class ProfileViewData {
  const ProfileViewData({
    required this.profile,
    required this.measurements,
    required this.recentWorkouts,
  });

  final ProfileDetails profile;
  final List<MeasurementPoint> measurements;
  final List<Workout> recentWorkouts;
}

final profileViewProvider =
    FutureProvider.autoDispose<ProfileViewData>((ref) async {
  final client = ref.watch(graphqlProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 90));

  final result = await client.query(
    QueryOptions(
      document: gql(GraphQLQueries.profileOverview),
      fetchPolicy: FetchPolicy.networkOnly,
      variables: {
        'range': {
          'start': _formatDate(start),
          'end': _formatDate(now),
        },
      },
    ),
  );

  if (result.hasException) {
    // If unauthorized or any error, return empty profile instead of throwing
    final errors = result.exception?.graphqlErrors ?? [];
    final exceptionMessage = result.exception?.toString().toLowerCase() ?? '';
    if (errors.any((e) => e.message.toLowerCase().contains('unauthorized')) ||
        exceptionMessage.contains('unauthorized') ||
        exceptionMessage.contains('linkexception') ||
        exceptionMessage.contains('network')) {
      return ProfileViewData(
        profile: const ProfileDetails(id: ''),
        measurements: [],
        recentWorkouts: [],
      );
    }
    // Log other errors but still return empty profile to prevent UI crash
    print('Error fetching profile: ${result.exception}');
    return ProfileViewData(
      profile: const ProfileDetails(id: ''),
      measurements: [],
      recentWorkouts: [],
    );
  }

  final profileJson =
      result.data?['profile'] as Map<String, dynamic>? ?? <String, dynamic>{};
  final profile = ProfileDetails(
    id: profileJson['id'] as String? ?? '',
    displayName: profileJson['displayName'] as String?,
    bio: profileJson['bio'] as String?,
    avatarUrl: profileJson['avatarUrl'] as String?,
    dateOfBirth: profileJson['dateOfBirth'] as String?,
    gender: profileJson['gender'] as String?,
    workoutCount: result.data?['progressSnapshot']?['workoutCount'] as int?,
    totalVolumeKg: _toDouble(result.data?['progressSnapshot']?['totalVolumeKg']),
    streakDays: profileJson['streakDays'] as int?,
  );

  final measurementsJson =
      (result.data?['measurements'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();

  final measurements = measurementsJson
      .map(
        (json) => MeasurementPoint(
          measurementDate: _parseDate(json['measurementDate'] as String? ?? ''),
          weightKg: _toDouble(json['weightKg']),
          bodyFatPercentage: _toDouble(json['bodyFatPercentage']),
          muscleMassKg: _toDouble(json['muscleMassKg']),
          extra: _parseExtra(json['measurementsJson'] as String?),
        ),
      )
      .where((point) =>
          point.measurementDate != DateTime.fromMillisecondsSinceEpoch(0))
      .toList()
    ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

  final workouts = await ref.read(workoutRepositoryProvider).fetchWorkouts(limit: 10);

  return ProfileViewData(
    profile: profile,
    measurements: measurements,
    recentWorkouts: workouts,
  );
});

final profileControllerProvider = Provider(ProfileController.new);

class ProfileController {
  ProfileController(this._ref);

  final Ref _ref;

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) {
      payload['displayName'] = displayName;
    }
    if (bio != null) {
      payload['bio'] = bio;
    }
    if (avatarUrl != null) {
      payload['avatarUrl'] = avatarUrl;
    }
    if (dateOfBirth != null) {
      payload['dateOfBirth'] = dateOfBirth;
    }
    if (gender != null) {
      payload['gender'] = gender;
    }

    final client = _ref.read(graphqlProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(GraphQLQueries.updateProfile),
        variables: {'input': payload},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    _ref.invalidate(profileViewProvider);
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime _parseDate(String value) {
  if (value.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  try {
    return DateTime.parse(value);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

Map<String, dynamic>? _parseExtra(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
