import 'package:bingcook/data/models/booking_api_models.dart';
import 'package:bingcook/data/repositories/api_booking_repository.dart';
import 'package:bingcook/data/services/booking_api_service.dart';
import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiBookingRepository', () {
    test('creates booking draft with current session token', () async {
      final service = FakeBookingApiService();
      final repository = ApiBookingRepository(
        bookingApiService: service,
        authRepository: FakeAuthRepository(),
      );

      final draft = await repository.createDraft(
        CreateBookingDraftCommand(
          propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
          roomId: '2cc3aa36-f925-4a1e-97bb-2695af5966b7',
          checkIn: DateTime(2026, 7, 10),
          checkOut: DateTime(2026, 7, 13),
          adults: 2,
          children: 1,
          roomQuantity: 1,
          addOns: ['breakfast'],
          note: 'Late arrival',
        ),
      );

      expect(service.lastToken, 'jwt-token');
      expect(
        service.lastDraftPropertyId,
        '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
      );
      expect(draft.bookingId, 'f4fb8b9d-b26c-4685-9454-0fbb9d927337');
      expect(draft.totalPrice, 4080000);
    });

    test('checks out booking with current session token', () async {
      final service = FakeBookingApiService();
      final repository = ApiBookingRepository(
        bookingApiService: service,
        authRepository: FakeAuthRepository(),
      );

      final result = await repository.checkout(
        const CheckoutBookingCommand(
          bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
          paymentMethod: 'PayOS',
          customerName: 'Jane Cook',
          customerEmail: 'jane@example.com',
          customerPhone: '+84901234567',
          identityNumber: '012345678',
        ),
      );

      expect(service.lastToken, 'jwt-token');
      expect(service.lastPaymentMethod, 'PayOS');
      expect(result.checkoutUrl, 'https://pay.payos.vn/web/88001234');
    });

    test('throws repository exception when user is not authenticated', () {
      final repository = ApiBookingRepository(
        bookingApiService: FakeBookingApiService(),
        authRepository: FakeAuthRepository.unauthenticated(),
      );

      expect(
        () => repository.createDraft(
          CreateBookingDraftCommand(
            propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
            roomId: '2cc3aa36-f925-4a1e-97bb-2695af5966b7',
            checkIn: DateTime(2026, 7, 10),
            checkOut: DateTime(2026, 7, 13),
            adults: 2,
            children: 0,
            roomQuantity: 1,
            addOns: [],
            note: null,
          ),
        ),
        throwsA(
          isA<BookingRepositoryException>().having(
            (error) => error.message,
            'message',
            'Please login before booking.',
          ),
        ),
      );
    });
  });
}

class FakeBookingApiService implements BookingApiService {
  String? lastToken;
  String? lastDraftPropertyId;
  String? lastPaymentMethod;

  @override
  Future<BookingDraftResponse> createDraft({
    required String token,
    required String propertyId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int roomQuantity,
    required List<String> addOns,
    required String? note,
  }) async {
    lastToken = token;
    lastDraftPropertyId = propertyId;
    return BookingDraftResponse(
      bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
      propertyId: '13430237-d5ed-4c9f-be3a-feddf4cb4fa8',
      propertyName: 'Ocean Pearl Hotel',
      roomId: '2cc3aa36-f925-4a1e-97bb-2695af5966b7',
      roomName: 'Deluxe Ocean View',
      roomType: 'Deluxe',
      checkIn: DateTime(2026, 7, 10),
      checkOut: DateTime(2026, 7, 13),
      nights: 3,
      adults: 2,
      children: 1,
      totalGuests: 3,
      roomQuantity: 1,
      maxGuests: 3,
      availableRooms: 4,
      roomSubtotal: 3000000,
      addOnSubtotal: 1080000,
      totalPrice: 4080000,
      addOns: [
        BookingAddOnResponse(
          code: 'breakfast',
          name: 'Breakfast',
          pricingType: 'PerGuestPerNight',
          unitPrice: 120000,
          totalPrice: 1080000,
        ),
      ],
      note: 'Late arrival',
      nextAction: 'ProceedToConfirmationPayment',
    );
  }

  @override
  Future<BookingCheckoutResponse> checkout({
    required String token,
    required String bookingId,
    required String paymentMethod,
    required String? customerName,
    required String? customerEmail,
    required String? customerPhone,
    required String? identityNumber,
  }) async {
    lastToken = token;
    lastPaymentMethod = paymentMethod;
    return const BookingCheckoutResponse(
      bookingId: 'f4fb8b9d-b26c-4685-9454-0fbb9d927337',
      bookingStatus: 'PendingPayment',
      paymentMethod: 'PayOS',
      paymentStatus: 'Pending',
      amount: 4080000,
      transactionCode: '88001234',
      paymentLinkId: 'payos-link-id',
      checkoutUrl: 'https://pay.payos.vn/web/88001234',
      qrCode: 'qr-code-payload',
      message: 'Open checkoutUrl to pay with PayOS.',
    );
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _session = _defaultSession;

  const FakeAuthRepository.unauthenticated() : _session = null;

  final AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) async {
    return _defaultSession;
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
    return _defaultSession;
  }

  static final _defaultSession = AuthSession(
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
