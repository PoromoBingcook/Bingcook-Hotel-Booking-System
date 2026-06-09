import 'package:bingcook/domain/models/auth_session.dart';

abstract interface class AuthRepository {
  AuthSession? get currentSession;

  Future<AuthSession> register({
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

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
