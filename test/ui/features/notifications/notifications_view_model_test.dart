import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:bingcook/ui/features/notifications/view_models/notifications_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationsViewModel', () {
    test('loads notifications and computes unread count', () async {
      final repository = FakeNotificationRepository();
      final viewModel = NotificationsViewModel(
        notificationRepository: repository,
      );

      await viewModel.load();

      expect(viewModel.notifications.length, 2);
      expect(viewModel.unreadCount, 1);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('markRead updates one notification after repository succeeds', () async {
      final repository = FakeNotificationRepository();
      final viewModel = NotificationsViewModel(
        notificationRepository: repository,
      );
      await viewModel.load();

      await viewModel.markRead('notification-1');

      expect(repository.markedId, 'notification-1');
      expect(viewModel.notifications.first.isRead, isTrue);
      expect(viewModel.unreadCount, 0);
    });

    test('markAllRead updates all notifications after repository succeeds', () async {
      final repository = FakeNotificationRepository();
      final viewModel = NotificationsViewModel(
        notificationRepository: repository,
      );
      await viewModel.load();

      await viewModel.markAllRead();

      expect(repository.markAllReadCalled, isTrue);
      expect(viewModel.notifications.every((item) => item.isRead), isTrue);
      expect(viewModel.unreadCount, 0);
    });
  });
}

class FakeNotificationRepository implements NotificationRepository {
  String? markedId;
  bool markAllReadCalled = false;

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    return [
      NotificationItem(
        id: 'notification-1',
        title: 'Booking Confirmed',
        message: 'Your stay at Ocean Pearl Hotel is confirmed.',
        isRead: false,
        createdAt: DateTime(2026, 7, 13, 9, 20),
      ),
      NotificationItem(
        id: 'notification-2',
        title: 'Special Offer',
        message: 'Get 20% off your next booking.',
        isRead: true,
        createdAt: DateTime(2026, 7, 12, 8),
      ),
    ];
  }

  @override
  Future<void> markAllRead() async {
    markAllReadCalled = true;
  }

  @override
  Future<void> markRead(String notificationId) async {
    markedId = notificationId;
  }
}
