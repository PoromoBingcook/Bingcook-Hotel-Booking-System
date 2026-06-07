import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:flutter/foundation.dart';

class CheckoutViewModel extends ChangeNotifier {
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.creditCard;

  PaymentMethodType get selectedPaymentMethod => _selectedPaymentMethod;

  void selectPaymentMethod(PaymentMethodType method) {
    if (_selectedPaymentMethod == method) {
      return;
    }
    _selectedPaymentMethod = method;
    notifyListeners();
  }
}
