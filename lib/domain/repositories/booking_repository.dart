import 'package:bingcook/domain/models/booking.dart';

abstract interface class BookingRepository {
  Future<List<BookingReservation>> fetchReservations();

  Future<BookingDraft> createDraft(CreateBookingDraftCommand command);

  Future<BookingCheckout> checkout(CheckoutBookingCommand command);

  Future<BookingPaymentStatus> fetchStatus(String bookingId);

  Future<BookingCancellation> cancel(String bookingId);
}

class BookingRepositoryException implements Exception {
  const BookingRepositoryException(this.message, {this.code, this.bookingId});

  final String message;
  final String? code;
  final String? bookingId;

  @override
  String toString() => message;
}
