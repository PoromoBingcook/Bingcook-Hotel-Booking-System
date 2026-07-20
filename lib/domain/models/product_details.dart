class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.address,
    required this.imageUrls,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
    required this.pricePerNight,
    required this.status,
    required this.checkInPolicy,
    required this.checkOutPolicy,
    required this.cancellationPolicy,
    required this.rooms,
    required this.ratingDistribution,
    required this.reviews,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String type;
  final String name;
  final String description;
  final String location;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final double pricePerNight;
  final String status;
  final String checkInPolicy;
  final String checkOutPolicy;
  final String cancellationPolicy;
  final List<ProductRoom> rooms;
  final List<ProductRatingBreakdown> ratingDistribution;
  final List<ProductReview> reviews;

  bool get isAvailable => rooms.isNotEmpty && status.toLowerCase() != 'soldout';
}

class ProductRoom {
  const ProductRoom({
    required this.id,
    required this.name,
    required this.maxGuests,
    required this.availableRooms,
    required this.pricePerNight,
    required this.imageUrl,
    required this.features,
    required this.policy,
  });

  final String id;
  final String name;
  final int maxGuests;
  final int availableRooms;
  final double pricePerNight;
  final String? imageUrl;
  final List<String> features;
  final String policy;
}

class ProductRatingBreakdown {
  const ProductRatingBreakdown({required this.stars, required this.fraction});

  final int stars;
  final double fraction;
}

class ProductReview {
  const ProductReview({
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
