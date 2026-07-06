import 'package:bingcook/app/app.dart';
import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows BingCook splash then opens login', (tester) async {
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

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
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
    expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
  });

  testWidgets('restores a saved session and opens the authenticated app', (
    tester,
  ) async {
    final authRepository = _RestoringAuthRepository();
    await tester.pumpWidget(
      BingCookApp(
        splashDuration: const Duration(milliseconds: 1),
        dependencies: _testDependencies(authRepository: authRepository),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(authRepository.didRestore, isTrue);
    expect(find.text('Find your next stay'), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsNothing);
  });

  testWidgets('sign up validates password confirmation after field blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignUpView(
          viewModel: SignUpViewModel(authRepository: FakeAuthRepository()),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('password_field')),
      'Password123',
    );
    await tester.enterText(
      find.byKey(const Key('confirm_password_field')),
      'Different123',
    );
    await tester.pump();

    expect(find.text('Passwords do not match'), findsNothing);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('sign up validates one invalid field after tapping away', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignUpView(
          viewModel: SignUpViewModel(authRepository: FakeAuthRepository()),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('email_field')), 'not-email');
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsNothing);

    await tester.tap(find.text('Create Account'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter your full name'), findsNothing);
    expect(find.text('Enter your phone number'), findsNothing);
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

AppDependencies _testDependencies({AuthRepository? authRepository}) {
  return AppDependencies.test(
    authRepository: authRepository ?? FakeAuthRepository(),
    productRepository: const FakeProductRepository(),
    bookingRepository: const FakeBookingRepository(),
  );
}

class _RestoringAuthRepository extends FakeAuthRepository
    implements RestorableAuthRepository {
  bool didRestore = false;

  @override
  Future<void> restoreSession() async {
    didRestore = true;
    _currentSession = FakeAuthRepository._session;
  }
}

class FakeAuthRepository implements AuthRepository {
  AuthSession? _currentSession;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _currentSession = _session;
  }

  @override
  Future<void> logout() async => _currentSession = null;

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _currentSession = _session;
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
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    return const [];
  }

  @override
  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) {
    throw UnimplementedError();
  }
}

class FakeBookingRepository implements BookingRepository {
  const FakeBookingRepository();

  @override
  Future<List<BookingReservation>> fetchReservations() async => const [];

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) async {
    return BookingDraft(
      bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
      propertyId: command.propertyId,
      propertyName: 'Ocean Pearl Hotel',
      roomId: command.roomId,
      roomName: 'Deluxe Ocean View',
      roomType: 'Deluxe',
      checkIn: command.checkIn,
      checkOut: command.checkOut,
      nights: command.checkOut.difference(command.checkIn).inDays,
      adults: command.adults,
      children: command.children,
      totalGuests: command.adults + command.children,
      roomQuantity: command.roomQuantity,
      maxGuests: 2,
      availableRooms: 3,
      roomSubtotal: 255,
      addOnSubtotal: 0,
      totalPrice: 255,
      addOns: const [],
      note: command.note,
      nextAction: 'ProceedToConfirmationPayment',
    );
  }

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) async {
    return const BookingCheckout(
      bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
      bookingStatus: 'PendingPayment',
      paymentMethod: 'PayOS',
      paymentStatus: 'Pending',
      amount: 255,
      transactionCode: '88001234',
      paymentLinkId: 'payos-link-id',
      checkoutUrl: 'https://pay.payos.vn/web/88001234',
      qrCode: 'qr-code-payload',
      message: 'Open checkoutUrl to pay with PayOS.',
    );
  }
}
