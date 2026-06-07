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
}
