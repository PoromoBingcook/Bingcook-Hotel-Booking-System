import 'dart:convert';

import 'package:bingcook/data/models/product_api_models.dart';
import 'package:http/http.dart' as http;

class SavedPropertyApiService {
  const SavedPropertyApiService({
    required http.Client client,
    required Uri baseUrl,
  }) : _client = client,
       _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<ProductListItemResponse>> fetchSavedProperties({
    required String token,
  }) async {
    final response = await _client.get(
      _baseUrl.replace(path: '/api/saved-properties'),
      headers: _headers(token),
    );
    final decoded = _tryDecode(response.body);
    _throwIfFailed(response, decoded, fallback: 'Unable to load saved stays.');

    if (decoded is! List) {
      throw const SavedPropertyApiException(
        'Unable to read saved stays response.',
      );
    }

    return decoded
        .whereType<Map<String, Object?>>()
        .map(ProductListItemResponse.fromJson)
        .toList(growable: false);
  }

  Future<void> saveProperty({
    required String token,
    required String propertyId,
  }) async {
    final response = await _client.put(
      _baseUrl.replace(path: '/api/saved-properties/$propertyId'),
      headers: _headers(token),
    );
    _throwIfFailed(
      response,
      _tryDecode(response.body),
      fallback: 'Unable to save this stay.',
    );
  }

  Future<void> removeProperty({
    required String token,
    required String propertyId,
  }) async {
    final response = await _client.delete(
      _baseUrl.replace(path: '/api/saved-properties/$propertyId'),
      headers: _headers(token),
    );
    _throwIfFailed(
      response,
      _tryDecode(response.body),
      fallback: 'Unable to remove this stay.',
    );
  }

  Map<String, String> _headers(String token) => {
    'accept': 'application/json',
    'authorization': 'Bearer $token',
  };

  void _throwIfFailed(
    http.Response response,
    Object? decoded, {
    required String fallback,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final message = decoded is Map<String, Object?>
        ? _readMessage(decoded)
        : null;
    throw SavedPropertyApiException(
      message ?? fallback,
      statusCode: response.statusCode,
    );
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

class SavedPropertyApiException implements Exception {
  const SavedPropertyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
