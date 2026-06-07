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
}
