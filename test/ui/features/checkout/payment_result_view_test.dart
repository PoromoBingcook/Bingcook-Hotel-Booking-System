import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/checkout/view_models/payment_result_view_model.dart';
import 'package:bingcook/ui/features/checkout/views/payment_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('embeds PayOS checkout URL in app and formats amount as VND', (
    tester,
  ) async {
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-id',
      bookingRepository: _BookingRepository(),
      delay: (_) async {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentResultView(
          checkout: _payOSCheckout,
          viewModel: viewModel,
          onBackToExplore: () {},
          onPaymentConfirmed: () {},
          payOSCheckoutBuilder: (url, _) => Text(
            'PayOS webview: $url',
            key: const Key('payos_checkout_webview'),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('payos_checkout_webview')), findsOneWidget);
    expect(
      find.text('PayOS webview: https://pay.payos.vn/web/88001234'),
      findsOneWidget,
    );
    expect(find.text('980.000 VND'), findsOneWidget);
    expect(find.text('Copy PayOS Link'), findsNothing);
    expect(find.text('Copy QR Payload'), findsNothing);
  });

  testWidgets('confirms payment after PayOS return finishes loading', (
    tester,
  ) async {
    var confirmedCalls = 0;
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-id',
      bookingRepository: _BookingRepository(statuses: const [_paidStatus]),
      delay: (_) async {},
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentResultView(
          checkout: _payOSCheckout,
          viewModel: viewModel,
          onBackToExplore: () {},
          onPaymentConfirmed: () => confirmedCalls++,
          payOSCheckoutBuilder: (url, onPageFinished) => TextButton(
            key: const Key('finish_payos_return'),
            onPressed: () => onPageFinished(
              'https://bingcook-api.mascoteach.com/api/payments/payos/return?orderCode=1',
            ),
            child: const Text('Finish return'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('finish_payos_return')));
    await tester.pump();

    expect(confirmedCalls, 0);
    expect(viewModel.state, PaymentResultState.confirmed);
    expect(find.byKey(const Key('payment_success_check')), findsOneWidget);
    expect(find.text('Transfer successful'), findsOneWidget);
    expect(find.byKey(const Key('finish_payos_return')), findsNothing);

    await tester.tap(find.byKey(const Key('view_bookings_button')));
    expect(confirmedCalls, 1);
  });

  testWidgets('shows the server-owned payment expiry countdown', (
    tester,
  ) async {
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-id',
      bookingRepository: _BookingRepository(),
      expiresAt: DateTime.utc(2026, 7, 14, 3, 15),
      now: () => DateTime.utc(2026, 7, 14, 3),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentResultView(
          checkout: _payOSCheckout,
          viewModel: viewModel,
          onBackToExplore: () {},
          onPaymentConfirmed: () {},
          onPaymentExpired: () {},
          payOSCheckoutBuilder: (_, _) => const SizedBox(),
        ),
      ),
    );

    expect(find.byKey(const Key('payment_expiry_countdown')), findsOneWidget);
    expect(find.text('Payment expires in 15:00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    viewModel.dispose();
  });

  testWidgets('delivers payment expiry once', (tester) async {
    var now = DateTime.utc(2026, 7, 14, 3);
    void Function(Timer)? tick;
    final timer = _Timer();
    var expiryCalls = 0;
    final viewModel = PaymentResultViewModel(
      bookingId: 'booking-id',
      bookingRepository: _BookingRepository(),
      expiresAt: DateTime.utc(2026, 7, 14, 3, 0, 1),
      now: () => now,
      timerFactory: (_, callback) {
        tick = callback;
        return timer;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PaymentResultView(
          checkout: _payOSCheckout,
          viewModel: viewModel,
          onBackToExplore: () {},
          onPaymentConfirmed: () {},
          onPaymentExpired: () => expiryCalls++,
          payOSCheckoutBuilder: (_, _) => const SizedBox(),
        ),
      ),
    );

    now = DateTime.utc(2026, 7, 14, 3, 0, 1);
    tick!(timer);
    await tester.pump();
    await tester.pump();
    expect(expiryCalls, 1);

    tick!(timer);
    await tester.pump();
    expect(expiryCalls, 1);

    await tester.pumpWidget(const SizedBox());
    viewModel.dispose();
  });
}

class _Timer implements Timer {
  var _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  int get tick => 0;

  @override
  void cancel() => _isActive = false;
}

const _payOSCheckout = BookingCheckout(
  bookingId: 'booking-id',
  bookingStatus: 'PendingPayment',
  paymentMethod: 'PayOS',
  paymentStatus: 'Pending',
  amount: 980000,
  transactionCode: '88001234',
  paymentLinkId: 'payos-link-id',
  checkoutUrl: 'https://pay.payos.vn/web/88001234',
  qrCode: 'qr-code-payload',
  message: 'Open checkoutUrl to pay with PayOS.',
);

const _paidStatus = BookingPaymentStatus(
  bookingId: 'booking-id',
  bookingStatus: 'Paid',
  paymentMethod: 'PayOS',
  paymentStatus: 'Success',
  amount: 980000,
  transactionCode: '88001234',
  paidAt: null,
  updatedAt: null,
);

class _BookingRepository implements BookingRepository {
  _BookingRepository({this.statuses = const []});

  final List<BookingPaymentStatus> statuses;
  int _statusIndex = 0;

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) async {
    return statuses[_statusIndex++];
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) =>
      throw UnimplementedError();

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) =>
      throw UnimplementedError();

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) =>
      throw UnimplementedError();

  @override
  Future<List<BookingReservation>> fetchReservations() =>
      throw UnimplementedError();
}
