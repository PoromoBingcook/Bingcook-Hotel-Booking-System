import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:bingcook/ui/features/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Figma profile with API-backed account data', (
    tester,
  ) async {
    final callbacks = _ProfileCallbacks();

    await _pumpProfile(tester, callbacks: callbacks);

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Jane Cook'), findsWidgets);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('+84901234567'), findsOneWidget);
    expect(find.text('John Doe'), findsNothing);
    expect(find.text('Travel Enthusiast'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_logout_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('profile_logout_button')), findsOneWidget);
  });

  testWidgets('keeps profile actions wired to existing callbacks', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    final callbacks = _ProfileCallbacks();

    await _pumpProfile(
      tester,
      authRepository: repository,
      callbacks: callbacks,
      unreadNotifications: 3,
    );

    await tester.tap(find.byKey(const Key('profile_messages_button')));
    await tester.tap(find.byKey(const Key('profile_notifications_button')));
    await tester.tap(find.byKey(const Key('profile_personal_info_item')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_support_item')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile_support_item')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_logout_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile_logout_button')));
    await tester.pumpAndSettle();

    expect(callbacks.messagesOpened, isTrue);
    expect(callbacks.notificationsOpened, isTrue);
    expect(callbacks.personalInformationOpened, isTrue);
    expect(callbacks.supportOpened, isTrue);
    expect(repository.logoutCalled, isTrue);
    expect(callbacks.loggedOut, isTrue);
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  _FakeAuthRepository? authRepository,
  required _ProfileCallbacks callbacks,
  int unreadNotifications = 0,
}) async {
  final repository = authRepository ?? _FakeAuthRepository();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProfileView(
          viewModel: ProfileViewModel(authRepository: repository),
          unreadNotifications: unreadNotifications,
          onMessagesRequested: () => callbacks.messagesOpened = true,
          onNotificationsRequested: () => callbacks.notificationsOpened = true,
          onPersonalInformationRequested: () =>
              callbacks.personalInformationOpened = true,
          onSupportRequested: () => callbacks.supportOpened = true,
          onLoggedOut: () => callbacks.loggedOut = true,
        ),
      ),
    ),
  );
}

class _ProfileCallbacks {
  bool messagesOpened = false;
  bool notificationsOpened = false;
  bool personalInformationOpened = false;
  bool supportOpened = false;
  bool loggedOut = false;
}

class _FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _session;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _session;
  }

  static const _session = AuthSession(
    token: 'jwt-token',
    user: AuthUser(
      id: 'user-1',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '+84901234567',
      role: 'Customer',
    ),
  );
}
