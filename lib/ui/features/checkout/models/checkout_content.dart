import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';

abstract final class CheckoutContent {
  static const oceanPearl = CheckoutData(
    propertyName: 'Ocean Pearl Hotel',
    propertyImageAsset: AppAssets.propertyDetails,
    roomName: 'Deluxe Ocean View',
    checkIn: 'Oct 12, 2024',
    checkOut: 'Oct 15, 2024',
    nights: 3,
    fullName: 'Johnathan Doe',
    email: 'john.doe@company.com',
    phone: '+1 (555) 000-0000',
    bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
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
    priceRows: [
      PriceBreakdownRow(label: 'Deluxe Ocean View (3 nights)', amount: 897),
      PriceBreakdownRow(label: 'Service Fee', amount: 45),
      PriceBreakdownRow(label: 'Occupancy Taxes', amount: 32.50),
    ],
    total: 974.50,
  );
}
