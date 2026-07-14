import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/models/notification_item.dart';
import 'package:bingcook/domain/models/product.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';
import 'package:bingcook/ui/features/checkout/views/payment_result_view.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bottom navigation switches destinations', (tester) async {
    await _pumpMainShell(tester);

    expect(find.text('Find your next stay'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom_nav_1')));
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

  testWidgets('explore opens nearby map and returns', (tester) async {
    await _pumpMainShell(tester);

    await tester.tap(find.byKey(const Key('explore_map_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('nearby_map_title')), findsOneWidget);
    expect(
      find.byKey(
        const Key('nearby_map_marker_c8622126-babc-4c88-a01f-8773fe5456a5'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const Key('nearby_map_marker_c8622126-babc-4c88-a01f-8773fe5456a5'),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('nearby_map_view_stay_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('property_details_title')), findsOneWidget);
    expect(find.text('Blue Garden Homestay'), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_back_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nearby_map_title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nearby_map_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('bottom navigation leaves search mode', (tester) async {
    await _pumpMainShell(tester);

    await tester.tap(find.byKey(const Key('explore_search_card')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_nav_1')));
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('property_book_now_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_favorite_button')));
    await tester.pump();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next stay'), findsOneWidget);
  });

  testWidgets('saved stay persists in Saved tab and can be removed', (
    tester,
  ) async {
    final savedRepository = FakeSavedPropertyRepository();
    await _pumpMainShell(tester, savedPropertyRepository: savedRepository);

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('property_favorite_button')));
    await tester.pumpAndSettle();

    expect(savedRepository.savedIds, contains(_oceanPearlId));
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('property_back_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottom_nav_1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved_stays_title')), findsOneWidget);
    expect(find.text('Ocean Pearl Hotel'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stay_saved_button_$_oceanPearlId')));
    await tester.pumpAndSettle();

    expect(savedRepository.savedIds, isEmpty);
    expect(find.text('No saved stays yet'), findsOneWidget);
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
    expect(find.text('Hoi An, Cam Chau'), findsOneWidget);
    expect(find.text('42 VND/night'), findsOneWidget);
    final detailsScrollable = find.byKey(
      const Key('property_details_scroll_view'),
    );
    await tester.drag(detailsScrollable, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Quiet garden homestay in Cam Chau.'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Guest Reviews'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Guest Reviews'), findsOneWidget);
  });

  testWidgets('Book Now opens room selection and updates total', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final bookNowButton = tester.widget<FilledButton>(
      find.byKey(const Key('property_book_now_button')),
    );
    bookNowButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
    expect(find.byKey(const Key('select_room_total_0')), findsOneWidget);

    await tester.tap(find.text('Deluxe Ocean View'));
    await tester.pump();

    expect(find.byKey(const Key('select_room_total_85')), findsOneWidget);

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
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    tester
        .widget<FilledButton>(find.byKey(const Key('property_book_now_button')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('select_room_title')), findsOneWidget);
    expect(find.text('Blue Garden Homestay'), findsOneWidget);
    expect(find.text('2 guests'), findsOneWidget);
    expect(find.text('Deluxe Ocean View'), findsOneWidget);
  });

  testWidgets('Continue to Payment opens checkout and back restores rooms', (
    tester,
  ) async {
    await _pumpMainShell(tester);

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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

  testWidgets('PayOS return refreshes data and opens bookings', (tester) async {
    final repository = PaidBookingRepository();
    await _pumpMainShell(
      tester,
      bookingRepository: repository,
      payOSCheckoutBuilder: (url, onPageFinished) => FilledButton(
        key: const Key('payos_complete_button'),
        onPressed: () => onPageFinished(
          'https://bingcook-api.mascoteach.com/api/payments/payos/return?orderCode=1',
        ),
        child: const Text('Complete PayOS'),
      ),
    );

    await tester.tap(find.text('Ocean Pearl Hotel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('property_book_now_button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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

    await tester.tap(find.byKey(const Key('payos_complete_button')));
    await tester.pumpAndSettle();

    expect(find.text('My Reservations'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Room booked successfully.'), findsOneWidget);
    expect(repository.fetchReservationsCalls, greaterThanOrEqualTo(2));
    expect(repository.statusCalls, 1);
  });

  testWidgets('booking cancellation refreshes notifications', (tester) async {
    final bookingRepository = CancelableBookingRepository();
    final notificationRepository = TrackingNotificationRepository();
    await _pumpMainShell(
      tester,
      bookingRepository: bookingRepository,
      notificationRepository: notificationRepository,
    );

    await tester.tap(find.byKey(const Key('bottom_nav_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel reservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_booking_cancellation')));
    await tester.pumpAndSettle();

    expect(notificationRepository.fetchCalls, greaterThanOrEqualTo(2));
    expect(bookingRepository.cancelCalls, 1);
  });

  testWidgets('profile tab logs out through repository', (tester) async {
    var loggedOut = false;
    final repository = FakeAuthRepository();

    await _pumpMainShell(
      tester,
      authRepository: repository,
      onLogoutCompleted: () => loggedOut = true,
    );

    await tester.tap(find.byKey(const Key('bottom_nav_3')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_title')), findsOneWidget);
    expect(find.text('Jane Cook'), findsWidgets);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('+84901234567'), findsOneWidget);
    expect(find.text('John Doe'), findsNothing);
    expect(find.text('Travel Enthusiast'), findsNothing);

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
  NotificationRepository? notificationRepository,
  SavedPropertyRepository? savedPropertyRepository,
  VoidCallback? onLogoutCompleted,
  PayOSCheckoutBuilder? payOSCheckoutBuilder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MainShell(
        authRepository: authRepository ?? FakeAuthRepository(),
        productRepository: productRepository ?? const FakeProductRepository(),
        bookingRepository: bookingRepository ?? const FakeBookingRepository(),
        chatRepository: const FakeChatRepository(),
        notificationRepository:
            notificationRepository ?? const FakeNotificationRepository(),
        savedPropertyRepository:
            savedPropertyRepository ?? FakeSavedPropertyRepository(),
        onLogoutCompleted: onLogoutCompleted ?? () {},
        payOSCheckoutBuilder:
            payOSCheckoutBuilder ??
            (url, _) => Text(
              'Embedded PayOS: $url',
              key: const Key('payos_checkout_webview'),
            ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _oceanPearlId = '13430237-d5ed-4c9f-be3a-feddf4cb4fa8';

class FakeSavedPropertyRepository implements SavedPropertyRepository {
  final Set<String> savedIds = {};

  @override
  Future<List<Product>> fetchSavedProperties() async {
    final products = await const FakeProductRepository().fetchProducts();
    return products
        .where((product) => savedIds.contains(product.id))
        .toList(growable: false);
  }

  @override
  Future<void> removeProperty(String propertyId) async {
    savedIds.remove(propertyId);
  }

  @override
  Future<void> saveProperty(String propertyId) async {
    savedIds.add(propertyId);
  }
}

class FakeNotificationRepository implements NotificationRepository {
  const FakeNotificationRepository();

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    return [
      NotificationItem(
        id: 'notification-1',
        title: 'Booking Confirmed',
        message: 'Your stay at Ocean Pearl Hotel is confirmed.',
        isRead: false,
        createdAt: DateTime(2026, 7, 13, 9, 20),
      ),
    ];
  }

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markRead(String notificationId) async {}
}

class TrackingNotificationRepository extends FakeNotificationRepository {
  int fetchCalls = 0;

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    fetchCalls++;
    return super.fetchNotifications();
  }
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

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) {
    throw UnimplementedError();
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) {
    throw UnimplementedError();
  }
}

class PaidBookingRepository extends FakeBookingRepository {
  int fetchReservationsCalls = 0;
  int statusCalls = 0;

  @override
  Future<List<BookingReservation>> fetchReservations() async {
    fetchReservationsCalls++;
    return const [];
  }

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) async {
    statusCalls++;
    return const BookingPaymentStatus(
      bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
      bookingStatus: 'Paid',
      paymentMethod: 'PayOS',
      paymentStatus: 'Success',
      amount: 255,
      transactionCode: '88001234',
      paidAt: null,
      updatedAt: null,
    );
  }
}

class CancelableBookingRepository extends FakeBookingRepository {
  bool _canceled = false;
  int cancelCalls = 0;

  @override
  Future<List<BookingReservation>> fetchReservations() async {
    final checkIn = DateTime.now().add(const Duration(days: 3));
    return [
      BookingReservation(
        bookingId: 'cancelable-booking',
        propertyId: 'property-1',
        propertyName: 'Cancelable Ocean Hotel',
        propertyImageUrl: null,
        roomId: 'room-1',
        roomName: 'Deluxe Room',
        roomImageUrl: null,
        checkIn: checkIn,
        checkOut: checkIn.add(const Duration(days: 2)),
        adults: 2,
        children: 0,
        roomQuantity: 1,
        totalPrice: 5000,
        bookingStatus: _canceled ? 'Cancelled' : 'Paid',
        paymentStatus: 'Success',
        paymentMethod: 'PayOS',
      ),
    ];
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) async {
    cancelCalls++;
    _canceled = true;
    return const BookingCancellation(
      bookingId: 'cancelable-booking',
      bookingStatus: 'Cancelled',
      paymentStatus: 'Success',
      message: 'Booking cancelled.',
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
        latitude: 16.0544,
        longitude: 108.2022,
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
        latitude: 15.8801,
        longitude: 108.3380,
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
