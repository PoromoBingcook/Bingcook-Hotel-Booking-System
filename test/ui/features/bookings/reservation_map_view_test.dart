import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/features/bookings/views/reservation_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds an OpenStreetMap URL with the hotel marker', () {
    final uri = buildOpenStreetMapUri(16.0544, 108.2022);

    expect(uri.host, 'www.openstreetmap.org');
    expect(uri.path, '/export/embed.html');
    expect(uri.queryParameters['marker'], '16.0544,108.2022');
    expect(uri.queryParameters['layer'], 'mapnik');
  });

  testWidgets('shows a clear state when hotel coordinates are unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ReservationMapView(reservation: _reservation)),
    );

    expect(find.text('Ocean Pearl Hotel'), findsOneWidget);
    expect(
      find.text('This property does not have map coordinates yet.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reservation_map_back_button')),
      findsOneWidget,
    );
  });
}

final _reservation = BookingReservation(
  bookingId: 'booking-1',
  propertyId: 'property-1',
  propertyName: 'Ocean Pearl Hotel',
  propertyImageUrl: null,
  roomId: 'room-1',
  roomName: 'Deluxe Room',
  roomImageUrl: null,
  checkIn: DateTime(2026, 7, 10),
  checkOut: DateTime(2026, 7, 12),
  adults: 2,
  children: 0,
  roomQuantity: 1,
  totalPrice: 1200000,
  bookingStatus: 'Confirmed',
  paymentStatus: 'Pending',
  paymentMethod: 'PayAtProperty',
);
