import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/ui/features/auth/view_models/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginViewModel', () {
    test('submits phone identity through repository', () async {
      final repository = FakeAuthRepository();
      final viewModel = LoginViewModel(authRepository: repository);

      final result = await viewModel.submit(
        identity: '+84901234567',
        password: 'Password123',
      );

      expect(result, isTrue);
      expect(repository.loginIdentity, '+84901234567');
      expect(repository.loginPassword, 'Password123');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isSubmitting, isFalse);
    });

    test('shows safe error when repository rejects credentials', () async {
      final repository = FakeAuthRepository()
        ..loginError = const AuthRepositoryException(
          'Invalid email/phone or password.',
        );
      final viewModel = LoginViewModel(authRepository: repository);

      final result = await viewModel.submit(
        identity: 'jane@example.com',
        password: 'wrong-password',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'Invalid email/phone or password.');
      expect(viewModel.isSubmitting, isFalse);
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  String? loginIdentity;
  String? loginPassword;
  AuthRepositoryException? loginError;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    loginIdentity = identity;
    loginPassword = password;
    final error = loginError;
    if (error != null) {
      throw error;
    }
    return _session;
  }

  @override
  Future<void> logout() async {}

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
