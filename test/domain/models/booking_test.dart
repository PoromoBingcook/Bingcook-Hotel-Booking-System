import 'package:bingcook/domain/models/booking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies active past and canceled reservations', () {
    final now = DateTime.utc(2026, 7, 14, 2);

    expect(
      _reservation(status: 'Paid').categoryAt(now),
      BookingCategory.active,
    );
    expect(
      _reservation(
        status: 'Confirmed',
        checkOut: DateTime(2026, 7, 13),
      ).categoryAt(now),
      BookingCategory.past,
    );
    expect(
      _reservation(status: 'Cancelled').categoryAt(now),
      BookingCategory.canceled,
    );
    expect(
      _reservation(status: 'Expired').categoryAt(now),
      BookingCategory.canceled,
    );
  });

  test('allows cancellation only before Vietnam check-in deadline', () {
    final reservation = _reservation(
      status: 'Paid',
      checkIn: DateTime(2026, 7, 16),
    );

    expect(reservation.canCancelAt(DateTime.utc(2026, 7, 15, 6, 59)), isTrue);
    expect(reservation.canCancelAt(DateTime.utc(2026, 7, 15, 7)), isFalse);
  });
}

BookingReservation _reservation({
  required String status,
  DateTime? checkIn,
  DateTime? checkOut,
}) {
  return BookingReservation(
    bookingId: 'booking-1',
    propertyId: 'property-1',
    propertyName: 'Ocean Pearl Hotel',
    propertyImageUrl: null,
    roomId: 'room-1',
    roomName: 'Deluxe Ocean View',
    roomImageUrl: null,
    checkIn: checkIn ?? DateTime(2026, 7, 16),
    checkOut: checkOut ?? DateTime(2026, 7, 18),
    adults: 2,
    children: 0,
    roomQuantity: 1,
    totalPrice: 4080000,
    bookingStatus: status,
    paymentStatus: status == 'Paid' ? 'Success' : 'Pending',
    paymentMethod: 'PayOS',
  );
}
