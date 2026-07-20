import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PropertyDetailsViewModel reviews', () {
    test('loads the current review and preselects its rating', () async {
      final repository = FakeReviewRepository(existing: _review(rating: 4));
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository);

      await viewModel.loadMyReview('property-1');

      expect(viewModel.myReview?.rating, 4);
      expect(viewModel.selectedRating, 4);
      expect(viewModel.isLoadingReview, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('clears stale review while loading another property', () async {
      final repository = FakeReviewRepository(existing: _review(rating: 4));
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository);
      await viewModel.loadMyReview('property-1');
      repository.existing = null;

      await viewModel.loadMyReview('property-2');

      expect(viewModel.myReview, isNull);
      expect(viewModel.selectedRating, 0);
    });

    test('submits a trimmed optional comment', () async {
      final repository = FakeReviewRepository();
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository)
        ..selectRating(5);

      final saved = await viewModel.submitReview(
        propertyId: 'property-1',
        comment: '  Nice stay  ',
      );

      expect(saved, isTrue);
      expect(repository.savedRating, 5);
      expect(repository.savedComment, 'Nice stay');
      expect(viewModel.myReview?.rating, 5);
      expect(viewModel.isSubmittingReview, isFalse);
    });

    test('submits a rating without a comment', () async {
      final repository = FakeReviewRepository();
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository)
        ..selectRating(3);

      final saved = await viewModel.submitReview(
        propertyId: 'property-1',
        comment: '   ',
      );

      expect(saved, isTrue);
      expect(repository.savedComment, isNull);
    });

    test('rejects submission until a rating is selected', () async {
      final repository = FakeReviewRepository();
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository);

      final saved = await viewModel.submitReview(
        propertyId: 'property-1',
        comment: null,
      );

      expect(saved, isFalse);
      expect(viewModel.errorMessage, 'Choose a rating from 1 to 5 stars.');
      expect(repository.savedRating, isNull);
    });

    test('keeps the draft when saving fails', () async {
      final repository = FakeReviewRepository(
        error: const ReviewRepositoryException('Reviews unavailable.'),
      );
      final viewModel = PropertyDetailsViewModel(reviewRepository: repository)
        ..selectRating(2);

      final saved = await viewModel.submitReview(
        propertyId: 'property-1',
        comment: 'Try later',
      );

      expect(saved, isFalse);
      expect(viewModel.selectedRating, 2);
      expect(viewModel.errorMessage, 'Reviews unavailable.');
      expect(viewModel.isSubmittingReview, isFalse);
    });

    test('updates stay dates and guests while preserving search filters', () {
      final viewModel = PropertyDetailsViewModel(
        reviewRepository: FakeReviewRepository(),
        now: DateTime(2026, 7, 17),
      );
      const baseQuery = ProductSearchQuery(location: 'Da Nang', type: 'Hotel');

      viewModel.configure(baseQuery);
      viewModel.updateDates(
        DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 13)),
      );
      viewModel.incrementGuests();
      final query = viewModel.buildQuery(baseQuery);

      expect(query.location, 'Da Nang');
      expect(query.type, 'Hotel');
      expect(query.checkIn, DateTime(2026, 8, 10));
      expect(query.checkOut, DateTime(2026, 8, 13));
      expect(query.guests, 3);
    });

    test('clamps configured past dates to today', () {
      final viewModel = PropertyDetailsViewModel(
        reviewRepository: FakeReviewRepository(),
        now: DateTime(2026, 7, 17, 18),
      );
      final query = ProductSearchQuery(
        checkIn: DateTime(2026, 7, 10),
        checkOut: DateTime(2026, 7, 12),
      );

      viewModel.configure(query);

      expect(viewModel.checkIn, DateTime(2026, 7, 17));
      expect(viewModel.checkOut, DateTime(2026, 7, 18));
    });

    test('ignores a date range that starts before today', () {
      final viewModel = PropertyDetailsViewModel(
        reviewRepository: FakeReviewRepository(),
        now: DateTime(2026, 7, 17),
      );

      viewModel.updateDates(
        DateTimeRange(start: DateTime(2026, 7, 16), end: DateTime(2026, 7, 19)),
      );

      expect(viewModel.checkIn, DateTime(2026, 7, 18));
      expect(viewModel.checkOut, DateTime(2026, 7, 19));
    });
  });
}

PropertyReview _review({required int rating, String? comment}) {
  return PropertyReview(
    id: 'review-1',
    propertyId: 'property-1',
    rating: rating,
    comment: comment,
    createdAt: DateTime.utc(2026, 7, 15, 2),
  );
}

class FakeReviewRepository implements ReviewRepository {
  FakeReviewRepository({this.existing, this.error});

  PropertyReview? existing;
  final ReviewRepositoryException? error;
  int? savedRating;
  String? savedComment;

  @override
  Future<PropertyReview?> fetchMyReview(String propertyId) async {
    final error = this.error;
    if (error != null) throw error;
    return existing;
  }

  @override
  Future<PropertyReview> saveReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final error = this.error;
    if (error != null) throw error;
    savedRating = rating;
    savedComment = comment;
    return _review(rating: rating, comment: comment);
  }
}
