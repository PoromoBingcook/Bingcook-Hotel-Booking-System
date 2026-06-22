import 'dart:convert';

import 'package:bingcook/data/models/booking_api_models.dart';
import 'package:http/http.dart' as http;

class BookingApiService {
  const BookingApiService({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Future<BookingDraftResponse> createDraft({
    required String token,
    required String propertyId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int roomQuantity,
    required List<String> addOns,
    required String? note,
  }) async {
    final decoded = await _postObject(
      token: token,
      path: '/api/bookings/draft',
      body: {
        'propertyId': propertyId,
        'roomId': roomId,
        'checkIn': _formatIsoDate(checkIn),
        'checkOut': _formatIsoDate(checkOut),
        'adults': adults,
        'children': children,
        'roomQuantity': roomQuantity,
        'addOns': addOns,
        'note': note,
      },
    );

    return BookingDraftResponse.fromJson(decoded);
  }

  Future<BookingCheckoutResponse> checkout({
    required String token,
    required String bookingId,
    required String paymentMethod,
    required String? customerName,
    required String? customerEmail,
    required String? customerPhone,
    required String? identityNumber,
  }) async {
    final decoded = await _postObject(
      token: token,
      path: '/api/bookings/checkout',
      body: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'identityNumber': identityNumber,
      },
    );

    return BookingCheckoutResponse.fromJson(decoded);
  }

  Future<Map<String, Object?>> _postObject({
    required String token,
    required String path,
    required Map<String, Object?> body,
  }) async {
    final response = await _client.post(
      _baseUrl.replace(path: path),
      headers: {
        'accept': 'application/json',
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final decoded = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookingApiException(
        _readMessage(decoded) ?? 'Booking request failed.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Map<String, Object?> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const BookingApiException('Unable to read booking response.');
    }
    return decoded;
  }

  String? _readMessage(Map<String, Object?> json) {
    final message = json['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }

  String _formatIsoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class BookingApiException implements Exception {
  const BookingApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
