import 'package:bingcook/app/app.dart';
import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows BingCook splash then opens sign up', (tester) async {
    await tester.pumpWidget(
      BingCookApp(
        splashDuration: const Duration(milliseconds: 300),
        dependencies: _testDependencies(),
      ),
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
      MaterialApp(
        home: SignUpView(
          viewModel: SignUpViewModel(authRepository: FakeAuthRepository()),
        ),
      ),
    );

    expect(find.byKey(const Key('full_name_field')), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('phone_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
  });

  testWidgets('sign up login link opens login screen', (tester) async {
    await tester.pumpWidget(
      BingCookApp(
        initialRoute: AppRoutes.signUp,
        dependencies: _testDependencies(),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('open_login_button')));
    await tester.tap(find.byKey(const Key('open_login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}

AppDependencies _testDependencies() {
  return AppDependencies.test(
    authRepository: FakeAuthRepository(),
    productRepository: const FakeProductRepository(),
  );
}

class FakeAuthRepository implements AuthRepository {
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
  Future<void> logout() async {}

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _session;
  }

  static final _session = AuthSession(
    token: 'jwt-token',
    user: AuthUser(
      id: 'c38d653b-3a56-49cf-9473-22edaa5f3a2c',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '+84901234567',
      role: 'Customer',
    ),
  );
}

class FakeProductRepository implements ProductRepository {
  const FakeProductRepository();

  @override
  Future<List<Product>> fetchProducts() async {
    return const [];
  }
}
