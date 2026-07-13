import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/notifications/view_models/notifications_view_model.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({
    required this.viewModel,
    required this.onBack,
    super.key,
  });

  final NotificationsViewModel viewModel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ColoredBox(
          color: const Color(0xFFF5F7FA),
          child: SafeArea(
            child: Column(
              children: [
                _NotificationsHeader(
                  onBack: onBack,
                  onMarkAllRead: viewModel.unreadCount == 0
                      ? null
                      : () => viewModel.markAllRead(),
                ),
                Expanded(child: _NotificationsBody(viewModel: viewModel)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.onBack,
    required this.onMarkAllRead,
  });

  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('notifications_back_button'),
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Notifications',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            key: const Key('notifications_mark_all_read'),
            onPressed: onMarkAllRead,
            child: const Text(
              'MARK ALL AS READ',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.viewModel});

  final NotificationsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading && !viewModel.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final errorMessage = viewModel.errorMessage;
    if (errorMessage != null && viewModel.notifications.isEmpty) {
      return _NotificationState(
        icon: Icons.wifi_off_rounded,
        title: errorMessage,
        buttonLabel: 'Retry',
        onPressed: viewModel.load,
      );
    }

    if (viewModel.notifications.isEmpty) {
      return const _NotificationState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet.',
      );
    }

    return ListView(
      key: const Key('notifications_list'),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
      children: [
        const _SectionHeader(),
        const SizedBox(height: 16),
        for (final notification in viewModel.notifications) ...[
          _NotificationCard(
            notification: notification,
            onTap: () => viewModel.markRead(notification.id),
          ),
          const SizedBox(height: 10),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'TODAY',
          style: TextStyle(
            color: AppColors.gray600,
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        SizedBox(width: 22),
        Expanded(child: Divider(color: Color(0xFFC7D2E2))),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(notification.title);
    final accent = _accentFor(notification.title);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0ECFF)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _relativeTime(notification.createdAt),
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!notification.isRead)
                    Container(
                      key: Key('notification_unread_dot_${notification.id}'),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('confirmed')) {
      return Icons.check_circle_rounded;
    }
    if (normalized.contains('payment')) {
      return Icons.schedule_rounded;
    }
    return Icons.local_offer_rounded;
  }

  static Color _accentFor(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('confirmed')) {
      return const Color(0xFF34A853);
    }
    if (normalized.contains('payment')) {
      return const Color(0xFFE89C18);
    }
    return const Color(0xFFB06A21);
  }

  static String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final normalized = createdAt.isUtc ? createdAt.toLocal() : createdAt;
    final difference = now.difference(normalized);
    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }
}

class _NotificationState extends StatelessWidget {
  const _NotificationState({
    required this.icon,
    required this.title,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.gray500, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onPressed, child: Text(buttonLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
