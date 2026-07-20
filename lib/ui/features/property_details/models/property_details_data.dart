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

enum PropertyAmenityType { wifi, pool, gym, parking }

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
