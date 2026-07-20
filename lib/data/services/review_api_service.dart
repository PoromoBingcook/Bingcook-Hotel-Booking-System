import 'dart:convert';

import 'package:bingcook/data/models/review_api_models.dart';
import 'package:http/http.dart' as http;

class ReviewApiService {
  const ReviewApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<ReviewApiResponse?> fetchMyReview({
    required String token,
    required String propertyId,
  }) async {
    final response = await _client.get(
      _reviewUri(propertyId, mine: true),
      headers: _headers(token),
    );
    if (response.statusCode == 204) {
      return null;
    }

    final decoded = _decodeMap(response.body);
    _throwForFailure(response.statusCode, decoded);
    return ReviewApiResponse.fromJson(decoded);
  }

  Future<ReviewApiResponse> saveReview({
    required String token,
    required String propertyId,
    required int rating,
    required String? comment,
  }) async {
    final response = await _client.put(
      _reviewUri(propertyId),
      headers: {..._headers(token), 'content-type': 'application/json'},
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    final decoded = _decodeMap(response.body);
    _throwForFailure(response.statusCode, decoded);
    return ReviewApiResponse.fromJson(decoded);
  }

  Future<List<ReviewApiResponse>> fetchMyReviews({
    required String token,
    required String propertyId,
  }) async {
    final response = await _client.get(
      _baseUrl.replace(path: '/api/reviews/properties/$propertyId/mine/all'),
      headers: _headers(token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decodeMap(response.body);
      _throwForFailure(response.statusCode, decoded);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ReviewApiException('Unable to read review response.');
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(ReviewApiResponse.fromJson)
        .toList(growable: false);
  }

  Future<ReviewApiResponse> createReview({
    required String token,
    required String propertyId,
    required int rating,
    required String? comment,
  }) {
    return _writeReview(
      method: 'POST',
      path: '/api/reviews/properties/$propertyId',
      token: token,
      rating: rating,
      comment: comment,
    );
  }

  Future<ReviewApiResponse> updateReview({
    required String token,
    required String reviewId,
    required int rating,
    required String? comment,
  }) {
    return _writeReview(
      method: 'PUT',
      path: '/api/reviews/$reviewId',
      token: token,
      rating: rating,
      comment: comment,
    );
  }

  Future<ReviewApiResponse> _writeReview({
    required String method,
    required String path,
    required String token,
    required int rating,
    required String? comment,
  }) async {
    final request = http.Request(method, _baseUrl.replace(path: path))
      ..headers.addAll({..._headers(token), 'content-type': 'application/json'})
      ..body = jsonEncode({'rating': rating, 'comment': comment});
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeMap(response.body);
    _throwForFailure(response.statusCode, decoded);
    return ReviewApiResponse.fromJson(decoded);
  }

  Uri _reviewUri(String propertyId, {bool mine = false}) {
    return _baseUrl.replace(
      path: '/api/reviews/properties/$propertyId${mine ? '/mine' : ''}',
    );
  }

  Map<String, String> _headers(String token) {
    return {'accept': 'application/json', 'authorization': 'Bearer $token'};
  }

  Map<String, Object?> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const ReviewApiException('Unable to read review response.');
  }

  void _throwForFailure(int statusCode, Map<String, Object?> decoded) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }
    final message = decoded['message'];
    throw ReviewApiException(
      message is String && message.trim().isNotEmpty
          ? message
          : 'Review request failed.',
      statusCode: statusCode,
    );
  }
}

class ReviewApiException implements Exception {
  const ReviewApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
