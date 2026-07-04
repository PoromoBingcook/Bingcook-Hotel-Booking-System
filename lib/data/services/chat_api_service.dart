import 'dart:convert';

import 'package:bingcook/data/models/chat_api_models.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  const ChatApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<ChatConversationResponse> createConversation({
    required String token,
    required String propertyId,
    required String? bookingId,
  }) async {
    final decoded = await _postObject(
      token: token,
      path: '/api/chat/conversations',
      body: {'propertyId': propertyId, 'bookingId': bookingId},
    );

    return ChatConversationResponse.fromJson(decoded);
  }

  Future<List<ChatConversationResponse>> fetchConversations({
    required String token,
  }) async {
    final decoded = await _getList(
      token: token,
      path: '/api/chat/conversations',
    );
    return decoded
        .map(ChatConversationResponse.fromJson)
        .toList(growable: false);
  }

  Future<List<ChatMessageResponse>> fetchMessages({
    required String token,
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) async {
    final queryParameters = <String, String>{'take': take.toString()};
    if (before != null) {
      queryParameters['before'] = before.toIso8601String();
    }

    final decoded = await _getList(
      token: token,
      path: '/api/chat/conversations/$conversationId/messages',
      queryParameters: queryParameters,
    );
    return decoded.map(ChatMessageResponse.fromJson).toList(growable: false);
  }

  Future<ChatMessageResponse> sendMessage({
    required String token,
    required String conversationId,
    required String body,
  }) async {
    final decoded = await _postObject(
      token: token,
      path: '/api/chat/conversations/$conversationId/messages',
      body: {'body': body},
    );

    return ChatMessageResponse.fromJson(decoded);
  }

  Future<void> markRead({
    required String token,
    required String conversationId,
  }) async {
    final response = await _client.post(
      _baseUrl.replace(path: '/api/chat/conversations/$conversationId/read'),
      headers: _headers(token),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatApiException(
        _readMessage(_decodeMaybeObject(response.body)) ??
            'Chat request failed.',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, Object?>> _postObject({
    required String token,
    required String path,
    required Map<String, Object?> body,
  }) async {
    final response = await _client.post(
      _baseUrl.replace(path: path),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatApiException(
        _readMessage(decoded) ?? 'Chat request failed.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Future<List<Map<String, Object?>>> _getList({
    required String token,
    required String path,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _baseUrl.replace(path: path, queryParameters: queryParameters),
      headers: _headers(token),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatApiException(
        _readMessage(_decodeMaybeObject(response.body)) ??
            'Chat request failed.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ChatApiException('Unable to read chat response.');
    }

    return decoded.cast<Map<String, Object?>>();
  }

  Map<String, String> _headers(String token) {
    return {
      'accept': 'application/json',
      'authorization': 'Bearer $token',
      'content-type': 'application/json',
    };
  }

  Map<String, Object?> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const ChatApiException('Unable to read chat response.');
    }
    return decoded;
  }

  Map<String, Object?> _decodeMaybeObject(String body) {
    if (body.trim().isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(body);
    return decoded is Map<String, Object?> ? decoded : const {};
  }

  String? _readMessage(Map<String, Object?> json) {
    final message = json['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
