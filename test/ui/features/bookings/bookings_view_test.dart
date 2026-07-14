import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:bingcook/ui/features/bookings/views/bookings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows three tabs and completes cancellation flow', (
    tester,
  ) async {
    final repository = _BookingRepository();
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 2),
    );
    await viewModel.load();
    var cancellationCallbacks = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingsView(
            viewModel: viewModel,
            onReservationCancelled: () => cancellationCallbacks++,
          ),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Canceled'), findsOneWidget);
    expect(find.text('Active Ocean Hotel'), findsOneWidget);

    await tester.tap(find.text('Canceled'));
    await tester.pump();
    expect(find.text('Canceled Garden Stay'), findsOneWidget);

    await tester.tap(find.text('Active'));
    await tester.pump();
    await tester.tap(find.text('Cancel reservation'));
    await tester.pumpAndSettle();

    expect(find.textContaining('24 hours'), findsOneWidget);
    expect(
      find.textContaining('successful payment remains recorded'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('confirm_booking_cancellation')));
    await tester.pump();
    expect(find.byKey(const Key('cancel_booking_progress')), findsOneWidget);

    repository.completeCancellation();
    await tester.pumpAndSettle();

    expect(find.text('Booking cancelled.'), findsOneWidget);
    expect(cancellationCallbacks, 1);
  });

  testWidgets('shows countdown and resumes an existing PayOS payment', (
    tester,
  ) async {
    final repository = _BookingRepository(includePending: true);
    final viewModel = BookingsViewModel(
      bookingRepository: repository,
      now: () => DateTime.utc(2026, 7, 14, 3),
    );
    await viewModel.load();
    BookingReservation? resumed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingsView(
            viewModel: viewModel,
            onResumePayment: (reservation) => resumed = reservation,
          ),
        ),
      ),
    );

    expect(find.text('Payment expires in 15:00'), findsOneWidget);
    final resumeButton = find.byKey(const Key('resume_payment_pending'));
    await tester.scrollUntilVisible(resumeButton, 400);
    await tester.pumpAndSettle();
    await tester.tap(resumeButton);
    expect(resumed?.bookingId, 'pending');

    await tester.pumpWidget(const SizedBox());
    viewModel.dispose();
  });
}

class _BookingRepository implements BookingRepository {
  _BookingRepository({this.includePending = false});

  final _cancellationCompleter = Completer<BookingCancellation>();
  final bool includePending;
  var _canceled = false;

  void completeCancellation() {
    _canceled = true;
    _cancellationCompleter.complete(
      const BookingCancellation(
        bookingId: 'active',
        bookingStatus: 'Cancelled',
        paymentStatus: 'Success',
        message: 'Booking cancelled.',
      ),
    );
  }

  @override
  Future<List<BookingReservation>> fetchReservations() async => [
    _reservation(
      id: 'active',
      propertyName: 'Active Ocean Hotel',
      status: _canceled ? 'Cancelled' : 'Paid',
    ),
    _reservation(
      id: 'canceled',
      propertyName: 'Canceled Garden Stay',
      status: 'Cancelled',
    ),
    if (includePending)
      _reservation(
        id: 'pending',
        propertyName: 'Pending PayOS Stay',
        status: 'PendingPayment',
        paymentStatus: 'Pending',
        checkoutUrl: 'https://pay.payos.vn/web/88001234',
        expiresAt: DateTime.utc(2026, 7, 14, 3, 15),
      ),
  ];

  @override
  Future<BookingCancellation> cancel(String bookingId) =>
      _cancellationCompleter.future;

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) =>
      throw UnimplementedError();
}

BookingReservation _reservation({
  required String id,
  required String propertyName,
  required String status,
  String paymentStatus = 'Success',
  String? checkoutUrl,
  DateTime? expiresAt,
}) {
  return BookingReservation(
    bookingId: id,
    propertyId: 'property-$id',
    propertyName: propertyName,
    propertyImageUrl: null,
    roomId: 'room-$id',
    roomName: 'Deluxe Room',
    roomImageUrl: null,
    checkIn: DateTime(2026, 7, 16),
    checkOut: DateTime(2026, 7, 18),
    adults: 2,
    children: 0,
    roomQuantity: 1,
    totalPrice: 1240000,
    bookingStatus: status,
    paymentStatus: paymentStatus,
    paymentMethod: 'PayOS',
    transactionCode: status == 'PendingPayment' ? '88001234' : null,
    checkoutUrl: checkoutUrl,
    expiresAt: expiresAt,
  );
}
