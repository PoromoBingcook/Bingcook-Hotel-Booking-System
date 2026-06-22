class CreateBookingDraftCommand {
  const CreateBookingDraftCommand({
    required this.propertyId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.roomQuantity,
    required this.addOns,
    required this.note,
  });

  final String propertyId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final int roomQuantity;
  final List<String> addOns;
  final String? note;
}

class CheckoutBookingCommand {
  const CheckoutBookingCommand({
    required this.bookingId,
    required this.paymentMethod,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.identityNumber,
  });

  final String bookingId;
  final String paymentMethod;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? identityNumber;
}

class BookingDraft {
  const BookingDraft({
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.adults,
    required this.children,
    required this.totalGuests,
    required this.roomQuantity,
    required this.maxGuests,
    required this.availableRooms,
    required this.roomSubtotal,
    required this.addOnSubtotal,
    required this.totalPrice,
    required this.addOns,
    required this.note,
    required this.nextAction,
  });

  final String bookingId;
  final String propertyId;
  final String propertyName;
  final String roomId;
  final String roomName;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final int adults;
  final int children;
  final int totalGuests;
  final int roomQuantity;
  final int maxGuests;
  final int availableRooms;
  final double roomSubtotal;
  final double addOnSubtotal;
  final double totalPrice;
  final List<BookingAddOn> addOns;
  final String? note;
  final String nextAction;
}

class BookingAddOn {
  const BookingAddOn({
    required this.code,
    required this.name,
    required this.pricingType,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String code;
  final String name;
  final String pricingType;
  final double unitPrice;
  final double totalPrice;
}

class BookingCheckout {
  const BookingCheckout({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.transactionCode,
    required this.paymentLinkId,
    required this.checkoutUrl,
    required this.qrCode,
    required this.message,
  });

  final String bookingId;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double amount;
  final String? transactionCode;
  final String? paymentLinkId;
  final String? checkoutUrl;
  final String? qrCode;
  final String message;
}
