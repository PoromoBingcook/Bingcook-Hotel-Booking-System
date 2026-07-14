class PropertyReview {
  const PropertyReview({
    required this.id,
    required this.propertyId,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  final String id;
  final String propertyId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
}
