import 'package:bingcook/data/services/product_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ProductApiService', () {
    test(
      'fetchProducts gets products endpoint and parses list response',
      () async {
        http.Request? capturedRequest;
        final service = ProductApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              '''
[
  {
    "id": "13430237-d5ed-4c9f-be3a-feddf4cb4fa8",
    "type": "Hotel",
    "name": "Ocean Pearl Hotel",
    "description": "Beachfront hotel near My Khe Beach.",
    "location": "Da Nang, Vo Nguyen Giap, Son Tra",
    "city": "Da Nang",
    "address": "Vo Nguyen Giap, Son Tra",
    "latitude": 16.0544,
    "longitude": 108.2022,
    "imageUrl": "https://example.com/ocean.jpg",
    "rating": 4.7,
    "reviewCount": 3,
    "amenities": ["Wi-Fi", "Pool"],
    "pricePerNight": 68.0,
    "status": "Active"
  }
]
''',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
          baseUrl: Uri.parse('http://10.0.2.2:5115'),
        );

        final products = await service.fetchProducts();

        expect(capturedRequest, isNotNull);
        expect(capturedRequest!.method, 'GET');
        expect(capturedRequest!.url.path, '/api/products');
        expect(capturedRequest!.headers['accept'], 'application/json');
        expect(products, hasLength(1));
        expect(products.single.name, 'Ocean Pearl Hotel');
        expect(products.single.pricePerNight, 68);
        expect(products.single.latitude, 16.0544);
        expect(products.single.longitude, 108.2022);
        expect(products.single.amenities, ['Wi-Fi', 'Pool']);
      },
    );

    test(
      'fetchProductDetails parses map coordinates and room quantity',
      () async {
        final service = ProductApiService(
          client: MockClient((request) async {
            return http.Response(
              '''
{
  "id": "13430237-d5ed-4c9f-be3a-feddf4cb4fa8",
  "type": "Hotel",
  "name": "Ocean Pearl Hotel",
  "location": "Da Nang, Vo Nguyen Giap, Son Tra",
  "city": "Da Nang",
  "address": "Vo Nguyen Giap, Son Tra",
  "latitude": 16.0544,
  "longitude": 108.2022,
  "pricePerNight": 68.0,
  "status": "Available",
  "rooms": [
    {
      "id": "room-1",
      "name": "Deluxe Room",
      "maxGuests": 2,
      "availableRooms": 7,
      "pricePerNight": 850000,
      "features": ["AC"],
      "policy": "Instant Booking"
    }
  ]
}
''',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
          baseUrl: Uri.parse('http://10.0.2.2:5115'),
        );

        final details = await service.fetchProductDetails(
          '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
        );

        expect(details.latitude, 16.0544);
        expect(details.longitude, 108.2022);
        expect(details.rooms.single.availableRooms, 7);
      },
    );

    test('throws ProductApiException with server message on failure', () async {
      final service = ProductApiService(
        client: MockClient((request) async {
          return http.Response(
            '{"message":"Products unavailable."}',
            500,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      expect(
        service.fetchProducts,
        throwsA(
          isA<ProductApiException>().having(
            (error) => error.message,
            'message',
            'Products unavailable.',
          ),
        ),
      );
    });
  });
}
