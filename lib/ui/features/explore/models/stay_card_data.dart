class StayCardData {
  const StayCardData({
    required this.imageAsset,
    required this.type,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.price,
    this.imageUrl,
  });

  final String imageAsset;
  final String? imageUrl;
  final String type;
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final int price;
}
