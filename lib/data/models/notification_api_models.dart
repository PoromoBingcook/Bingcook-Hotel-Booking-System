import 'package:bingcook/domain/models/notification_item.dart';

class NotificationResponse {
  const NotificationResponse({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, Object?> json) {
    return NotificationResponse(
      id: _readString(json['id']),
      title: _readString(json['title']),
      message: _readString(json['message']),
      isRead: json['isRead'] == true,
      createdAt: _readUtcDateTime(json['createdAt']),
    );
  }

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem toDomain() {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  static String _readString(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw const FormatException('Unable to read notification response.');
  }

  static DateTime _readUtcDateTime(Object? value) {
    final parsed = DateTime.parse(_readString(value));
    if (parsed.isUtc) {
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
