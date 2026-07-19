import 'dart:convert';

import 'package:bingcook/data/models/auth_api_models.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  const AuthApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _postCommand('/api/auth/register', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<AuthApiResponse> login({
    required String identity,
    required String password,
  }) {
    return _postAuth('/api/auth/login', {
      'identity': identity,
      'password': password,
    });
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _baseUrl.replace(path: '/api/auth/logout'),
      headers: {'accept': 'application/json', 'authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = response.body.trim().isEmpty
          ? <String, Object?>{}
          : _decodeObject(response.body);
      throw AuthApiException(
        _readMessage(decoded) ?? 'Logout request failed.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<AuthApiResponse> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    return _postAuth('/api/auth/verify-email', {'email': email, 'otp': otp});
  }

  Future<void> resendEmailOtp({required String email}) async {
    await _postCommand('/api/auth/resend-email-otp', {'email': email});
  }

  Future<AuthApiResponse> _postAuth(
    String path,
    Map<String, String> body,
  ) async {
    final response = await _client.post(
      _baseUrl.replace(path: path),
      headers: const {
        'accept': 'application/json',
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        _readMessage(decoded) ?? 'Authentication request failed.',
        statusCode: response.statusCode,
      );
    }

    return AuthApiResponse.fromJson(decoded);
  }

  Future<void> _postCommand(String path, Map<String, String> body) async {
    final response = await _client.post(
      _baseUrl.replace(path: path),
      headers: const {
        'accept': 'application/json',
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = response.body.trim().isEmpty
        ? <String, Object?>{}
        : _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        _readMessage(decoded) ?? 'Authentication request failed.',
        statusCode: response.statusCode,
      );
    }
  }

  Map<String, Object?> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const AuthApiException('Unable to read authentication response.');
    }
    return decoded;
  }

  String? _readMessage(Map<String, Object?> json) {
    final message = json['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
