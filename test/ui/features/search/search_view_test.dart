import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildView({VoidCallback? onClose}) {
    return MaterialApp(
      home: Scaffold(
        body: SearchView(
          viewModel: SearchViewModel(now: DateTime(2023, 6, 11)),
          onClose: onClose ?? () {},
          onSearch: (_) {},
        ),
      ),
    );
  }

  testWidgets('renders deterministic search content', (tester) async {
    await tester.pumpWidget(buildView());

    expect(find.byKey(const Key('search_title')), findsOneWidget);
    expect(find.text('Da Nang'), findsOneWidget);
    expect(find.text('Jun 12'), findsOneWidget);
    expect(find.text('Jun 15'), findsOneWidget);
    expect(find.byKey(const Key('adults_count_2')), findsOneWidget);
  });

  testWidgets('positions close button left of centered title', (tester) async {
    await tester.pumpWidget(buildView());

    final closeRect = tester.getRect(
      find.byKey(const Key('search_close_button')),
    );
    final titleRect = tester.getRect(find.byKey(const Key('search_title')));

    expect(closeRect.right, lessThan(titleRect.left));
  });

  testWidgets('clear and date controls update visible state', (tester) async {
    await tester.pumpWidget(buildView());

    await tester.tap(find.byKey(const Key('destination_clear_button')));
    await tester.tap(find.byKey(const Key('calendar_day_18')));
    await tester.pump();

    expect(find.text('Da Nang'), findsNothing);
    expect(find.text('Jun 18'), findsOneWidget);
    expect(find.text('Select date'), findsOneWidget);
  });

  testWidgets('guest controls respect boundaries and update counts', (
    tester,
  ) async {
    await tester.pumpWidget(buildView());

    await tester.ensureVisible(
      find.byKey(const Key('adults_decrement_button')),
    );
    await tester.tap(find.byKey(const Key('adults_decrement_button')));
    await tester.tap(find.byKey(const Key('adults_decrement_button')));
    await tester.tap(find.byKey(const Key('children_increment_button')));
    await tester.pump();

    expect(find.byKey(const Key('adults_count_1')), findsOneWidget);
    expect(find.byKey(const Key('children_count_1')), findsOneWidget);
  });

  testWidgets('amenity chips toggle selected state', (tester) async {
    await tester.pumpWidget(buildView());

    final wifiChip = find.byKey(const Key('amenity_Wi-Fi'));
    await tester.ensureVisible(wifiChip);
    await tester.tap(wifiChip);
    await tester.pump();

    final chip = tester.widget<FilterChip>(wifiChip);
    expect(chip.selected, isTrue);
  });
}
