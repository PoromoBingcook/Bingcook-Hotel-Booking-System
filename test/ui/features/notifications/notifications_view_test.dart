import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:bingcook/ui/features/notifications/view_models/notifications_view_model.dart';
import 'package:bingcook/ui/features/notifications/views/notifications_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders notifications and marks all as read', (tester) async {
    final repository = FakeNotificationRepository();
    final viewModel = NotificationsViewModel(
      notificationRepository: repository,
    );
    await viewModel.load();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsView(viewModel: viewModel, onBack: () {}),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Booking Confirmed'), findsOneWidget);
    expect(find.byKey(const Key('notification_unread_dot_notification-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('notifications_mark_all_read')));
    await tester.pump();

    expect(repository.markAllReadCalled, isTrue);
    expect(find.byKey(const Key('notification_unread_dot_notification-1')), findsNothing);
  });

  testWidgets('renders empty state', (tester) async {
    final viewModel = NotificationsViewModel(
      notificationRepository: FakeNotificationRepository.empty(),
    );
    await viewModel.load();

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsView(viewModel: viewModel, onBack: () {}),
      ),
    );

    expect(find.text('No notifications yet.'), findsOneWidget);
  });
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository() : _notifications = _defaultNotifications;

  FakeNotificationRepository.empty() : _notifications = const [];

  final List<NotificationItem> _notifications;
  bool markAllReadCalled = false;

  @override
  Future<List<NotificationItem>> fetchNotifications() async => _notifications;

  @override
  Future<void> markAllRead() async {
    markAllReadCalled = true;
  }

  @override
  Future<void> markRead(String notificationId) async {}

  static final _defaultNotifications = [
    NotificationItem(
      id: 'notification-1',
      title: 'Booking Confirmed',
      message: 'Your stay at Ocean Pearl Hotel is confirmed for Jul 13.',
      isRead: false,
      createdAt: DateTime(2026, 7, 13, 9, 20),
    ),
  ];
}
