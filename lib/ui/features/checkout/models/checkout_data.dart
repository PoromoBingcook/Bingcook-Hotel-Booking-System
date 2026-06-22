enum PaymentMethodType { payOS, payAtProperty }

class CheckoutData {
  const CheckoutData({
    required this.propertyName,
    required this.propertyImageAsset,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bookingId,
    required this.paymentMethods,
    required this.priceRows,
    required this.total,
  });

  final String propertyName;
  final String propertyImageAsset;
  final String roomName;
  final String checkIn;
  final String checkOut;
  final int nights;
  final String fullName;
  final String email;
  final String phone;
  final String bookingId;
  final List<PaymentMethodData> paymentMethods;
  final List<PriceBreakdownRow> priceRows;
  final double total;
}

class PaymentMethodData {
  const PaymentMethodData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final String iconAsset;
}

class PriceBreakdownRow {
  const PriceBreakdownRow({required this.label, required this.amount});

  final String label;
  final double amount;
}
