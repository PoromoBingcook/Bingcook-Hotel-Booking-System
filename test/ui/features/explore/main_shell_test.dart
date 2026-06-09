import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation switches destinations', (tester) async {
    await _pumpMainShell(tester);

    expect(find.text('Find your next stay'), findsOneWidget);

    await tester.tap(find.text('Đã lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Saved stays'), findsOneWidget);
  });

  testWidgets('explore search card opens search and close returns', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.tap(find.byKey(const Key('explore_search_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search_title')), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);

    await tester.tap(find.byKey(const Key('search_close_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('bottom navigation leaves search mode', (tester) async {
    await _pumpMainShell(tester);

    await tester.tap(find.byKey(const Key('explore_search_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đã lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Saved stays'), findsOneWidget);
    expect(find.byKey(const Key('search_title')), findsNothing);
  });

  testWidgets('Ocean Pearl opens details, toggles favorite, and returns', (
    tester,
  ) async {
    await _pumpMainShell(tester);

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
    await _pumpMainShell(tester);

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

  testWidgets('Continue to Payment opens checkout and back restores rooms', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const Key('property_book_now_button')))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deluxe Ocean View'));
    await tester.pump();
    tester
        .widget<FilledButton>(
          find.byKey(const Key('continue_to_payment_button')),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkout_title')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Price Breakdown'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Price Breakdown'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('payment_method_digitalWallet')),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('payment_method_digitalWallet')));
    await tester.pump();

    expect(
      find.byKey(const Key('payment_method_digitalWallet_selected')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('checkout_back_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
  });

  testWidgets('Confirm Booking opens Add Card and back restores checkout', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const Key('property_book_now_button')))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deluxe Ocean View'));
    await tester.pump();
    tester
        .widget<FilledButton>(
          find.byKey(const Key('continue_to_payment_button')),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const Key('confirm_booking_button')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_card_title')), findsOneWidget);
    expect(find.byKey(const Key('save_card_switch_on')), findsOneWidget);

    tester.widget<Switch>(find.byKey(const Key('save_card_switch'))).onChanged!(
      false,
    );
    await tester.pump();

    expect(find.byKey(const Key('save_card_switch_off')), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_card_back_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkout_title')), findsOneWidget);
  });

  testWidgets('profile tab logs out through repository', (tester) async {
    var loggedOut = false;
    final repository = FakeAuthRepository();

    await _pumpMainShell(
      tester,
      authRepository: repository,
      onLogoutCompleted: () => loggedOut = true,
    );

    await tester.tap(find.text('Tài khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Chào Jane Cook'), findsOneWidget);
    expect(find.text('Thông tin cá nhân'), findsOneWidget);
    expect(find.text('Cài đặt bảo mật'), findsNothing);
    expect(find.text('Người đi cùng'), findsNothing);
    expect(find.text('Tặng thưởng & Ví'), findsNothing);

    final profileScrollable = find.descendant(
      of: find.byKey(const Key('profile_scroll_view')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile_logout_button')),
      300,
      scrollable: profileScrollable,
    );
    await tester.tap(find.byKey(const Key('profile_logout_button')));
    await tester.pumpAndSettle();

    expect(repository.logoutCalled, isTrue);
    expect(loggedOut, isTrue);
  });
}

Future<void> _pumpMainShell(
  WidgetTester tester, {
  AuthRepository? authRepository,
  ProductRepository? productRepository,
  VoidCallback? onLogoutCompleted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MainShell(
        authRepository: authRepository ?? FakeAuthRepository(),
        productRepository: productRepository ?? const FakeProductRepository(),
        onLogoutCompleted: onLogoutCompleted ?? () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeAuthRepository implements AuthRepository {
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
    return const [
      Product(
        id: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
        type: 'Hotel',
        name: 'Ocean Pearl Hotel',
        description: 'Beachfront hotel near My Khe Beach.',
        location: 'Da Nang, Vo Nguyen Giap, Son Tra',
        city: 'Da Nang',
        address: 'Vo Nguyen Giap, Son Tra',
        imageUrl: null,
        rating: 4.7,
        reviewCount: 3,
        amenities: ['Wi-Fi', 'Pool'],
        pricePerNight: 68,
        status: 'Active',
      ),
      Product(
        id: 'c8622126-babc-4c88-a01f-8773fe5456a5',
        type: 'Homestay',
        name: 'Blue Garden Homestay',
        description: 'Quiet garden homestay in Cam Chau.',
        location: 'Hoi An, Cam Chau',
        city: 'Hoi An',
        address: 'Cam Chau',
        imageUrl: null,
        rating: 4.5,
        reviewCount: 2,
        amenities: ['Wi-Fi', 'Parking'],
        pricePerNight: 42,
        status: 'Active',
      ),
    ];
  }
}
