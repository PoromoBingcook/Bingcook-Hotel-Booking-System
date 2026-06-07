class SelectRoomData {
  const SelectRoomData({
    required this.propertyName,
    required this.propertyImageAsset,
    required this.dateRange,
    required this.guests,
    required this.nights,
    required this.rooms,
  });

  final String propertyName;
  final String propertyImageAsset;
  final String dateRange;
  final int guests;
  final int nights;
  final List<RoomOptionData> rooms;
}

class RoomOptionData {
  const RoomOptionData({
    required this.id,
    required this.imageAsset,
    required this.name,
    required this.maxGuests,
    required this.pricePerNight,
    required this.features,
    required this.policy,
    required this.policyPositive,
    this.badge,
  });

  final String id;
  final String imageAsset;
  final String name;
  final int maxGuests;
  final int pricePerNight;
  final List<String> features;
  final String policy;
  final bool policyPositive;
  final RoomBadge? badge;
}

enum RoomBadge { bestSeller, premium }
