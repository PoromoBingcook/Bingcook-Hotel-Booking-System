import 'package:bingcook/data/models/auth_api_models.dart';
import 'package:bingcook/data/repositories/api_auth_repository.dart';
import 'package:bingcook/data/services/auth_api_service.dart';
import 'package:bingcook/data/services/auth_session_storage.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiAuthRepository', () {
    test('logout clears local session when server token is expired', () async {
      final storage = FakeAuthSessionStorage(_session);
      final repository = ApiAuthRepository(
        authApiService: FakeAuthApiService(
          logoutError: const AuthApiException(
            'Logout request failed.',
            statusCode: 401,
          ),
        ),
        sessionStorage: storage,
      );
      await repository.restoreSession();

      await repository.logout();

      expect(repository.currentSession, isNull);
      expect(storage.cleared, isTrue);
    });
  });
}

class FakeAuthApiService implements AuthApiService {
  const FakeAuthApiService({this.logoutError});

  final AuthApiException? logoutError;

  @override
  Future<AuthApiResponse> login({
    required String identity,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout({required String token}) async {
    final error = logoutError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> resendEmailOtp({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthApiResponse> verifyEmailOtp({
    required String email,
    required String otp,
  }) {
    throw UnimplementedError();
  }
}

class FakeAuthSessionStorage implements AuthSessionStorage {
  FakeAuthSessionStorage(this.session);

  AuthSession? session;
  bool cleared = false;

  @override
  Future<void> clear() async {
    cleared = true;
    session = null;
  }

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async {
    this.session = session;
  }
}

final _session = AuthSession(
  token: 'expired-token',
  user: AuthUser(
    id: 'c38d653b-3a56-49cf-9473-22edaa5f3a2c',
    fullName: 'Jane Cook',
    email: 'jane@example.com',
    phone: '+84901234567',
    role: 'Customer',
  ),
);
