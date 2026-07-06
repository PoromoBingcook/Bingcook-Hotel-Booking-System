import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation switches destinations', (tester) async {
    await _pumpMainShell(tester);

    expect(find.text('Find your next stay'), findsOneWidget);

    await tester.tap(find.text('ÄÃ£ lÆ°u'));
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
    await tester.tap(find.text('ÄÃ£ lÆ°u'));
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

  testWidgets('selecting another stay opens details with its product data', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.scrollUntilVisible(find.text('Blue Garden Homestay'), 300);
    await tester.tap(
      find.byKey(const Key('stay_card_c8622126-babc-4c88-a01f-8773fe5456a5')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('property_details_title')), findsOneWidget);
    expect(find.text('Blue Garden Homestay'), findsOneWidget);
    expect(find.text('Hoi An - Cam Chau'), findsOneWidget);
    expect(find.text('42 VND/night'), findsOneWidget);
    final detailsScrollable = find.byKey(
      const Key('property_details_scroll_view'),
    );
    await tester.drag(detailsScrollable, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Quiet garden homestay in Cam Chau.'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);
    await tester.drag(detailsScrollable, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Guest Reviews'), findsOneWidget);
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

  testWidgets('Book Now carries selected property into room selection', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.scrollUntilVisible(find.text('Blue Garden Homestay'), 300);
    await tester.tap(
      find.byKey(const Key('stay_card_c8622126-babc-4c88-a01f-8773fe5456a5')),
    );
    await tester.pumpAndSettle();
    tester
        .widget<FilledButton>(find.byKey(const Key('property_book_now_button')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
    expect(find.text('Blue Garden Homestay'), findsOneWidget);
    expect(find.text('Jun 12 - Jun 15'), findsOneWidget);
    expect(find.text('2 guests'), findsOneWidget);
    expect(find.text('Deluxe Ocean View'), findsOneWidget);
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
      find.byKey(const Key('payment_method_payAtProperty')),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('payment_method_payAtProperty')));
    await tester.pump();

    expect(
      find.byKey(const Key('payment_method_payAtProperty_selected')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('checkout_back_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
  });

  testWidgets('Confirm Booking opens PayOS result and closes to explore', (
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

    expect(find.byKey(const Key('payment_result_title')), findsOneWidget);
    expect(find.text('PayOS checkout ready'), findsOneWidget);
    expect(find.byKey(const Key('payos_checkout_webview')), findsOneWidget);
    expect(
      find.text('Embedded PayOS: https://pay.payos.vn/web/88001234'),
      findsOneWidget,
    );
    expect(find.text('255 VND'), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_result_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('profile tab logs out through repository', (tester) async {
    var loggedOut = false;
    final repository = FakeAuthRepository();

    await _pumpMainShell(
      tester,
      authRepository: repository,
      onLogoutCompleted: () => loggedOut = true,
    );

    await tester.tap(find.text('TÃ i khoáº£n'));
    await tester.pumpAndSettle();

    expect(find.text('ChÃ o Jane Cook'), findsOneWidget);
    expect(find.text('ThÃ´ng tin cÃ¡ nhÃ¢n'), findsOneWidget);
    expect(find.text('CÃ i Ä‘áº·t báº£o máº­t'), findsNothing);
    expect(find.text('NgÆ°á»i Ä‘i cÃ¹ng'), findsNothing);
    expect(find.text('Táº·ng thÆ°á»Ÿng & VÃ­'), findsNothing);

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
  BookingRepository? bookingRepository,
  VoidCallback? onLogoutCompleted,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MainShell(
        authRepository: authRepository ?? FakeAuthRepository(),
        productRepository: productRepository ?? const FakeProductRepository(),
        bookingRepository: bookingRepository ?? const FakeBookingRepository(),
        chatRepository: const FakeChatRepository(),
        onLogoutCompleted: onLogoutCompleted ?? () {},
        payOSCheckoutBuilder: (url) => Text(
          'Embedded PayOS: $url',
          key: const Key('payos_checkout_webview'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeChatRepository implements ChatRepository {
  const FakeChatRepository();

  @override
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  }) async {
    return ChatConversation(
      id: 'conversation-1',
      propertyId: propertyId,
      propertyName: 'Ocean Pearl Hotel',
      bookingId: bookingId,
      customerUserId: 'user-1',
      customerName: 'Jane Cook',
      status: 'Open',
      createdAt: DateTime(2026, 7, 5, 8),
      updatedAt: DateTime(2026, 7, 5, 8),
    );
  }

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    return const [];
  }

  @override
  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) async {
    return const [];
  }

  @override
  Future<void> markRead({required String conversationId}) async {}

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    return ChatMessage(
      id: 'message-1',
      conversationId: conversationId,
      senderUserId: 'user-1',
      senderName: 'Jane Cook',
      body: body,
      createdAt: DateTime(2026, 7, 5, 8, 10),
    );
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
  Future<List<Product>> fetchProducts({
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
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
        isAvailable: true,
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
        isAvailable: true,
      ),
    ];
  }

  @override
  Future<ProductDetails> fetchProductDetails(
    String id, {
    ProductSearchQuery query = const ProductSearchQuery(),
  }) async {
    final product = (await fetchProducts()).firstWhere(
      (product) => product.id == id,
    );

    return ProductDetails(
      id: product.id,
      type: product.type,
      name: product.name,
      description: product.description,
      location: product.location,
      city: product.city,
      address: product.address,
      imageUrls: const [],
      rating: product.rating,
      reviewCount: product.reviewCount,
      amenities: product.amenities,
      pricePerNight: product.pricePerNight,
      status: product.status,
      checkInPolicy: 'Check-in from 14:00.',
      checkOutPolicy: 'Check-out before 12:00.',
      cancellationPolicy: 'Free cancellation up to 24 hours before check-in.',
      rooms: const [
        ProductRoom(
          id: 'deluxe-ocean-view',
          name: 'Deluxe Ocean View',
          maxGuests: 2,
          pricePerNight: 85,
          imageUrl: null,
          features: ['King Bed', 'Balcony', 'AC', 'Free Wifi'],
          policy: 'Instant Booking',
        ),
      ],
      ratingDistribution: const [
        ProductRatingBreakdown(stars: 5, fraction: 0.8),
        ProductRatingBreakdown(stars: 4, fraction: 0.2),
      ],
      reviews: const [],
    );
  }
}
