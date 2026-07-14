import 'package:bingcook/data/services/notification_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotificationApiService', () {
    test('fetches authenticated notifications', () async {
      http.Request? capturedRequest;
      final service = NotificationApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
[
  {
    "id": "notification-1",
    "title": "Booking Confirmed",
    "message": "Your stay at Ocean Pearl Hotel is confirmed.",
    "isRead": false,
    "createdAt": "2026-07-13T09:20:00Z"
  }
]
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final notifications = await service.fetchNotifications(
        token: 'jwt-token',
      );

      expect(capturedRequest!.method, 'GET');
      expect(capturedRequest!.url.path, '/api/notifications');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      expect(notifications.single.title, 'Booking Confirmed');
      expect(notifications.single.isRead, isFalse);
    });

    test('marks a notification read', () async {
      http.Request? capturedRequest;
      final service = NotificationApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      await service.markRead(
        token: 'jwt-token',
        notificationId: 'notification-1',
      );

      expect(capturedRequest!.method, 'POST');
      expect(
        capturedRequest!.url.path,
        '/api/notifications/notification-1/read',
      );
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
    });

    test('marks all notifications read', () async {
      http.Request? capturedRequest;
      final service = NotificationApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      await service.markAllRead(token: 'jwt-token');

      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/notifications/mark-all-read');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
    });

    test('throws NotificationApiException with server message on failure', () {
      final service = NotificationApiService(
        client: MockClient((request) async {
          return http.Response(
            '{"message":"Notifications are unavailable."}',
            500,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      expect(
        () => service.fetchNotifications(token: 'jwt-token'),
        throwsA(
          isA<NotificationApiException>().having(
            (error) => error.message,
            'message',
            'Notifications are unavailable.',
          ),
        ),
      );
    });
  });
}
