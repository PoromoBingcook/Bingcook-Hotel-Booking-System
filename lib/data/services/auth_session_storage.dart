import 'dart:convert';

import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthSessionStorage {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  const SecureAuthSessionStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _sessionKey = 'bingcook.auth_session';
  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final json = jsonDecode(encoded) as Map<String, Object?>;
      final token = json['token'] as String;
      final user = json['user'] as Map<String, Object?>;
      return AuthSession(
        token: token,
        user: AuthUser(
          id: user['id'] as String,
          fullName: user['fullName'] as String,
          email: user['email'] as String?,
          phone: user['phone'] as String?,
          role: user['role'] as String,
        ),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'token': session.token,
        'user': {
          'id': session.user.id,
          'fullName': session.user.fullName,
          'email': session.user.email,
          'phone': session.user.phone,
          'role': session.user.role,
        },
      }),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}
