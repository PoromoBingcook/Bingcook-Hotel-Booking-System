import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation switches destinations', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.text('Find your next stay'), findsOneWidget);

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('Saved stays'), findsOneWidget);
  });

  testWidgets('explore search card opens search and close returns', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.byKey(const Key('explore_search_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search_title')), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);

    await tester.tap(find.byKey(const Key('search_close_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('bottom navigation leaves search mode', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.byKey(const Key('explore_search_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('Saved stays'), findsOneWidget);
    expect(find.byKey(const Key('search_title')), findsNothing);
  });

  testWidgets('Ocean Pearl opens details, toggles favorite, and returns', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('property_details_title')), findsOneWidget);
    expect(find.text('Book Now'), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_favorite_button')));
    await tester.pump();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('Book Now opens room selection and updates total', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    final bookNowButton = tester.widget<FilledButton>(
      find.byKey(const Key('property_book_now_button')),
    );
    bookNowButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
    expect(find.byKey(const Key('select_room_total_0')), findsOneWidget);

    await tester.tap(find.text('Deluxe Ocean View'));
    await tester.pump();

    expect(find.byKey(const Key('select_room_total_255')), findsOneWidget);

    await tester.tap(find.byKey(const Key('select_room_back_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('property_details_title')), findsOneWidget);
  });
}
