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
    paymentMethods: [
      PaymentMethodData(
        type: PaymentMethodType.creditCard,
        title: 'Credit or Debit Card',
        subtitle: 'Visa, Mastercard, Amex',
        iconAsset: AppAssets.checkoutCredit,
      ),
      PaymentMethodData(
        type: PaymentMethodType.digitalWallet,
        title: 'Digital Wallets',
        subtitle: 'Apple Pay, Google Pay',
        iconAsset: AppAssets.checkoutDigitalWallet,
      ),
      PaymentMethodData(
        type: PaymentMethodType.bankTransfer,
        title: 'Bank Transfer',
        subtitle: 'Direct secure wire',
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
