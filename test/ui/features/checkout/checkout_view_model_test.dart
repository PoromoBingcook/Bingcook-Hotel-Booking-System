import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:bingcook/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutViewModel', () {
    test('submits selected PayOS method through repository', () async {
      final repository = FakeBookingRepository();
      final viewModel = CheckoutViewModel(bookingRepository: repository);

      final result = await viewModel.submit(
        data: _data,
        customerName: ' Jane Cook ',
        customerEmail: ' jane@example.com ',
        customerPhone: ' +84901234567 ',
      );

      expect(result, isTrue);
      expect(repository.lastCheckoutCommand?.bookingId, _data.bookingId);
      expect(repository.lastCheckoutCommand?.paymentMethod, 'PayOS');
      expect(repository.lastCheckoutCommand?.customerName, 'Jane Cook');
      expect(viewModel.checkout?.checkoutUrl, 'https://pay.payos.vn/web/1');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isSubmitting, isFalse);
    });

    test('maps pay at property selection to backend method', () async {
      final repository = FakeBookingRepository();
      final viewModel = CheckoutViewModel(bookingRepository: repository);

      viewModel.selectPaymentMethod(PaymentMethodType.payAtProperty);
      await viewModel.submit(
        data: _data,
        customerName: '',
        customerEmail: '',
        customerPhone: '',
      );

      expect(repository.lastCheckoutCommand?.paymentMethod, 'PayAtProperty');
      expect(repository.lastCheckoutCommand?.customerName, isNull);
    });
  });
}

const _data = CheckoutData(
  bookingId: 'booking-id',
  propertyName: 'Ocean Pearl Hotel',
  propertyImageAsset: AppAssets.propertyDetails,
  roomName: 'Deluxe Ocean View',
  checkIn: 'Jul 10',
  checkOut: 'Jul 13',
  nights: 3,
  fullName: 'Jane Cook',
  email: 'jane@example.com',
  phone: '+84901234567',
  paymentMethods: [
    PaymentMethodData(
      type: PaymentMethodType.payOS,
      title: 'PayOS Checkout',
      subtitle: 'Card, wallet, or QR payment',
      iconAsset: AppAssets.checkoutDigitalWallet,
    ),
    PaymentMethodData(
      type: PaymentMethodType.payAtProperty,
      title: 'Pay at Property',
      subtitle: 'Confirm now, pay on arrival',
      iconAsset: AppAssets.checkoutBankTransfer,
    ),
  ],
  priceRows: [PriceBreakdownRow(label: 'Room', amount: 300)],
  total: 300,
);

class FakeBookingRepository implements BookingRepository {
  CheckoutBookingCommand? lastCheckoutCommand;

  @override
  Future<List<BookingReservation>> fetchReservations() async => const [];

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) {
    throw UnimplementedError();
  }

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) async {
    lastCheckoutCommand = command;
    return const BookingCheckout(
      bookingId: 'booking-id',
      bookingStatus: 'PendingPayment',
      paymentMethod: 'PayOS',
      paymentStatus: 'Pending',
      amount: 300,
      transactionCode: '1',
      paymentLinkId: 'link-id',
      checkoutUrl: 'https://pay.payos.vn/web/1',
      qrCode: 'qr-payload',
      message: 'Open checkoutUrl to pay with PayOS.',
    );
  }
}
