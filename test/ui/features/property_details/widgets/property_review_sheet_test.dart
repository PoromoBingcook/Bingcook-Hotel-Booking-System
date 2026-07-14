import 'package:bingcook/domain/models/property_review.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_review_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('submits a rating without requiring a comment', (tester) async {
    final repository = FakeReviewRepository();
    final viewModel = PropertyDetailsViewModel(reviewRepository: repository);
    var savedCalls = 0;
    await _openSheet(
      tester,
      viewModel: viewModel,
      onSaved: () async => savedCalls++,
    );

    expect(find.text('Write a review'), findsOneWidget);
    expect(find.text('Submit review'), findsOneWidget);

    await tester.tap(find.byKey(const Key('review_star_5')));
    await tester.tap(find.byKey(const Key('review_submit_button')));
    await tester.pumpAndSettle();

    expect(repository.savedRating, 5);
    expect(repository.savedComment, isNull);
    expect(savedCalls, 1);
    expect(find.byType(PropertyReviewSheet), findsNothing);
  });

  testWidgets('prefills and updates an existing review', (tester) async {
    final repository = FakeReviewRepository(
      existing: _review(rating: 3, comment: 'Original comment'),
    );
    final viewModel = PropertyDetailsViewModel(reviewRepository: repository);
    await viewModel.loadMyReview('property-1');
    await _openSheet(tester, viewModel: viewModel);

    expect(find.text('Edit your review'), findsOneWidget);
    expect(find.text('Update review'), findsOneWidget);
    expect(find.text('Original comment'), findsOneWidget);

    await tester.tap(find.byKey(const Key('review_star_4')));
    await tester.enterText(
      find.byKey(const Key('review_comment_field')),
      'Updated comment',
    );
    await tester.tap(find.byKey(const Key('review_submit_button')));
    await tester.pumpAndSettle();

    expect(repository.savedRating, 4);
    expect(repository.savedComment, 'Updated comment');
  });

  testWidgets('keeps the sheet open and shows repository errors', (
    tester,
  ) async {
    final repository = FakeReviewRepository(
      error: const ReviewRepositoryException('Reviews unavailable.'),
    );
    final viewModel = PropertyDetailsViewModel(reviewRepository: repository);
    await _openSheet(tester, viewModel: viewModel);

    await tester.tap(find.byKey(const Key('review_star_2')));
    await tester.tap(find.byKey(const Key('review_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byType(PropertyReviewSheet), findsOneWidget);
    expect(find.byKey(const Key('review_sheet_error')), findsOneWidget);
    expect(find.text('Reviews unavailable.'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}

Future<void> _openSheet(
  WidgetTester tester, {
  required PropertyDetailsViewModel viewModel,
  Future<void> Function()? onSaved,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => PropertyReviewSheet(
                viewModel: viewModel,
                propertyId: 'property-1',
                onSaved: onSaved ?? () async {},
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

PropertyReview _review({required int rating, required String? comment}) {
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
