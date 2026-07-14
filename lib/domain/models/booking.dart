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

enum BookingCategory { active, past, canceled }

class BookingReservation {
  const BookingReservation({
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyImageUrl,
    this.latitude,
    this.longitude,
    required this.roomId,
    required this.roomName,
    required this.roomImageUrl,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.roomQuantity,
    required this.totalPrice,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionCode,
    this.checkoutUrl,
    this.expiresAt,
  });

  final String bookingId;
  final String propertyId;
  final String propertyName;
  final String? propertyImageUrl;
  final double? latitude;
  final double? longitude;
  final String roomId;
  final String roomName;
  final String? roomImageUrl;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final int roomQuantity;
  final double totalPrice;
  final String bookingStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? transactionCode;
  final String? checkoutUrl;
  final DateTime? expiresAt;

  BookingCategory categoryAt(DateTime now) {
    final normalizedStatus = bookingStatus.trim().toLowerCase();
    if (normalizedStatus == 'cancelled' ||
        normalizedStatus == 'canceled' ||
        normalizedStatus == 'expired') {
      return BookingCategory.canceled;
    }
    final vietnamNow = now.toUtc().add(const Duration(hours: 7));
    final todayInVietnam = DateTime.utc(
      vietnamNow.year,
      vietnamNow.month,
      vietnamNow.day,
    );
    final checkOutDate = DateTime.utc(
      checkOut.year,
      checkOut.month,
      checkOut.day,
    );
    if (checkOutDate.isBefore(todayInVietnam)) {
      return BookingCategory.past;
    }
    return BookingCategory.active;
  }

  bool canCancelAt(DateTime now) {
    final normalizedStatus = bookingStatus.trim().toLowerCase();
    if (normalizedStatus == 'pendingpayment') {
      final normalizedPaymentStatus = paymentStatus?.trim().toLowerCase();
      return normalizedPaymentStatus == 'pending' &&
          (expiresAt == null || now.toUtc().isBefore(expiresAt!.toUtc()));
    }
    if (normalizedStatus == 'pending') {
      return expiresAt == null || now.toUtc().isBefore(expiresAt!.toUtc());
    }
    if (normalizedStatus != 'confirmed' && normalizedStatus != 'paid') {
      return false;
    }

    final checkInInstant = DateTime.utc(
      checkIn.year,
      checkIn.month,
      checkIn.day,
      7,
    );
    return now.toUtc().isBefore(
      checkInInstant.subtract(const Duration(days: 1)),
    );
  }

  bool canResumePaymentAt(DateTime now) {
    return bookingStatus.trim().toLowerCase() == 'pendingpayment' &&
        paymentStatus?.trim().toLowerCase() == 'pending' &&
        checkoutUrl?.trim().isNotEmpty == true &&
        expiresAt != null &&
        now.toUtc().isBefore(expiresAt!.toUtc());
  }
}

class BookingPaymentStatus {
  const BookingPaymentStatus({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.transactionCode,
    required this.paidAt,
    required this.updatedAt,
    this.checkoutUrl,
    this.expiresAt,
  });

  final String bookingId;
  final String bookingStatus;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? amount;
  final String? transactionCode;
  final DateTime? paidAt;
  final DateTime? updatedAt;
  final String? checkoutUrl;
  final DateTime? expiresAt;

  bool get isPaid =>
      bookingStatus.toLowerCase() == 'paid' &&
      paymentStatus?.toLowerCase() == 'success';
}

class BookingCancellation {
  const BookingCancellation({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.message,
  });

  final String bookingId;
  final String bookingStatus;
  final String? paymentStatus;
  final String message;
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
    this.expiresAt,
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
  final DateTime? expiresAt;
}
