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
  ];

  static const oceanPearl = CheckoutData(
    propertyName: 'Ocean Pearl Hotel',
    propertyImageAsset: AppAssets.propertyDetails,
    roomName: 'Deluxe Ocean View',
    checkIn: checkIn,
    checkOut: checkOut,
    nights: 3,
    fullName: 'Johnathan Doe',
    email: 'john.doe@company.com',
    phone: '+1 (555) 000-0000',
    bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
    paymentMethods: paymentMethods,
    priceRows: [
      PriceBreakdownRow(label: 'Deluxe Ocean View (3 nights)', amount: 897),
      PriceBreakdownRow(label: 'Service Fee', amount: 45),
      PriceBreakdownRow(label: 'Occupancy Taxes', amount: 32.50),
    ],
    total: 974.50,
  );

  static CheckoutData fromBooking({
    required PropertyDetailsData property,
    required RoomOptionData room,
    required AuthUser? user,
    required String bookingId,
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
      bookingId: bookingId,
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
