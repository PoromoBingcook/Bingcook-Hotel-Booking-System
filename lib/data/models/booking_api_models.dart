import 'package:bingcook/domain/models/booking.dart';

class BookingDraftResponse {
  const BookingDraftResponse({
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

  factory BookingDraftResponse.fromJson(Map<String, Object?> json) {
    return BookingDraftResponse(
      bookingId: _readString(json['bookingId'], fallback: ''),
      propertyId: _readString(json['propertyId'], fallback: ''),
      propertyName: _readString(json['propertyName'], fallback: ''),
      roomId: _readString(json['roomId'], fallback: ''),
      roomName: _readString(json['roomName'], fallback: ''),
      roomType: _readString(json['roomType'], fallback: ''),
      checkIn: _readDate(json['checkIn']),
      checkOut: _readDate(json['checkOut']),
      nights: _readInt(json['nights']),
      adults: _readInt(json['adults']),
      children: _readInt(json['children']),
      totalGuests: _readInt(json['totalGuests']),
      roomQuantity: _readInt(json['roomQuantity']),
      maxGuests: _readInt(json['maxGuests']),
      availableRooms: _readInt(json['availableRooms']),
      roomSubtotal: _readDouble(json['roomSubtotal']),
      addOnSubtotal: _readDouble(json['addOnSubtotal']),
      totalPrice: _readDouble(json['totalPrice']),
      addOns: _readMapList(
        json['addOns'],
      ).map(BookingAddOnResponse.fromJson).toList(growable: false),
      note: _readOptionalString(json['note']),
      nextAction: _readString(json['nextAction'], fallback: ''),
    );
  }

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
  final List<BookingAddOnResponse> addOns;
  final String? note;
  final String nextAction;

  BookingDraft toDomain() {
    return BookingDraft(
      bookingId: bookingId,
      propertyId: propertyId,
      propertyName: propertyName,
      roomId: roomId,
      roomName: roomName,
      roomType: roomType,
      checkIn: checkIn,
      checkOut: checkOut,
      nights: nights,
      adults: adults,
      children: children,
      totalGuests: totalGuests,
      roomQuantity: roomQuantity,
      maxGuests: maxGuests,
      availableRooms: availableRooms,
      roomSubtotal: roomSubtotal,
      addOnSubtotal: addOnSubtotal,
      totalPrice: totalPrice,
      addOns: List.unmodifiable(addOns.map((addOn) => addOn.toDomain())),
      note: note,
      nextAction: nextAction,
    );
  }

  static String _readString(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  static String? _readOptionalString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  static DateTime _readDate(Object? value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    throw const FormatException('Unable to read booking date.');
  }

  static double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static List<Map<String, Object?>> _readMapList(Object? value) {
    if (value is! List<Object?>) {
      return const [];
    }
    return value.whereType<Map<String, Object?>>().toList(growable: false);
  }
}

class BookingAddOnResponse {
  const BookingAddOnResponse({
    required this.code,
    required this.name,
    required this.pricingType,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory BookingAddOnResponse.fromJson(Map<String, Object?> json) {
    return BookingAddOnResponse(
      code: BookingDraftResponse._readString(json['code'], fallback: ''),
      name: BookingDraftResponse._readString(json['name'], fallback: ''),
      pricingType: BookingDraftResponse._readString(
        json['pricingType'],
        fallback: '',
      ),
      unitPrice: BookingDraftResponse._readDouble(json['unitPrice']),
      totalPrice: BookingDraftResponse._readDouble(json['totalPrice']),
    );
  }

  final String code;
  final String name;
  final String pricingType;
  final double unitPrice;
  final double totalPrice;

  BookingAddOn toDomain() {
    return BookingAddOn(
      code: code,
      name: name,
      pricingType: pricingType,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}

class BookingCheckoutResponse {
  const BookingCheckoutResponse({
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

  factory BookingCheckoutResponse.fromJson(Map<String, Object?> json) {
    return BookingCheckoutResponse(
      bookingId: BookingDraftResponse._readString(
        json['bookingId'],
        fallback: '',
      ),
      bookingStatus: BookingDraftResponse._readString(
        json['bookingStatus'],
        fallback: '',
      ),
      paymentMethod: BookingDraftResponse._readString(
        json['paymentMethod'],
        fallback: '',
      ),
      paymentStatus: BookingDraftResponse._readString(
        json['paymentStatus'],
        fallback: '',
      ),
      amount: BookingDraftResponse._readDouble(json['amount']),
      transactionCode: BookingDraftResponse._readOptionalString(
        json['transactionCode'],
      ),
      paymentLinkId: BookingDraftResponse._readOptionalString(
        json['paymentLinkId'],
      ),
      checkoutUrl: BookingDraftResponse._readOptionalString(
        json['checkoutUrl'],
      ),
      qrCode: BookingDraftResponse._readOptionalString(json['qrCode']),
      message: BookingDraftResponse._readString(json['message'], fallback: ''),
    );
  }

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

  BookingCheckout toDomain() {
    return BookingCheckout(
      bookingId: bookingId,
      bookingStatus: bookingStatus,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      amount: amount,
      transactionCode: transactionCode,
      paymentLinkId: paymentLinkId,
      checkoutUrl: checkoutUrl,
      qrCode: qrCode,
      message: message,
    );
  }
}
