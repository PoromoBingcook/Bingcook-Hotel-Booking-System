import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';

class AuthApiResponse {
  const AuthApiResponse({required this.user, required this.token});

  factory AuthApiResponse.fromJson(Map<String, Object?> json) {
    return AuthApiResponse(
      user: AuthApiUser.fromJson(json['user'] as Map<String, Object?>),
      token: json['token'] as String,
    );
  }

  final AuthApiUser user;
  final String token;

  AuthSession toDomain() {
    return AuthSession(user: user.toDomain(), token: token);
  }
}

class AuthApiUser {
  const AuthApiUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory AuthApiUser.fromJson(Map<String, Object?> json) {
    return AuthApiUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );
  }

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
    );
  }
}
