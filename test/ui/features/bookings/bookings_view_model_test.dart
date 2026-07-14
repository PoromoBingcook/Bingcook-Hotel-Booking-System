import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('separates active past and canceled reservations', () async {
    final repository = _BookingRepository([
      _reservation(id: 'active', status: 'Paid'),
      _reservation(
        id: 'past',
        status: 'Confirmed',
        checkIn: DateTime(2026, 7, 10),
        checkOut: DateTime(2026, 7, 13),
      ),
      _reservation(id: 'canceled', status: 'Cancelled'),
    ]);
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 2),
    );

    await viewModel.load();
    expect(viewModel.visibleReservations.single.bookingId, 'active');

    viewModel.selectTab(BookingListTab.past);
    expect(viewModel.visibleReservations.single.bookingId, 'past');

    viewModel.selectTab(BookingListTab.canceled);
    expect(viewModel.visibleReservations.single.bookingId, 'canceled');
  });

  test('cancels eligible reservation and reloads server data', () async {
    final reservation = _reservation(id: 'paid', status: 'Paid');
    final repository = _BookingRepository([reservation]);
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 2),
    );
    await viewModel.load();

    final success = await viewModel.cancel(reservation);

    expect(success, isTrue);
    expect(repository.cancelledBookingId, reservation.bookingId);
    expect(viewModel.cancellingBookingId, isNull);
    expect(viewModel.successMessage, contains('Booking cancelled'));
    expect(repository.fetchCalls, 2);
  });

  test('prevents duplicate cancellation while request is pending', () async {
    final reservation = _reservation(id: 'paid', status: 'Paid');
    final repository = _BookingRepository([
      reservation,
    ], cancellationCompleter: Completer<BookingCancellation>());
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 2),
    );
    await viewModel.load();

    final first = viewModel.cancel(reservation);
    final second = await viewModel.cancel(reservation);

    expect(second, isFalse);
    expect(repository.cancelCalls, 1);
    repository.cancellationCompleter!.complete(_cancellation(reservation));
    expect(await first, isTrue);
  });

  test('keeps reservations loaded when cancellation fails', () async {
    final reservation = _reservation(id: 'paid', status: 'Paid');
    final repository = _BookingRepository([
      reservation,
    ], cancellationError: 'Cancellation is too close to check-in.');
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 2),
    );
    await viewModel.load();

    final success = await viewModel.cancel(reservation);

    expect(success, isFalse);
    expect(viewModel.visibleReservations.single.bookingId, 'paid');
    expect(
      viewModel.actionErrorMessage,
      'Cancellation is too close to check-in.',
    );
  });

  test(
    'exposes resume action only while pending payment is unexpired',
    () async {
      var now = DateTime.utc(2026, 7, 14, 3);
      final reservation = _reservation(
        id: 'pending',
        status: 'PendingPayment',
        expiresAt: DateTime.utc(2026, 7, 14, 3, 15),
        checkoutUrl: 'https://pay.payos.vn/web/88001234',
      );
      final viewModel = BookingsViewModel(
        bookingRepository: _BookingRepository([reservation]),
        now: () => now,
      );
      await viewModel.load();

      expect(viewModel.canResumePayment(reservation), isTrue);
      expect(viewModel.paymentCountdown(reservation), '15:00');

      now = DateTime.utc(2026, 7, 14, 3, 15);
      expect(viewModel.canResumePayment(reservation), isFalse);
      expect(viewModel.paymentCountdown(reservation), '00:00');
      viewModel.dispose();
    },
  );
}

BookingReservation _reservation({
  required String id,
  required String status,
  DateTime? checkIn,
  DateTime? checkOut,
  DateTime? expiresAt,
  String? checkoutUrl,
}) => BookingReservation(
  bookingId: id,
  propertyId: 'property',
  propertyName: 'Ocean Pearl Hotel',
  propertyImageUrl: null,
  roomId: 'room',
  roomName: 'Deluxe Ocean View',
  roomImageUrl: null,
  checkIn: checkIn ?? DateTime(2026, 7, 16),
  checkOut: checkOut ?? DateTime(2026, 7, 18),
  adults: 2,
  children: 0,
  roomQuantity: 1,
  totalPrice: 1240000,
  bookingStatus: status,
  paymentStatus: status == 'Paid' ? 'Success' : 'Pending',
  paymentMethod: status == 'Paid' ? 'PayOS' : 'PayAtProperty',
  transactionCode: status == 'PendingPayment' ? '88001234' : null,
  checkoutUrl: checkoutUrl,
  expiresAt: expiresAt,
);

BookingCancellation _cancellation(BookingReservation reservation) {
  return BookingCancellation(
    bookingId: reservation.bookingId,
    bookingStatus: 'Cancelled',
    paymentStatus: reservation.paymentStatus,
    message: 'Booking cancelled.',
  );
}

class _BookingRepository implements BookingRepository {
  _BookingRepository(
    List<BookingReservation> reservations, {
    this.cancellationCompleter,
    this.cancellationError,
  }) : _reservations = reservations;

  List<BookingReservation> _reservations;
  final Completer<BookingCancellation>? cancellationCompleter;
  final String? cancellationError;
  String? cancelledBookingId;
  int fetchCalls = 0;
  int cancelCalls = 0;

  @override
  Future<List<BookingReservation>> fetchReservations() async {
    fetchCalls++;
    return List.of(_reservations);
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) async {
    cancelCalls++;
    cancelledBookingId = bookingId;
    if (cancellationError case final message?) {
      throw BookingRepositoryException(message);
    }
    final reservation = _reservations.singleWhere(
      (item) => item.bookingId == bookingId,
    );
    final cancellation = cancellationCompleter == null
        ? _cancellation(reservation)
        : await cancellationCompleter!.future;
    _reservations = [
      for (final item in _reservations)
        item.bookingId == bookingId
            ? BookingReservation(
                bookingId: item.bookingId,
                propertyId: item.propertyId,
                propertyName: item.propertyName,
                propertyImageUrl: item.propertyImageUrl,
                latitude: item.latitude,
                longitude: item.longitude,
                roomId: item.roomId,
                roomName: item.roomName,
                roomImageUrl: item.roomImageUrl,
                checkIn: item.checkIn,
                checkOut: item.checkOut,
                adults: item.adults,
                children: item.children,
                roomQuantity: item.roomQuantity,
                totalPrice: item.totalPrice,
                bookingStatus: 'Cancelled',
                paymentStatus: item.paymentStatus,
                paymentMethod: item.paymentMethod,
              )
            : item,
    ];
    return cancellation;
  }

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) =>
      throw UnimplementedError();
}
