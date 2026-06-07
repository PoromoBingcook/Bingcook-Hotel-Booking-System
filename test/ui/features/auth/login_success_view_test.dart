import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/features/auth/views/login_success_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('progress animates from empty and redirects to explore', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.explore: (_) => const Scaffold(body: Text('Explore ready')),
        },
        home: const LoginSuccessView(animationDuration: Duration(seconds: 1)),
      ),
    );

    var progress = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('login_success_progress')),
    );
    expect(progress.value, 0);

    await tester.pump(const Duration(milliseconds: 500));
    progress = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('login_success_progress')),
    );
    expect(progress.value, greaterThan(0));
    expect(progress.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Explore ready'), findsOneWidget);
  });
}
