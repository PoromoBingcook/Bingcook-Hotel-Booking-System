import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';

class ProductListItemResponse {
  const ProductListItemResponse({
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
    this.latitude,
    this.longitude,
  });

  factory ProductListItemResponse.fromJson(Map<String, Object?> json) {
    return ProductListItemResponse(
      id: _readString(json['id'], fallback: ''),
      type: _readString(json['type'], fallback: 'Stay'),
      name: _readString(json['name'], fallback: 'Unnamed stay'),
      description: _readString(json['description'], fallback: ''),
      location: _readString(json['location'], fallback: 'Vietnam'),
      city: _readString(json['city'], fallback: ''),
      address: _readString(json['address'], fallback: ''),
      latitude: _readOptionalDouble(json['latitude']),
      longitude: _readOptionalDouble(json['longitude']),
      imageUrl: _readOptionalString(json['imageUrl']),
      rating: _readDouble(json['rating']),
      reviewCount: _readInt(json['reviewCount']),
      amenities: _readStringList(json['amenities']),
      pricePerNight: _readDouble(json['pricePerNight']),
      status: _readString(json['status'], fallback: 'Available'),
    );
  }

  final String id;
  final String type;
  final String name;
  final String description;
  final String location;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final double pricePerNight;
  final String status;

  Product toDomain() {
    return Product(
      id: id,
      type: type,
      name: name,
      description: description,
      location: location,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      amenities: List.unmodifiable(amenities),
      pricePerNight: pricePerNight,
      status: status,
      isAvailable: status.toLowerCase() != 'soldout',
    );
  }

  static String _readString(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static String? _readOptionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  static double? _readOptionalDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List<Object?>) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }
}

class ProductDetailsResponse {
  const ProductDetailsResponse({
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
  });

  factory ProductDetailsResponse.fromJson(Map<String, Object?> json) {
    return ProductDetailsResponse(
      id: ProductListItemResponse._readString(json['id'], fallback: ''),
      type: ProductListItemResponse._readString(json['type'], fallback: 'Stay'),
      name: ProductListItemResponse._readString(
        json['name'],
        fallback: 'Unnamed stay',
      ),
      description: ProductListItemResponse._readString(
        json['description'],
        fallback: '',
      ),
      location: ProductListItemResponse._readString(
        json['location'],
        fallback: 'Vietnam',
      ),
      city: ProductListItemResponse._readString(json['city'], fallback: ''),
      address: ProductListItemResponse._readString(
        json['address'],
        fallback: '',
      ),
      imageUrls: ProductListItemResponse._readStringList(json['imageUrls']),
      rating: ProductListItemResponse._readDouble(json['rating']),
      reviewCount: ProductListItemResponse._readInt(json['reviewCount']),
      amenities: ProductListItemResponse._readStringList(json['amenities']),
      pricePerNight: ProductListItemResponse._readDouble(json['pricePerNight']),
      status: ProductListItemResponse._readString(
        json['status'],
        fallback: 'Available',
      ),
      checkInPolicy: ProductListItemResponse._readString(
        json['checkInPolicy'],
        fallback: 'Check-in from 14:00.',
      ),
      checkOutPolicy: ProductListItemResponse._readString(
        json['checkOutPolicy'],
        fallback: 'Check-out before 12:00.',
      ),
      cancellationPolicy: ProductListItemResponse._readString(
        json['cancellationPolicy'],
        fallback: 'Free cancellation up to 24 hours before check-in.',
      ),
      rooms: _readMapList(
        json['rooms'],
      ).map(ProductRoomResponse.fromJson).toList(growable: false),
      ratingDistribution: _readMapList(
        json['ratingDistribution'],
      ).map(ProductRatingBreakdownResponse.fromJson).toList(growable: false),
      reviews: _readMapList(
        json['reviews'],
      ).map(ProductReviewResponse.fromJson).toList(growable: false),
    );
  }

  final String id;
  final String type;
  final String name;
  final String description;
  final String location;
  final String city;
  final String address;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final List<String> amenities;
  final double pricePerNight;
  final String status;
  final String checkInPolicy;
  final String checkOutPolicy;
  final String cancellationPolicy;
  final List<ProductRoomResponse> rooms;
  final List<ProductRatingBreakdownResponse> ratingDistribution;
  final List<ProductReviewResponse> reviews;

  ProductDetails toDomain() {
    return ProductDetails(
      id: id,
      type: type,
      name: name,
      description: description,
      location: location,
      city: city,
      address: address,
      imageUrls: List.unmodifiable(imageUrls),
      rating: rating,
      reviewCount: reviewCount,
      amenities: List.unmodifiable(amenities),
      pricePerNight: pricePerNight,
      status: status,
      checkInPolicy: checkInPolicy,
      checkOutPolicy: checkOutPolicy,
      cancellationPolicy: cancellationPolicy,
      rooms: List.unmodifiable(rooms.map((room) => room.toDomain())),
      ratingDistribution: List.unmodifiable(
        ratingDistribution.map((item) => item.toDomain()),
      ),
      reviews: List.unmodifiable(reviews.map((review) => review.toDomain())),
    );
  }

  static List<Map<String, Object?>> _readMapList(Object? value) {
    if (value is! List<Object?>) {
      return const [];
    }
    return value.whereType<Map<String, Object?>>().toList(growable: false);
  }
}

class ProductRoomResponse {
  const ProductRoomResponse({
    required this.id,
    required this.name,
    required this.maxGuests,
    required this.pricePerNight,
    required this.imageUrl,
    required this.features,
    required this.policy,
  });

  factory ProductRoomResponse.fromJson(Map<String, Object?> json) {
    return ProductRoomResponse(
      id: ProductListItemResponse._readString(json['id'], fallback: ''),
      name: ProductListItemResponse._readString(
        json['name'],
        fallback: 'Available Room',
      ),
      maxGuests: ProductListItemResponse._readInt(json['maxGuests']),
      pricePerNight: ProductListItemResponse._readDouble(json['pricePerNight']),
      imageUrl: ProductListItemResponse._readOptionalString(json['imageUrl']),
      features: ProductListItemResponse._readStringList(json['features']),
      policy: ProductListItemResponse._readString(
        json['policy'],
        fallback: 'Instant Booking',
      ),
    );
  }

  final String id;
  final String name;
  final int maxGuests;
  final double pricePerNight;
  final String? imageUrl;
  final List<String> features;
  final String policy;

  ProductRoom toDomain() {
    return ProductRoom(
      id: id,
      name: name,
      maxGuests: maxGuests,
      pricePerNight: pricePerNight,
      imageUrl: imageUrl,
      features: List.unmodifiable(features),
      policy: policy,
    );
  }
}

class ProductRatingBreakdownResponse {
  const ProductRatingBreakdownResponse({
    required this.stars,
    required this.fraction,
  });

  factory ProductRatingBreakdownResponse.fromJson(Map<String, Object?> json) {
    return ProductRatingBreakdownResponse(
      stars: ProductListItemResponse._readInt(json['stars']),
      fraction: ProductListItemResponse._readDouble(json['fraction']),
    );
  }

  final int stars;
  final double fraction;

  ProductRatingBreakdown toDomain() {
    return ProductRatingBreakdown(stars: stars, fraction: fraction);
  }
}

class ProductReviewResponse {
  const ProductReviewResponse({
    required this.author,
    required this.rating,
    required this.timeAgo,
    required this.comment,
  });

  factory ProductReviewResponse.fromJson(Map<String, Object?> json) {
    return ProductReviewResponse(
      author: ProductListItemResponse._readString(
        json['author'],
        fallback: 'Guest',
      ),
      rating: ProductListItemResponse._readInt(json['rating']),
      timeAgo: ProductListItemResponse._readString(
        json['timeAgo'],
        fallback: 'Recently',
      ),
      comment: ProductListItemResponse._readString(
        json['comment'],
        fallback: '',
      ),
    );
  }

  final String author;
  final int rating;
  final String timeAgo;
  final String comment;

  ProductReview toDomain() {
    return ProductReview(
      author: author,
      rating: rating,
      timeAgo: timeAgo,
      comment: comment,
    );
  }
}
