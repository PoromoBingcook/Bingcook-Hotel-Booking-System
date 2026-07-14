class StayCardData {
  const StayCardData({
    required this.id,
    required this.imageAsset,
    required this.type,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.price,
    required this.status,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String imageAsset;
  final String? imageUrl;
  final String type;
  final String name;
  final String description;
  final String location;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final int price;
  final String status;

  bool get isAvailable => status.toLowerCase() != 'soldout';

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
