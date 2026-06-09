import 'dart:convert';

import 'package:bingcook/data/models/product_api_models.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  const ProductApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<ProductListItemResponse>> fetchProducts() async {
    final response = await _client.get(
      _baseUrl.replace(path: '/api/products'),
      headers: const {'accept': 'application/json'},
    );

    final decoded = _decodeList(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductApiException(
        _readMessage(decoded) ?? 'Products request failed.',
        statusCode: response.statusCode,
      );
    }

    return decoded
        .map(
          (item) =>
              ProductListItemResponse.fromJson(item as Map<String, Object?>),
        )
        .toList(growable: false);
  }

  List<Object?> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List<Object?>) {
      return decoded;
    }
    if (decoded is Map<String, Object?>) {
      return [decoded];
    }
    throw const ProductApiException('Unable to read products response.');
  }

  String? _readMessage(List<Object?> decoded) {
    if (decoded.length != 1) {
      return null;
    }
    final first = decoded.first;
    if (first is! Map<String, Object?>) {
      return null;
    }
    final message = first['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

class ProductApiException implements Exception {
  const ProductApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
