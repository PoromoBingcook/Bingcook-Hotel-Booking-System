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
    this.expiresAt,
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
      expiresAt: BookingStatusResponse._readOptionalDateTime(json['expiresAt']),
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
  final DateTime? expiresAt;

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
      expiresAt: expiresAt,
    );
  }
}

class BookingStatusResponse {
  const BookingStatusResponse({
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

  factory BookingStatusResponse.fromJson(Map<String, Object?> json) {
    return BookingStatusResponse(
      bookingId: BookingDraftResponse._readString(
        json['bookingId'],
        fallback: '',
      ),
      bookingStatus: BookingDraftResponse._readString(
        json['bookingStatus'],
        fallback: '',
      ),
      paymentMethod: BookingDraftResponse._readOptionalString(
        json['paymentMethod'],
      ),
      paymentStatus: BookingDraftResponse._readOptionalString(
        json['paymentStatus'],
      ),
      amount: _readOptionalDouble(json['amount']),
      transactionCode: BookingDraftResponse._readOptionalString(
        json['transactionCode'],
      ),
      checkoutUrl: BookingDraftResponse._readOptionalString(
        json['checkoutUrl'],
      ),
      expiresAt: _readOptionalDateTime(json['expiresAt']),
      paidAt: _readOptionalDateTime(json['paidAt']),
      updatedAt: _readOptionalDateTime(json['updatedAt']),
    );
  }

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

  BookingPaymentStatus toDomain() {
    return BookingPaymentStatus(
      bookingId: bookingId,
      bookingStatus: bookingStatus,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      amount: amount,
      transactionCode: transactionCode,
      paidAt: paidAt,
      updatedAt: updatedAt,
      checkoutUrl: checkoutUrl,
      expiresAt: expiresAt,
    );
  }

  static double? _readOptionalDouble(Object? value) {
    return switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text),
      _ => null,
    };
  }

  static DateTime? _readOptionalDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null || parsed.isUtc) {
      return parsed;
    }
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }
}

class BookingCancellationResponse {
  const BookingCancellationResponse({
    required this.bookingId,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.message,
  });

  factory BookingCancellationResponse.fromJson(Map<String, Object?> json) {
    return BookingCancellationResponse(
      bookingId: BookingDraftResponse._readString(
        json['bookingId'],
        fallback: '',
      ),
      bookingStatus: BookingDraftResponse._readString(
        json['bookingStatus'],
        fallback: '',
      ),
      paymentStatus: BookingDraftResponse._readOptionalString(
        json['paymentStatus'],
      ),
      message: BookingDraftResponse._readString(json['message'], fallback: ''),
    );
  }

  final String bookingId;
  final String bookingStatus;
  final String? paymentStatus;
  final String message;

  BookingCancellation toDomain() {
    return BookingCancellation(
      bookingId: bookingId,
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
      message: message,
    );
  }
}

class BookingReservationResponse {
  const BookingReservationResponse({
    required this.bookingId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyImageUrl,
    required this.latitude,
    required this.longitude,
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

  factory BookingReservationResponse.fromJson(Map<String, Object?> json) {
    String text(String key) => json[key] is String ? json[key]! as String : '';
    String? optionalText(String key) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty ? value : null;
    }

    int integer(String key) => switch (json[key]) {
      int value => value,
      num value => value.toInt(),
      _ => 0,
    };
    double decimal(String key) => switch (json[key]) {
      num value => value.toDouble(),
      String value => double.tryParse(value) ?? 0,
      _ => 0,
    };
    double? optionalDecimal(String key) => switch (json[key]) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };

    return BookingReservationResponse(
      bookingId: text('bookingId'),
      propertyId: text('propertyId'),
      propertyName: text('propertyName'),
      propertyImageUrl: optionalText('propertyImageUrl'),
      latitude: optionalDecimal('latitude'),
      longitude: optionalDecimal('longitude'),
      roomId: text('roomId'),
      roomName: text('roomName'),
      roomImageUrl: optionalText('roomImageUrl'),
      checkIn: DateTime.parse(text('checkIn')),
      checkOut: DateTime.parse(text('checkOut')),
      adults: integer('adults'),
      children: integer('children'),
      roomQuantity: integer('roomQuantity'),
      totalPrice: decimal('totalPrice'),
      bookingStatus: text('bookingStatus'),
      paymentStatus: optionalText('paymentStatus'),
      paymentMethod: optionalText('paymentMethod'),
      transactionCode: optionalText('transactionCode'),
      checkoutUrl: optionalText('checkoutUrl'),
      expiresAt: BookingStatusResponse._readOptionalDateTime(json['expiresAt']),
    );
  }

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

  BookingReservation toDomain() => BookingReservation(
    bookingId: bookingId,
    propertyId: propertyId,
    propertyName: propertyName,
    propertyImageUrl: propertyImageUrl,
    latitude: latitude,
    longitude: longitude,
    roomId: roomId,
    roomName: roomName,
    roomImageUrl: roomImageUrl,
    checkIn: checkIn,
    checkOut: checkOut,
    adults: adults,
    children: children,
    roomQuantity: roomQuantity,
    totalPrice: totalPrice,
    bookingStatus: bookingStatus,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
    transactionCode: transactionCode,
    checkoutUrl: checkoutUrl,
    expiresAt: expiresAt,
  );
}
