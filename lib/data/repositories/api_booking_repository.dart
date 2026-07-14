import 'package:bingcook/data/services/booking_api_service.dart';
import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  const ApiBookingRepository({
    required BookingApiService bookingApiService,
    required AuthRepository authRepository,
  }) : _bookingApiService = bookingApiService,
       _authRepository = authRepository;

  final BookingApiService _bookingApiService;
  final AuthRepository _authRepository;

  @override
  Future<List<BookingReservation>> fetchReservations() async {
    try {
      final response = await _bookingApiService.fetchReservations(
        token: _token(),
      );
      return response.map((item) => item.toDomain()).toList(growable: false);
    } on BookingRepositoryException {
      rethrow;
    } on BookingApiException catch (error) {
      throw BookingRepositoryException(
        error.message,
        code: error.code,
        bookingId: error.bookingId,
      );
    } on FormatException {
      throw const BookingRepositoryException('Unable to read reservations.');
    } catch (_) {
      throw const BookingRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command) async {
    try {
      final response = await _bookingApiService.createDraft(
        token: _token(),
        propertyId: command.propertyId,
        roomId: command.roomId,
        checkIn: command.checkIn,
        checkOut: command.checkOut,
        adults: command.adults,
        children: command.children,
        roomQuantity: command.roomQuantity,
        addOns: command.addOns,
        note: command.note,
      );
      return response.toDomain();
    } on BookingRepositoryException {
      rethrow;
    } on BookingApiException catch (error) {
      throw BookingRepositoryException(
        error.message,
        code: error.code,
        bookingId: error.bookingId,
      );
    } on FormatException {
      throw const BookingRepositoryException(
        'Unable to read booking response.',
      );
    } catch (_) {
      throw const BookingRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<BookingCheckout> checkout(CheckoutBookingCommand command) async {
    try {
      final response = await _bookingApiService.checkout(
        token: _token(),
        bookingId: command.bookingId,
        paymentMethod: command.paymentMethod,
        customerName: command.customerName,
        customerEmail: command.customerEmail,
        customerPhone: command.customerPhone,
        identityNumber: command.identityNumber,
      );
      return response.toDomain();
    } on BookingRepositoryException {
      rethrow;
    } on BookingApiException catch (error) {
      throw BookingRepositoryException(
        error.message,
        code: error.code,
        bookingId: error.bookingId,
      );
    } on FormatException {
      throw const BookingRepositoryException(
        'Unable to read booking response.',
      );
    } catch (_) {
      throw const BookingRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<BookingPaymentStatus> fetchStatus(String bookingId) async {
    try {
      final response = await _bookingApiService.fetchStatus(
        token: _token(),
        bookingId: bookingId,
      );
      return response.toDomain();
    } on BookingRepositoryException {
      rethrow;
    } on BookingApiException catch (error) {
      throw BookingRepositoryException(
        error.message,
        code: error.code,
        bookingId: error.bookingId,
      );
    } on FormatException {
      throw const BookingRepositoryException(
        'Unable to read booking status response.',
      );
    } catch (_) {
      throw const BookingRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  @override
  Future<BookingCancellation> cancel(String bookingId) async {
    try {
      final response = await _bookingApiService.cancel(
        token: _token(),
        bookingId: bookingId,
      );
      return response.toDomain();
    } on BookingRepositoryException {
      rethrow;
    } on BookingApiException catch (error) {
      throw BookingRepositoryException(
        error.message,
        code: error.code,
        bookingId: error.bookingId,
      );
    } on FormatException {
      throw const BookingRepositoryException(
        'Unable to read cancellation response.',
      );
    } catch (_) {
      throw const BookingRepositoryException(
        'Unable to reach BingCook server.',
      );
    }
  }

  String _token() {
    final token = _authRepository.currentSession?.token;
    if (token == null || token.isEmpty) {
      throw const BookingRepositoryException('Please login before booking.');
    }
    return token;
  }
}
