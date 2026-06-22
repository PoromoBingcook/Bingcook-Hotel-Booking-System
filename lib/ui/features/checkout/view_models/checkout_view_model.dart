import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:flutter/foundation.dart';

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({required BookingRepository bookingRepository})
    : _bookingRepository = bookingRepository;

  final BookingRepository _bookingRepository;
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.payOS;
  bool _isSubmitting = false;
  String? _errorMessage;
  BookingCheckout? _checkout;

  PaymentMethodType get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  BookingCheckout? get checkout => _checkout;

  void selectPaymentMethod(PaymentMethodType method) {
    if (_selectedPaymentMethod == method) {
      return;
    }
    _selectedPaymentMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit({
    required CheckoutData data,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _checkout = await _bookingRepository.checkout(
        CheckoutBookingCommand(
          bookingId: data.bookingId,
          paymentMethod: _paymentMethodValue(_selectedPaymentMethod),
          customerName: _emptyToNull(customerName),
          customerEmail: _emptyToNull(customerEmail),
          customerPhone: _emptyToNull(customerPhone),
          identityNumber: null,
        ),
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on BookingRepositoryException catch (error) {
      _errorMessage = error.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Unable to confirm booking.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  String _paymentMethodValue(PaymentMethodType method) {
    return switch (method) {
      PaymentMethodType.payOS => 'PayOS',
      PaymentMethodType.payAtProperty => 'PayAtProperty',
    };
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
