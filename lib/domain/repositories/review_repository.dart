import 'package:bingcook/domain/models/property_review.dart';

abstract interface class ReviewRepository {
  Future<PropertyReview?> fetchMyReview(String propertyId);

  Future<PropertyReview> saveReview({
    required String propertyId,
    required int rating,
    String? comment,
  });
}

class ReviewRepositoryException implements Exception {
  const ReviewRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
