import '../../../../core/domain/entity.dart';
import '../../../workouts/domain/entities/workout.dart';
import '../../../auth/domain/entities/user.dart';

/// Workout post entity - combines workout with social features
class WorkoutPost extends Entity {
  final String id;
  final String workoutId;
  final Workout workout;
  final User author;
  final String? imageUrl;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final List<String> likedByUserIds; // First few user IDs who liked
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutPost({
    required this.id,
    required this.workoutId,
    required this.workout,
    required this.author,
    this.imageUrl,
    this.caption,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.likedByUserIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        workoutId,
        workout,
        author,
        imageUrl,
        caption,
        likesCount,
        commentsCount,
        isLiked,
        likedByUserIds,
        createdAt,
        updatedAt,
      ];

  factory WorkoutPost.fromGraphql(Map<String, dynamic> json) {
    DateTime _parseDate(String? value) =>
        value == null || value.isEmpty ? DateTime.now() : DateTime.parse(value).toLocal();
    DateTime? _parseOptionalDate(String? value) =>
        value == null || value.isEmpty ? null : DateTime.parse(value).toLocal();

    final workoutJson = (json['workout'] as Map<String, dynamic>?) ?? {};
    final profileJson = json['authorProfile'] as Map<String, dynamic>?;
    final startedAt = _parseOptionalDate(workoutJson['startedAt'] as String?);
    final completedAt = _parseOptionalDate(workoutJson['completedAt'] as String?);

    final workout = Workout(
      id: workoutJson['id'] as String? ?? json['workoutId'] as String,
      userId: workoutJson['userId'] as String? ?? json['userId'] as String,
      name: workoutJson['name'] as String?,
      notes: workoutJson['notes'] as String?,
      startedAt: startedAt,
      completedAt: completedAt,
      durationSeconds: _deriveDuration(startedAt, completedAt),
      totalVolumeKg: null,
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String? ?? json['createdAt'] as String?),
    );

    final author = User(
      id: json['userId'] as String,
      email: '${json['userId']}@zenx.local',
      name: (profileJson?['displayName'] as String?)?.trim().isNotEmpty == true
          ? profileJson!['displayName'] as String
          : 'ZenX Athlete',
      avatarUrl: profileJson?['avatarUrl'] as String?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return WorkoutPost(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      workout: workout,
      author: author,
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      likedByUserIds: (json['likedByUserIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String? ?? json['createdAt'] as String?),
    );
  }
}

int? _deriveDuration(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return null;
  }
  return end.difference(start).inSeconds.abs();
}







