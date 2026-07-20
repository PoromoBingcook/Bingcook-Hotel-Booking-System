import 'package:bingcook/domain/models/auth_session.dart';

abstract interface class AuthRepository {
  AuthSession? get currentSession;

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSession> login({
    required String identity,
    required String password,
  });

  Future<void> logout();
}

abstract interface class RestorableAuthRepository {
  Future<void> restoreSession();
}

abstract interface class EmailVerificationAuthRepository {
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<void> resendEmailOtp({required String email});
}

abstract interface class EditableProfileAuthRepository {
  Future<AuthSession> updateProfile({
    required String fullName,
    required String? phone,
  });
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
