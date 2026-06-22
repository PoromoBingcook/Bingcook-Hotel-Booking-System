class Product {
  const Product({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.pricePerNight,
    required this.status,
    required this.isAvailable,
  });

  final String id;
  final String type;
  final String name;
  final String description;
  final String location;
  final String city;
  final String address;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final double pricePerNight;
  final String status;
  final bool isAvailable;
}
