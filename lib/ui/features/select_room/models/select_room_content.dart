import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';

abstract final class SelectRoomContent {
  static final oceanPearl = SelectRoomData(
    propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
    propertyName: 'Ocean Pearl Hotel',
    propertyImageAsset: AppAssets.oceanPearlHotel,
    dateRange: 'Jun 12 - Jun 15',
    checkIn: DateTime(2026, 6, 12),
    checkOut: DateTime(2026, 6, 15),
    adults: 2,
    children: 0,
    roomQuantity: 1,
    guests: 2,
    nights: 3,
    rooms: const [
      RoomOptionData(
        id: 'deluxe-ocean-view',
        imageAsset: AppAssets.deluxeOceanView,
        name: 'Deluxe Ocean View',
        maxGuests: 2,
        pricePerNight: 85,
        features: ['King Bed', 'Balcony', 'AC', 'Free Wifi'],
        policy: 'Instant Booking',
        policyPositive: true,
        badge: RoomBadge.bestSeller,
      ),
      RoomOptionData(
        id: 'standard-double-room',
        imageAsset: AppAssets.doubleRoom,
        name: 'Standard Double Room',
        maxGuests: 2,
        pricePerNight: 65,
        features: ['2 Twin Beds', 'AC', 'Smart TV'],
        policy: 'Non-refundable',
        policyPositive: false,
      ),
      RoomOptionData(
        id: 'executive-suite',
        imageAsset: AppAssets.executiveSuite,
        name: 'Executive Suite',
        maxGuests: 3,
        pricePerNight: 145,
        features: ['Master King', 'Living Area', 'Nespresso'],
        policy: 'Breakfast Included',
        policyPositive: true,
        badge: RoomBadge.premium,
      ),
    ],
  );
}
