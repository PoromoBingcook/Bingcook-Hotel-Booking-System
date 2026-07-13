import 'package:bingcook/data/services/saved_property_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('fetches saved properties with bearer token', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/saved-properties');
      expect(request.headers['authorization'], 'Bearer jwt-token');
      return http.Response(_savedProductJson, 200);
    });
    final service = SavedPropertyApiService(
      client: client,
      baseUrl: Uri.parse('https://bingcook-api.mascoteach.com'),
    );

    final products = await service.fetchSavedProperties(token: 'jwt-token');

    expect(products.single.name, 'Ocean Pearl Hotel');
  });

  test('uses idempotent PUT and DELETE endpoints', () async {
    final methods = <String>[];
    final client = MockClient((request) async {
      methods.add('${request.method} ${request.url.path}');
      expect(request.headers['authorization'], 'Bearer jwt-token');
      return http.Response('', 204);
    });
    final service = SavedPropertyApiService(
      client: client,
      baseUrl: Uri.parse('https://bingcook-api.mascoteach.com'),
    );

    await service.saveProperty(token: 'jwt-token', propertyId: 'property-1');
    await service.removeProperty(token: 'jwt-token', propertyId: 'property-1');

    expect(methods, [
      'PUT /api/saved-properties/property-1',
      'DELETE /api/saved-properties/property-1',
    ]);
  });
}

const _savedProductJson = '''
[
  {
    "id": "13430237-d5ed-4c9f-be3a-feddf4cb4fa8",
    "type": "Hotel",
    "name": "Ocean Pearl Hotel",
    "description": "Beachfront hotel.",
    "location": "Da Nang, Son Tra",
    "city": "Da Nang",
    "address": "Son Tra",
    "imageUrl": null,
    "rating": 4.7,
    "reviewCount": 3,
    "amenities": ["Wi-Fi"],
    "pricePerNight": 680000,
    "status": "Available"
  }
]
''';
