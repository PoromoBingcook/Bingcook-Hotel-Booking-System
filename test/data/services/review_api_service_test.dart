import 'dart:convert';

import 'package:bingcook/data/services/review_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ReviewApiService', () {
    test('fetchMyReview returns null for a 204 response', () async {
      late http.Request capturedRequest;
      final service = ReviewApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final review = await service.fetchMyReview(
        token: 'token-1',
        propertyId: 'property-1',
      );

      expect(review, isNull);
      expect(capturedRequest.method, 'GET');
      expect(
        capturedRequest.url.path,
        '/api/reviews/properties/property-1/mine',
      );
      expect(capturedRequest.headers['authorization'], 'Bearer token-1');
    });

    test('fetchMyReview parses an existing review', () async {
      final service = ReviewApiService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({
              'id': 'review-1',
              'propertyId': 'property-1',
              'rating': 4,
              'comment': 'Comfortable room.',
              'createdAt': '2026-07-15T02:00:00Z',
            }),
            200,
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final review = await service.fetchMyReview(
        token: 'token-1',
        propertyId: 'property-1',
      );

      expect(review?.rating, 4);
      expect(review?.comment, 'Comfortable room.');
      expect(review?.createdAt.isUtc, isTrue);
    });

    test('saveReview sends rating-only PUT body and parses response', () async {
      late http.Request capturedRequest;
      final service = ReviewApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 'review-1',
              'propertyId': 'property-1',
              'rating': 5,
              'comment': null,
              'createdAt': '2026-07-15T02:00:00Z',
            }),
            200,
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final review = await service.saveReview(
        token: 'token-1',
        propertyId: 'property-1',
        rating: 5,
        comment: null,
      );

      expect(capturedRequest.method, 'PUT');
      expect(capturedRequest.url.path, '/api/reviews/properties/property-1');
      expect(capturedRequest.headers['authorization'], 'Bearer token-1');
      expect(jsonDecode(capturedRequest.body), {'rating': 5, 'comment': null});
      expect(review.rating, 5);
      expect(review.comment, isNull);
    });

    test('creates a new review and updates it by review ID', () async {
      final requests = <http.Request>[];
      final service = ReviewApiService(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'id': 'review-1',
              'propertyId': 'property-1',
              'rating': 5,
              'comment': 'Great',
              'createdAt': '2026-07-15T02:00:00Z',
            }),
            request.method == 'POST' ? 201 : 200,
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      await service.createReview(
        token: 'token-1',
        propertyId: 'property-1',
        rating: 5,
        comment: 'Great',
      );
      await service.updateReview(
        token: 'token-1',
        reviewId: 'review-1',
        rating: 5,
        comment: 'Great',
      );

      expect(requests[0].method, 'POST');
      expect(requests[0].url.path, '/api/reviews/properties/property-1');
      expect(requests[1].method, 'PUT');
      expect(requests[1].url.path, '/api/reviews/review-1');
    });

    test('propagates the server error message', () async {
      final service = ReviewApiService(
        client: MockClient((_) async {
          return http.Response(
            jsonEncode({'message': 'Property not found.'}),
            404,
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      expect(
        () => service.saveReview(
          token: 'token-1',
          propertyId: 'missing',
          rating: 5,
          comment: null,
        ),
        throwsA(
          isA<ReviewApiException>().having(
            (error) => error.message,
            'message',
            'Property not found.',
          ),
        ),
      );
    });
  });
}
