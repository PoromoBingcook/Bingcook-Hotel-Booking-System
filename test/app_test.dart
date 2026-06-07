import 'package:bingcook/app/app.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows BingCook splash then opens sign up', (tester) async {
    await tester.pumpWidget(
      const BingCookApp(splashDuration: Duration(milliseconds: 300)),
    );

    expect(find.text('BingCook'), findsOneWidget);
    expect(find.text('Adventure begins with a single tap.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('sign up screen contains reusable form fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SignUpView(viewModel: SignUpViewModel())),
    );

    expect(find.byKey(const Key('full_name_field')), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('phone_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
  });

  testWidgets('sign up login link opens login screen', (tester) async {
    await tester.pumpWidget(const BingCookApp(initialRoute: AppRoutes.signUp));

    await tester.ensureVisible(find.byKey(const Key('open_login_button')));
    await tester.tap(find.byKey(const Key('open_login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
