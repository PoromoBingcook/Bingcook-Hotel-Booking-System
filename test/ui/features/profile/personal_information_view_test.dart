import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/ui/features/profile/views/personal_information_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows user information without exposing the user ID', (
    tester,
  ) async {
    var wentBack = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PersonalInformationView(
          user: const AuthUser(
            id: 'private-user-id',
            fullName: 'Jane Cook',
            email: 'jane@example.com',
            phone: '0900000000',
            role: 'Customer',
          ),
          onBack: () => wentBack = true,
        ),
      ),
    );

    expect(find.text('Jane Cook'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('0900000000'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('private-user-id'), findsNothing);

    expect(find.byType(TextField), findsNothing);
    expect(
      find.byKey(const Key('personal_information_save_button')),
      findsNothing,
    );
    expect(find.text('Customer'), findsOneWidget);

    await tester.tap(find.byKey(const Key('personal_information_back_button')));
    expect(wentBack, isTrue);
  });
}
