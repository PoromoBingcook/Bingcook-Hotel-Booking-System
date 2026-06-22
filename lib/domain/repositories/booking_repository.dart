import 'package:bingcook/domain/models/booking.dart';

abstract interface class BookingRepository {
  Future<BookingDraft> createDraft(CreateBookingDraftCommand command);

  Future<BookingCheckout> checkout(CheckoutBookingCommand command);
}

class BookingRepositoryException implements Exception {
  const BookingRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
