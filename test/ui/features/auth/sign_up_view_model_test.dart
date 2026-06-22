import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUpViewModel', () {
    test('toggles password visibility', () {
      final viewModel = SignUpViewModel(authRepository: FakeAuthRepository());

      expect(viewModel.isPasswordVisible, isFalse);

      viewModel.togglePasswordVisibility();

      expect(viewModel.isPasswordVisible, isTrue);
    });

    test('returns validation errors for empty values', () {
      final viewModel = SignUpViewModel(authRepository: FakeAuthRepository());

      final errors = viewModel.validate(
        fullName: '',
        email: '',
        phone: '',
        password: '',
        confirmPassword: '',
      );

      expect(errors.fullName, isNotNull);
      expect(errors.email, isNotNull);
      expect(errors.phone, isNotNull);
      expect(errors.password, isNotNull);
      expect(errors.confirmPassword, isNotNull);
    });

    test('returns error when confirm password does not match', () {
      final viewModel = SignUpViewModel(authRepository: FakeAuthRepository());

      final errors = viewModel.validate(
        fullName: 'Jane Cook',
        email: 'jane@example.com',
        phone: '+84901234567',
        password: 'Password123',
        confirmPassword: 'Password456',
      );

      expect(errors.confirmPassword, 'Passwords do not match');
    });

    test('submits valid registration through repository', () async {
      final repository = FakeAuthRepository();
      final viewModel = SignUpViewModel(authRepository: repository);

      final result = await viewModel.submit(
        fullName: 'Jane Cook',
        email: 'JANE@example.com',
        phone: '+84901234567',
        password: 'Password123',
        confirmPassword: 'Password123',
      );

      expect(result, isTrue);
      expect(repository.registerEmail, 'JANE@example.com');
      expect(repository.registerPhone, '+84901234567');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isSubmitting, isFalse);
    });

    test('shows repository error for duplicate identity', () async {
      final repository = FakeAuthRepository()
        ..registerError = const AuthRepositoryException(
          'Email or phone already exists.',
        );
      final viewModel = SignUpViewModel(authRepository: repository);

      final result = await viewModel.submit(
        fullName: 'Jane Cook',
        email: 'jane@example.com',
        phone: '+84901234567',
        password: 'Password123',
        confirmPassword: 'Password123',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'Email or phone already exists.');
      expect(viewModel.isSubmitting, isFalse);
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  String? registerEmail;
  String? registerPhone;
  AuthRepositoryException? registerError;

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
  Future<void> logout() async {}

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    registerEmail = email;
    registerPhone = phone;
    final error = registerError;
    if (error != null) {
      throw error;
    }
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
