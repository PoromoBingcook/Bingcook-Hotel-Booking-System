import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';

class PropertyDetailsData {
  const PropertyDetailsData({
    required this.imageAsset,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.checkIn,
    required this.checkOut,
    required this.amenities,
    required this.ratingDistribution,
    required this.summaryRating,
    required this.summaryReviewCount,
    required this.reviews,
    this.id = '',
    this.type = 'Hotel',
    this.description = '',
    this.address = '',
    this.imageUrls = const [],
    this.imageUrl,
    this.status = 'Available',
    this.checkInPolicy = '',
    this.checkOutPolicy = '',
    this.cancellationPolicy = '',
    this.rooms = const [],
    this.latitude,
    this.longitude,
  });

  final String id;
  final String imageAsset;
  final List<String> imageUrls;
  final String? imageUrl;
  final String type;
  final String name;
  final String description;
  final String location;
  final String address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int reviewCount;
  final int pricePerNight;
  final String status;
  final String checkIn;
  final String checkOut;
  final String checkInPolicy;
  final String checkOutPolicy;
  final String cancellationPolicy;
  final List<PropertyAmenityData> amenities;
  final List<RoomOptionData> rooms;
  final List<RatingDistributionData> ratingDistribution;
  final double summaryRating;
  final int summaryReviewCount;
  final List<GuestReviewData> reviews;

  bool get canBook => rooms.isNotEmpty && status.toLowerCase() != 'soldout';

  bool get hasCoordinates {
    final latitude = this.latitude;
    final longitude = this.longitude;
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180;
  }
}

class PropertyAmenityData {
  const PropertyAmenityData({required this.type, required this.label});

  final PropertyAmenityType type;
  final String label;
}

enum PropertyAmenityType {
  wifi,
  pool,
  gym,
  parking,
  selfCheckIn,
  airConditioning,
  breakfast,
  pets,
  restaurant,
  spa,
  airportShuttle,
  laundry,
  bar,
  roomService,
  beach,
  kitchen,
  television,
  elevator,
  generic,
}

PropertyAmenityType propertyAmenityTypeFor(String label) {
  final normalized = label.toLowerCase().trim();

  if (_containsAny(normalized, const ['wi-fi', 'wifi', 'internet'])) {
    return PropertyAmenityType.wifi;
  }
  if (_containsAny(normalized, const ['pool', 'swim', 'hồ bơi', 'bể bơi'])) {
    return PropertyAmenityType.pool;
  }
  if (_containsAny(normalized, const ['gym', 'fitness'])) {
    return PropertyAmenityType.gym;
  }
  if (_containsAny(normalized, const ['parking', 'car park', 'đỗ xe'])) {
    return PropertyAmenityType.parking;
  }
  if (_containsAny(normalized, const ['self check-in', 'self checkin'])) {
    return PropertyAmenityType.selfCheckIn;
  }
  if (_containsAny(normalized, const [
    'air conditioning',
    'air conditioner',
    'a/c',
    'ac',
    'điều hòa',
  ])) {
    return PropertyAmenityType.airConditioning;
  }
  if (_containsAny(normalized, const ['breakfast', 'bữa sáng'])) {
    return PropertyAmenityType.breakfast;
  }
  if (_containsAny(normalized, const ['pet', 'thú cưng'])) {
    return PropertyAmenityType.pets;
  }
  if (_containsAny(normalized, const ['restaurant', 'nhà hàng'])) {
    return PropertyAmenityType.restaurant;
  }
  if (_containsAny(normalized, const ['spa', 'massage', 'sauna'])) {
    return PropertyAmenityType.spa;
  }
  if (_containsAny(normalized, const [
    'airport',
    'shuttle',
    'transfer',
    'đưa đón',
  ])) {
    return PropertyAmenityType.airportShuttle;
  }
  if (_containsAny(normalized, const ['laundry', 'giặt ủi', 'giặt là'])) {
    return PropertyAmenityType.laundry;
  }
  if (_containsAny(normalized, const ['bar', 'minibar'])) {
    return PropertyAmenityType.bar;
  }
  if (_containsAny(normalized, const ['room service', 'dịch vụ phòng'])) {
    return PropertyAmenityType.roomService;
  }
  if (_containsAny(normalized, const ['beach', 'bãi biển'])) {
    return PropertyAmenityType.beach;
  }
  if (_containsAny(normalized, const ['kitchen', 'bếp'])) {
    return PropertyAmenityType.kitchen;
  }
  if (_containsAny(normalized, const ['television', 'tv', 'smart tv'])) {
    return PropertyAmenityType.television;
  }
  if (_containsAny(normalized, const ['elevator', 'lift', 'thang máy'])) {
    return PropertyAmenityType.elevator;
  }
  return PropertyAmenityType.generic;
}

bool _containsAny(String value, List<String> keywords) {
  return keywords.any((keyword) {
    if (keyword == 'ac' || keyword == 'tv') {
      return value == keyword;
    }
    return value.contains(keyword);
  });
}

class RatingDistributionData {
  const RatingDistributionData({required this.stars, required this.fraction});

  final int stars;
  final double fraction;
}

class GuestReviewData {
  const GuestReviewData({
    required this.author,
    required this.rating,
    required this.timeAgo,
    required this.comment,
    this.id = '',
  });

  final String author;
  final int rating;
  final String timeAgo;
  final String comment;
  final String id;
}
