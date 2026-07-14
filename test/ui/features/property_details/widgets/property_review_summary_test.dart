import 'package:bingcook/ui/features/property_details/widgets/property_review_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('summary stars follow the rounded average rating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PropertyReviewSummary(
            distribution: [],
            rating: 0,
            reviewCount: 0,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PropertyReviewSummary(
            distribution: [],
            rating: 4.8,
            reviewCount: 4,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.byIcon(Icons.star_border_rounded), findsNothing);
  });
}
