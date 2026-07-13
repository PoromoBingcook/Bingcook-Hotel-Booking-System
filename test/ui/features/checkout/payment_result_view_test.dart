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

    expect(confirmedCalls, 1);
    expect(viewModel.state, PaymentResultState.confirmed);
  });
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
