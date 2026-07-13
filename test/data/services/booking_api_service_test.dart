import 'package:bingcook/data/services/booking_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('BookingApiService', () {
    test('fetches authenticated reservations', () async {
      http.Request? capturedRequest;
      final service = BookingApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('''
[
  {
    "bookingId": "booking-1",
    "propertyId": "property-1",
    "propertyName": "Ocean Pearl Hotel",
    "propertyImageUrl": "https://example.com/hotel.jpg",
    "latitude": 16.0544,
    "longitude": 108.2022,
    "roomId": "room-1",
    "roomName": "Deluxe Ocean View",
    "roomImageUrl": null,
    "checkIn": "2026-07-10",
    "checkOut": "2026-07-13",
    "adults": 2,
    "children": 1,
    "roomQuantity": 1,
    "totalPrice": 4080000,
    "bookingStatus": "Confirmed",
    "paymentStatus": "Pending",
    "paymentMethod": "PayAtProperty"
  }
]
''', 200);
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final reservations = await service.fetchReservations(token: 'jwt-token');

      expect(capturedRequest!.method, 'GET');
      expect(capturedRequest!.url.path, '/api/bookings');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      expect(reservations.single.propertyName, 'Ocean Pearl Hotel');
      expect(reservations.single.totalPrice, 4080000);
      expect(reservations.single.latitude, 16.0544);
      expect(reservations.single.longitude, 108.2022);
    });

    test('createDraft posts selection with bearer token', () async {
      http.Request? capturedRequest;
      final service = BookingApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "bookingId": "f4fb8b9d-b26c-4685-9454-0fbb9d927337",
  "propertyId": "13430237-d5ed-4c9f-be3a-feddf4cb4fa8",
  "propertyName": "Ocean Pearl Hotel",
  "roomId": "2cc3aa36-f925-4a1e-97bb-2695af5966b7",
  "roomName": "Deluxe Ocean View",
  "roomType": "Deluxe",
  "checkIn": "2026-07-10",
  "checkOut": "2026-07-13",
  "nights": 3,
  "adults": 2,
  "children": 1,
  "totalGuests": 3,
  "roomQuantity": 1,
  "maxGuests": 3,
  "availableRooms": 4,
  "roomSubtotal": 3000000,
  "addOnSubtotal": 1080000,
  "totalPrice": 4080000,
  "addOns": [
    {
      "code": "breakfast",
      "name": "Breakfast",
      "pricingType": "PerGuestPerNight",
      "unitPrice": 120000,
      "totalPrice": 1080000
    }
  ],
  "note": "Late arrival",
  "nextAction": "ProceedToConfirmationPayment"
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final draft = await service.createDraft(
        token: 'jwt-token',
        propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
        roomId: '2cc3aa36-f925-4a1e-97bb-2695af5966b7',
        checkIn: DateTime(2026, 7, 10),
        checkOut: DateTime(2026, 7, 13),
        adults: 2,
        children: 1,
        roomQuantity: 1,
        addOns: const ['breakfast'],
        note: 'Late arrival',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/bookings/draft');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      expect(capturedRequest!.body, contains('"checkIn":"2026-07-10"'));
      expect(capturedRequest!.body, contains('"addOns":["breakfast"]'));
      expect(draft.bookingId, 'f4fb8b9d-b26c-4685-9454-0fbb9d927337');
      expect(draft.totalPrice, 4080000);
      expect(draft.addOns.single.code, 'breakfast');
    });

    test('checkout posts payment method and parses PayOS link', () async {
      http.Request? capturedRequest;
      final service = BookingApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "bookingId": "f4fb8b9d-b26c-4685-9454-0fbb9d927337",
  "bookingStatus": "PendingPayment",
  "paymentMethod": "PayOS",
  "paymentStatus": "Pending",
  "amount": 4080000,
  "transactionCode": "88001234",
  "paymentLinkId": "payos-link-id",
  "checkoutUrl": "https://pay.payos.vn/web/88001234",
  "qrCode": "qr-code-payload",
  "message": "Open checkoutUrl to pay with PayOS."
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final checkout = await service.checkout(
        token: 'jwt-token',
        bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
        paymentMethod: 'PayOS',
        customerName: 'Jane Cook',
        customerEmail: 'jane@example.com',
        customerPhone: '+84901234567',
        identityNumber: '012345678',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/bookings/checkout');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      expect(capturedRequest!.body, contains('"paymentMethod":"PayOS"'));
      expect(checkout.checkoutUrl, 'https://pay.payos.vn/web/88001234');
      expect(checkout.bookingStatus, 'PendingPayment');
    });

    test('fetchStatus gets authenticated payment status', () async {
      http.Request? capturedRequest;
      final service = BookingApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "bookingId": "booking-1",
  "bookingStatus": "Paid",
  "paymentMethod": "PayOS",
  "paymentStatus": "Success",
  "amount": 4080000,
  "transactionCode": "88001234",
  "paymentLinkId": "payos-link-id",
  "checkoutUrl": "https://pay.payos.vn/web/88001234",
  "expiresAt": null,
  "paidAt": "2026-07-14T02:00:00Z",
  "updatedAt": "2026-07-14T02:00:00Z"
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final status = await service.fetchStatus(
        token: 'jwt-token',
        bookingId: 'booking-1',
      );

      expect(capturedRequest!.method, 'GET');
      expect(capturedRequest!.url.path, '/api/bookings/booking-1/status');
      expect(capturedRequest!.headers['authorization'], 'Bearer jwt-token');
      expect(status.toDomain().isPaid, isTrue);
    });

    test('cancel posts to booking cancellation endpoint', () async {
      http.Request? capturedRequest;
      final service = BookingApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            '''
{
  "bookingId": "booking-1",
  "bookingStatus": "Cancelled",
  "paymentStatus": "Success",
  "message": "Booking cancelled."
}
''',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      final cancellation = await service.cancel(
        token: 'jwt-token',
        bookingId: 'booking-1',
      );

      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/bookings/booking-1/cancel');
      expect(cancellation.paymentStatus, 'Success');
    });

    test('throws BookingApiException with server message on failure', () {
      final service = BookingApiService(
        client: MockClient((request) async {
          return http.Response(
            '{"message":"Room is no longer available."}',
            409,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: Uri.parse('http://10.0.2.2:5115'),
      );

      expect(
        () => service.createDraft(
          token: 'jwt-token',
          propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
          roomId: '2cc3aa36-f925-4a1e-97bb-2695af5966b7',
          checkIn: DateTime(2026, 7, 10),
          checkOut: DateTime(2026, 7, 13),
          adults: 2,
          children: 0,
          roomQuantity: 1,
          addOns: const [],
          note: null,
        ),
        throwsA(
          isA<BookingApiException>().having(
            (error) => error.message,
            'message',
            'Room is no longer available.',
          ),
        ),
      );
    });
  });
}
