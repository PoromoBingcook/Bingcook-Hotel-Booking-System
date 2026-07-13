import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:flutter/foundation.dart';

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository;

  final NotificationRepository _notificationRepository;
  List<NotificationItem> _notifications = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.fetchNotifications();
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    } on NotificationRepositoryException catch (error) {
      _errorMessage = error.message;
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Unable to load notifications.';
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  Future<void> markRead(String notificationId) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index == -1 || _notifications[index].isRead) {
      return;
    }

    try {
      await _notificationRepository.markRead(notificationId);
      _notifications = [
        for (var i = 0; i < _notifications.length; i++)
          i == index ? _notifications[i].copyWith(isRead: true) : _notifications[i],
      ];
      _errorMessage = null;
      notifyListeners();
    } on NotificationRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Unable to update notification.';
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) {
      return;
    }

    try {
      await _notificationRepository.markAllRead();
      _notifications = [
        for (final notification in _notifications)
          notification.copyWith(isRead: true),
      ];
      _errorMessage = null;
      notifyListeners();
    } on NotificationRepositoryException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Unable to update notifications.';
      notifyListeners();
    }
  }
}
