import 'package:bingcook/data/services/notification_api_service.dart';
import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  const ApiNotificationRepository({
    required NotificationApiService notificationApiService,
    required AuthRepository authRepository,
  }) : _notificationApiService = notificationApiService,
       _authRepository = authRepository;

  final NotificationApiService _notificationApiService;
  final AuthRepository _authRepository;

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final response = await _notificationApiService.fetchNotifications(
        token: _token(),
      );
      return response.map((item) => item.toDomain()).toList(growable: false);
    } on NotificationRepositoryException {
      rethrow;
    } on NotificationApiException catch (error) {
      throw NotificationRepositoryException(error.message);
    } on FormatException {
      throw const NotificationRepositoryException(
        'Unable to read notifications.',
      );
    } catch (_) {
      throw const NotificationRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await _notificationApiService.markRead(
        token: _token(),
        notificationId: notificationId,
      );
    } on NotificationRepositoryException {
      rethrow;
    } on NotificationApiException catch (error) {
      throw NotificationRepositoryException(error.message);
    } catch (_) {
      throw const NotificationRepositoryException(
        'Unable to update notification.',
      );
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _notificationApiService.markAllRead(token: _token());
    } on NotificationRepositoryException {
      rethrow;
    } on NotificationApiException catch (error) {
      throw NotificationRepositoryException(error.message);
    } catch (_) {
      throw const NotificationRepositoryException(
        'Unable to update notifications.',
      );
    }
  }

  String _token() {
    final token = _authRepository.currentSession?.token;
    if (token == null || token.isEmpty) {
      throw const NotificationRepositoryException(
        'Please login to view notifications.',
      );
    }
    return token;
  }
}
