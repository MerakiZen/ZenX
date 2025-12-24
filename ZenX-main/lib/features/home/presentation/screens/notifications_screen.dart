import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../domain/entities/notification.dart' as notification_entity;
import '../providers/feed_providers.dart';

/// Notifications screen (Hevy Pro style)
class NotificationsScreen extends BaseScreen {
  const NotificationsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) => RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: notifications.isEmpty
            ? const _NotificationsEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationItem(
                    notification: notification,
                    onTap: () =>
                        _handleNotificationTap(context, ref, notification),
                  );
                },
              ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _NotificationsErrorState(
        onRetry: () => ref.refresh(notificationsProvider.future),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    notification_entity.AppNotification notification,
  ) async {
    try {
      await ref
          .read(feedRepositoryProvider)
          .markNotificationRead(notification.id);
      ref.invalidate(notificationsProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update notification. Please try again.'),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    if (notification.workoutId != null) {
      context.push('/workouts/${notification.workoutId}');
    } else if (notification.postId != null) {
      context.push('/feed/${notification.postId}');
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final notification_entity.AppNotification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType(notification_entity.NotificationType type) {
    switch (type) {
      case notification_entity.NotificationType.like:
        return Icons.thumb_up;
      case notification_entity.NotificationType.comment:
        return Icons.comment;
      case notification_entity.NotificationType.follow:
        return Icons.person_add;
      case notification_entity.NotificationType.workoutCompleted:
        return Icons.check_circle;
      case notification_entity.NotificationType.personalRecord:
        return Icons.emoji_events;
      case notification_entity.NotificationType.achievement:
        return Icons.star;
      case notification_entity.NotificationType.mention:
        return Icons.alternate_email;
      case notification_entity.NotificationType.workoutShared:
        return Icons.share;
    }
  }

  Color _getIconColorForType(notification_entity.NotificationType type) {
    switch (type) {
      case notification_entity.NotificationType.like:
        return Colors.blue;
      case notification_entity.NotificationType.comment:
        return Colors.green;
      case notification_entity.NotificationType.follow:
        return HevyColors.primary;
      case notification_entity.NotificationType.workoutCompleted:
        return Colors.green;
      case notification_entity.NotificationType.personalRecord:
        return Colors.orange;
      case notification_entity.NotificationType.achievement:
        return Colors.amber;
      case notification_entity.NotificationType.mention:
        return Colors.purple;
      case notification_entity.NotificationType.workoutShared:
        return Colors.blue;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.paddingScreen,
          vertical: DesignTokens.spacingM,
        ),
        decoration: BoxDecoration(
          color: notification.read
              ? Colors.transparent
              : HevyColors.surfaceElevated.withValues(alpha: 0.3),
          border: const Border(
            bottom: BorderSide(color: HevyColors.border, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getIconColorForType(notification.type)
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: _getIconColorForType(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: DesignTokens.bodyLarge,
                      fontWeight:
                          notification.read ? FontWeight.w400 : FontWeight.w600,
                      color: HevyColors.textPrimary,
                    ),
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: const TextStyle(
                        fontSize: DesignTokens.bodySmall,
                        color: HevyColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(notification.createdAt),
                    style: const TextStyle(
                      fontSize: DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: HevyColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 120),
              Icon(
                Icons.notifications_none,
                size: 80,
                color: HevyColors.textSecondary,
              ),
              SizedBox(height: DesignTokens.spacingXL),
              Text(
                'No recent notifications',
                style: TextStyle(
                  fontSize: DesignTokens.titleLarge,
                  fontWeight: FontWeight.w600,
                  color: HevyColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignTokens.spacingM),
              Text(
                'We will notify you when you have new activity.',
                style: TextStyle(
                  fontSize: DesignTokens.bodyMedium,
                  color: HevyColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _NotificationsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: HevyColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DesignTokens.spacingL),
          const Text(
            'Unable to load notifications',
            style: TextStyle(
              fontSize: DesignTokens.bodyLarge,
              color: HevyColors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
