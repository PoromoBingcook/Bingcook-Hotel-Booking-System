import 'dart:convert';

import 'package:bingcook/data/models/product_api_models.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  const ProductApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<List<ProductListItemResponse>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    final response = await _client.get(
      _productsUri(query),
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

  Future<ProductDetailsResponse> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    final response = await _client.get(
      _productDetailsUri(id, query),
      headers: const {'accept': 'application/json'},
    );

    final decoded = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductApiException(
        _readMessageFromMap(decoded) ?? 'Product details request failed.',
        statusCode: response.statusCode,
      );
    }

    return ProductDetailsResponse.fromJson(decoded);
  }

  Uri _productsUri(ProductSearchQuery query) {
    return _baseUrl.replace(
      path: '/api/products',
      queryParameters: query.toQueryParameters().isEmpty
          ? null
          : query.toQueryParameters(),
    );
  }

  Uri _productDetailsUri(String id, ProductSearchQuery query) {
    return _baseUrl.replace(
      path: '/api/products/$id',
      queryParameters: query.toQueryParameters().isEmpty
          ? null
          : query.toQueryParameters(),
    );
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

  Map<String, Object?> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const ProductApiException('Unable to read product details response.');
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

  String? _readMessageFromMap(Map<String, Object?> decoded) {
    final message = decoded['message'];
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
