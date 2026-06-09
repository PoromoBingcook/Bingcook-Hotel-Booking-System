import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileViewModel', () {
    test('exposes current account display name', () {
      final viewModel = ProfileViewModel(authRepository: FakeAuthRepository());

      expect(viewModel.displayName, 'Jane Cook');
      expect(viewModel.email, 'jane@example.com');
    });

    test('logout clears session through repository', () async {
      final repository = FakeAuthRepository();
      final viewModel = ProfileViewModel(authRepository: repository);

      final result = await viewModel.logout();

      expect(result, isTrue);
      expect(repository.logoutCalled, isTrue);
      expect(viewModel.isLoggingOut, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('logout maps repository errors to safe state', () async {
      final repository = FakeAuthRepository()
        ..logoutError = const AuthRepositoryException('Unable to logout.');
      final viewModel = ProfileViewModel(authRepository: repository);

      final result = await viewModel.logout();

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'Unable to logout.');
      expect(viewModel.isLoggingOut, isFalse);
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;
  AuthRepositoryException? logoutError;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _session;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    final error = logoutError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _session;
  }

  static final _session = AuthSession(
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
