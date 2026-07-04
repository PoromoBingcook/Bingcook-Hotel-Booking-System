import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/features/checkout/views/payment_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('embeds PayOS checkout URL in app and formats amount as VND', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentResultView(
          checkout: _payOSCheckout,
          onBackToExplore: () {},
          payOSCheckoutBuilder: (url) => Text(
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
