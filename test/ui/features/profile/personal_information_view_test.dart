import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
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
          viewModel: ProfileViewModel(authRepository: _ProfileRepository()),
          onBack: () => wentBack = true,
        ),
      ),
    );

    expect(find.text('Jane Cook'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('0900000000'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('private-user-id'), findsNothing);

    expect(find.byType(TextField), findsNWidgets(2));
    expect(
      find.byKey(const Key('personal_information_save_button')),
      findsOneWidget,
    );
    expect(find.text('Customer'), findsOneWidget);

    await tester.tap(find.byKey(const Key('personal_information_back_button')));
    expect(wentBack, isTrue);
  });
}

class _ProfileRepository
    implements AuthRepository, EditableProfileAuthRepository {
  AuthSession _session = const AuthSession(
    token: 'token',
    user: AuthUser(
      id: 'private-user-id',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '0900000000',
      role: 'Customer',
    ),
  );

  @override
  AuthSession get currentSession => _session;

  @override
  Future<AuthSession> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    _session = AuthSession(
      token: _session.token,
      user: AuthUser(
        id: _session.user.id,
        fullName: fullName,
        email: _session.user.email,
        phone: phone,
        role: _session.user.role,
      ),
    );
    return _session;
  }

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async => _session;
  @override
  Future<void> logout() async {}
  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {}
}
