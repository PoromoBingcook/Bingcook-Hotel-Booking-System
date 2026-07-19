import 'package:bingcook/data/models/notification_api_models.dart';
import 'package:bingcook/data/repositories/api_notification_repository.dart';
import 'package:bingcook/data/services/notification_api_service.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiNotificationRepository', () {
    test('fetches notifications with current session token', () async {
      final service = FakeNotificationApiService();
      final repository = ApiNotificationRepository(
        notificationApiService: service,
        authRepository: FakeAuthRepository(),
      );

      final notifications = await repository.fetchNotifications();

      expect(service.lastToken, 'jwt-token');
      expect(notifications.single.title, 'Booking Confirmed');
      expect(notifications.single.isRead, isFalse);
    });

    test('marks a notification read with current session token', () async {
      final service = FakeNotificationApiService();
      final repository = ApiNotificationRepository(
        notificationApiService: service,
        authRepository: FakeAuthRepository(),
      );

      await repository.markRead('notification-1');

      expect(service.lastToken, 'jwt-token');
      expect(service.lastMarkedId, 'notification-1');
    });

    test('throws repository exception when user is not authenticated', () {
      final repository = ApiNotificationRepository(
        notificationApiService: FakeNotificationApiService(),
        authRepository: FakeAuthRepository.unauthenticated(),
      );

      expect(
        repository.fetchNotifications,
        throwsA(
          isA<NotificationRepositoryException>().having(
            (error) => error.message,
            'message',
            'Please login to view notifications.',
          ),
        ),
      );
    });
  });
}

class FakeNotificationApiService implements NotificationApiService {
  String? lastToken;
  String? lastMarkedId;

  @override
  Future<List<NotificationResponse>> fetchNotifications({
    required String token,
  }) async {
    lastToken = token;
    return [
      NotificationResponse(
        id: 'notification-1',
        title: 'Booking Confirmed',
        message: 'Your stay at Ocean Pearl Hotel is confirmed.',
        isRead: false,
        createdAt: DateTime(2026, 7, 13, 9, 20),
      ),
    ];
  }

  @override
  Future<void> markAllRead({required String token}) async {
    lastToken = token;
  }

  @override
  Future<void> markRead({
    required String token,
    required String notificationId,
  }) async {
    lastToken = token;
    lastMarkedId = notificationId;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _session = _defaultSession;

  const FakeAuthRepository.unauthenticated() : _session = null;

  final AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _defaultSession;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {}

  static final _defaultSession = AuthSession(
    token: 'jwt-token',
    user: AuthUser(
      id: 'c38d653b-3a56-49cf-9473-22edaa5f3a2c',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '+84901234567',
      role: 'Customer',
    ),
  );
}
