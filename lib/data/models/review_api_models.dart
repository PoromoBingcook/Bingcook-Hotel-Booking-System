import 'package:bingcook/domain/models/property_review.dart';

class ReviewApiResponse {
  const ReviewApiResponse({
    required this.id,
    required this.propertyId,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  factory ReviewApiResponse.fromJson(Map<String, Object?> json) {
    return ReviewApiResponse(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  final String id;
  final String propertyId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  PropertyReview toDomain() {
    return PropertyReview(
      id: id,
      propertyId: propertyId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}
