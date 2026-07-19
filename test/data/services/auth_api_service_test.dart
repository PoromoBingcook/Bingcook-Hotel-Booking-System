import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthApiService', () {
    test('register posts credentials and accepts otp response', () async {
      http.Request? capturedRequest;
      final service = AuthApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '{"message":"A verification OTP has been sent to your email."}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      await service.register(
        fullName: 'Jane Cook',
        email: 'jane@example.com',
        phone: '+84901234567',
        password: 'Password123',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/auth/register');
      expect(capturedRequest!.body, contains('"email":"jane@example.com"'));
    });

    test('login accepts phone identity and parses token response', () async {
      http.Request? capturedRequest;
      final service = AuthApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "user": {
    "id": "c38d653b-3a56-49cf-9473-22edaa5f3a2c",
    "fullName": "Jane Cook",
    "email": "jane@example.com",
    "phone": "+84901234567",
    "role": "Customer"
  },
  "token": "jwt-token"
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final response = await service.login(
        identity: '+84901234567',
        password: 'Password123',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/auth/login');
      expect(capturedRequest!.body, contains('"identity":"+84901234567"'));
      expect(response.token, 'jwt-token');
      expect(response.user.phone, '+84901234567');
    });

    test(
      'logout posts bearer token and accepts empty success response',
      () async {
        http.Request? capturedRequest;
        final service = AuthApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response('', 204);
          }),
          baseUrl: Uri.parse('http://10.0.2.2:5115'),
        );

        await service.logout(token: 'jwt-token');

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.method, 'POST');
        expect(capturedRequest!.url.path, '/api/auth/logout');
        expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      },
    );

    test('verifyEmailOtp posts email and otp', () async {
      http.Request? capturedRequest;
      final service = AuthApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "user": {
    "id": "c38d653b-3a56-49cf-9473-22edaa5f3a2c",
    "fullName": "Jane Cook",
    "email": "jane@example.com",
    "phone": "+84901234567",
    "role": "Customer"
  },
  "token": "jwt-token"
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final response = await service.verifyEmailOtp(
        email: 'jane@example.com',
        otp: '123456',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/auth/verify-email');
      expect(capturedRequest!.body, contains('"email":"jane@example.com"'));
      expect(capturedRequest!.body, contains('"otp":"123456"'));
      expect(response.token, 'jwt-token');
      expect(response.user.email, 'jane@example.com');
    });

    test('resendEmailOtp posts email', () async {
      http.Request? capturedRequest;
      final service = AuthApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '{"message":"A new OTP has been sent to your email."}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      await service.resendEmailOtp(email: 'jane@example.com');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/auth/resend-email-otp');
      expect(capturedRequest!.body, contains('"email":"jane@example.com"'));
    });

    test('throws AuthApiException with server message on conflict', () async {
      final service = AuthApiService(
        client: MockClient((request) async {
          return http.Response(
            '{"message":"Email or phone already exists."}',
            409,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      expect(
        () => service.register(
          fullName: 'Jane Cook',
          email: 'jane@example.com',
          phone: '+84901234567',
          password: 'Password123',
        ),
        throwsA(
          isA<AuthApiException>().having(
            (error) => error.message,
            'message',
            'Email or phone already exists.',
          ),
        ),
      );
    });
  });
}
