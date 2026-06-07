import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';

abstract final class SelectRoomContent {
  static const oceanPearl = SelectRoomData(
    propertyName: 'Ocean Pearl Hotel',
    propertyImageAsset: AppAssets.oceanPearlHotel,
    dateRange: 'Jun 12 - Jun 15',
    guests: 2,
    nights: 3,
    rooms: [
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
