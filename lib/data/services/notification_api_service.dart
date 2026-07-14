import 'dart:convert';

import 'package:bingcook/data/models/notification_api_models.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  const NotificationApiService({
    required http.Client client,
    required Uri baseUrl,
  }) : _client = client,
       _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<NotificationResponse>> fetchNotifications({
    required String token,
  }) async {
    final response = await _client.get(
      _baseUrl.replace(path: '/api/notifications'),
      headers: {'accept': 'application/json', 'authorization': 'Bearer $token'},
    );

    final decoded = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, Object?>
          ? _readMessage(decoded)
          : null;
      throw NotificationApiException(
        message ?? 'Unable to load notifications.',
        statusCode: response.statusCode,
      );
    }

    if (decoded is! List) {
      throw const NotificationApiException(
        'Unable to read notifications response.',
      );
    }

    return decoded
        .whereType<Map<String, Object?>>()
        .map(NotificationResponse.fromJson)
        .toList(growable: false);
  }

  Future<void> markRead({
    required String token,
    required String notificationId,
  }) async {
    await _postEmpty(
      token: token,
      path: '/api/notifications/$notificationId/read',
    );
  }

  Future<void> markAllRead({required String token}) async {
    await _postEmpty(token: token, path: '/api/notifications/mark-all-read');
  }

  Future<void> _postEmpty({required String token, required String path}) async {
    final response = await _client.post(
      _baseUrl.replace(path: path),
      headers: {'accept': 'application/json', 'authorization': 'Bearer $token'},
    );

    final decoded = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, Object?>
          ? _readMessage(decoded)
          : null;
      throw NotificationApiException(
        message ?? 'Notification request failed.',
        statusCode: response.statusCode,
      );
    }
  }

  Object? _tryDecode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  String? _readMessage(Map<String, Object?> json) {
    final message = json['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

class NotificationApiException implements Exception {
  const NotificationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
