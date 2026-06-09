import 'package:bingcook/domain/models/product.dart';

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
      imageUrl: _readOptionalString(json['imageUrl']),
      rating: _readDouble(json['rating']),
      reviewCount: _readInt(json['reviewCount']),
      amenities: _readStringList(json['amenities']),
      pricePerNight: _readDouble(json['pricePerNight']),
      status: _readString(json['status'], fallback: ''),
    );
  }

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

  Product toDomain() {
    return Product(
      id: id,
      type: type,
      name: name,
      description: description,
      location: location,
      city: city,
      address: address,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      amenities: List.unmodifiable(amenities),
      pricePerNight: pricePerNight,
      status: status,
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
