import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads reservations and separates upcoming from past', () async {
    final repository = _BookingRepository([
      _reservation(
        id: 'upcoming',
        checkIn: DateTime.now().add(const Duration(days: 2)),
        checkOut: DateTime.now().add(const Duration(days: 4)),
      ),
      _reservation(
        id: 'past',
        checkIn: DateTime.now().subtract(const Duration(days: 4)),
        checkOut: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
    final viewModel = BookingsViewModel(bookingRepository: repository);

    await viewModel.load();
    expect(viewModel.visibleReservations.single.bookingId, 'upcoming');

    viewModel.selectTab(BookingListTab.past);
    expect(viewModel.visibleReservations.single.bookingId, 'past');
  });
}

BookingReservation _reservation({
  required String id,
  required DateTime checkIn,
  required DateTime checkOut,
}) => BookingReservation(
  bookingId: id,
  propertyId: 'property',
  propertyName: 'Ocean Pearl Hotel',
  propertyImageUrl: null,
  roomId: 'room',
  roomName: 'Deluxe Ocean View',
  roomImageUrl: null,
  checkIn: checkIn,
  checkOut: checkOut,
  adults: 2,
  children: 0,
  roomQuantity: 1,
  totalPrice: 1240000,
  bookingStatus: 'Confirmed',
  paymentStatus: 'Pending',
  paymentMethod: 'PayAtProperty',
);

class _BookingRepository implements BookingRepository {
  const _BookingRepository(this.reservations);
  final List<BookingReservation> reservations;

  @override
  Future<List<BookingReservation>> fetchReservations() async => reservations;

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) =>
      throw UnimplementedError();
}
