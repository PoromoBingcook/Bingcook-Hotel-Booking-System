import 'package:bingcook/domain/models/notification_item.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationItem>> fetchNotifications();

  Future<void> markRead(String notificationId);

  Future<void> markAllRead();
}

class NotificationRepositoryException implements Exception {
  const NotificationRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
