import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';

abstract final class CheckoutContent {
  static const checkIn = 'Oct 12, 2024';
  static const checkOut = 'Oct 15, 2024';
  static const paymentMethods = [
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
  ];

  static CheckoutData fromBooking({
    required PropertyDetailsData property,
    required RoomOptionData room,
    required AuthUser? user,
    int nights = 3,
  }) {
    final roomTotal = room.pricePerNight * nights;

    return CheckoutData(
      propertyName: property.name,
      propertyImageAsset: property.imageAsset,
      propertyImageUrl: property.imageUrl,
      roomName: room.name,
      checkIn: checkIn,
      checkOut: checkOut,
      nights: nights,
      fullName: user?.fullName ?? '',
      email: user?.email ?? '',
      phone: user?.phone ?? '',
      paymentMethods: paymentMethods,
      priceRows: [
        PriceBreakdownRow(
          label: '${room.name} ($nights nights)',
          amount: roomTotal.toDouble(),
        ),
      ],
      total: roomTotal.toDouble(),
    );
  }
}
