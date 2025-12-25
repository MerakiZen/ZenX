import '../../../../core/domain/entity.dart';

/// App notification entity (renamed to avoid conflict with Flutter's Notification)
class AppNotification extends Entity {
  final String id;
  final NotificationType type;
  final String title;
  final String? body;
  final String? userId; // User who triggered the notification
  final String? workoutId;
  final String? postId;
  final bool read;
  final DateTime createdAt;
  final Map<String, String> data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.userId,
    this.workoutId,
    this.postId,
    this.read = false,
    required this.createdAt,
    this.data = const {},
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        userId,
        workoutId,
        postId,
        read,
        createdAt,
        data,
      ];

  factory AppNotification.fromGraphql(Map<String, dynamic> json) {
    final dataEntries = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .fold<Map<String, String>>({}, (map, entry) {
      final key = entry['key'] as String? ?? '';
      final value = entry['value'] as String? ?? '';
      if (key.isNotEmpty) {
        map[key] = value;
      }
      return map;
    });

    final template = json['template'] as String? ?? 'notification';
    final resolvedTitle =
        dataEntries['title'] ?? _deriveTitle(template, dataEntries);
    final resolvedBody =
        dataEntries['body'] ?? _deriveBody(template, dataEntries);
    final createdAtRaw =
        json['createdAt'] as String? ?? DateTime.now().toIso8601String();
    return AppNotification(
      id: json['id'] as String,
      type: NotificationTypeExt.fromTemplate(template),
      title: resolvedTitle,
      body: resolvedBody,
      userId: dataEntries['userId'],
      workoutId: dataEntries['workoutId'],
      postId: dataEntries['postId'],
      read: (json['status'] as String?) == 'read',
      createdAt: DateTime.parse(createdAtRaw).toLocal(),
      data: Map.unmodifiable(dataEntries),
    );
  }
}

/// Notification types
enum NotificationType {
  like('like'),
  comment('comment'),
  follow('follow'),
  workoutCompleted('workout_completed'),
  personalRecord('personal_record'),
  achievement('achievement'),
  mention('mention'),
  workoutShared('workout_shared');

  final String value;
  const NotificationType(this.value);
}

extension NotificationTypeExt on NotificationType {
  static NotificationType fromTemplate(String? template) {
    switch (template) {
      case 'workouts.created':
      case 'workout.reminder':
      case 'workout.summary':
        return NotificationType.workoutCompleted;
      case 'feed.like':
        return NotificationType.like;
      case 'feed.comment':
        return NotificationType.comment;
      case 'social.follow':
        return NotificationType.follow;
      case 'analytics.personal_record':
        return NotificationType.personalRecord;
      case 'achievement.unlocked':
        return NotificationType.achievement;
      default:
        return NotificationType.workoutShared;
    }
  }
}

String _deriveTitle(String template, Map<String, String> data) {
  switch (template) {
    case 'workout.summary':
      final workoutName = data['workout_name'] ?? 'Workout';
      return 'Workout logged: $workoutName';
    case 'workouts.created':
      return 'Workout completed';
    case 'feed.like':
      return '${data['user_name'] ?? 'Someone'} liked your post';
    case 'feed.comment':
      return '${data['user_name'] ?? 'Someone'} commented on your post';
    case 'social.follow':
      return '${data['user_name'] ?? 'New athlete'} started following you';
    case 'analytics.personal_record':
      return 'New personal record';
    case 'achievement.unlocked':
      return data['achievement_name'] ?? 'Achievement unlocked';
    default:
      return template.replaceAll('.', ' ').split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
  }
}

String? _deriveBody(String template, Map<String, String> data) {
  switch (template) {
    case 'workout.summary':
      final workoutName = data['workout_name'];
      final exerciseCount = data['exercise_count'];
      final totalSets = data['total_sets'];
      if (exerciseCount != null && totalSets != null) {
        return '$exerciseCount exercises · $totalSets sets';
      }
      return workoutName;
    case 'workouts.created':
      return data['notes'];
    case 'feed.like':
    case 'feed.comment':
      return data['workout_name'];
    case 'analytics.personal_record':
      return data['record_summary'];
    case 'achievement.unlocked':
      return data['description'];
    default:
      return data['message'];
  }
}
