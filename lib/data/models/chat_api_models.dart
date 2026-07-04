import 'package:bingcook/domain/models/chat.dart';

class ChatConversationResponse {
  const ChatConversationResponse({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.customerUserId,
    required this.customerName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.bookingId,
    this.hostUserId,
    this.lastMessageAt,
    this.customerLastReadAt,
    this.hostLastReadAt,
  });

  factory ChatConversationResponse.fromJson(Map<String, Object?> json) {
    return ChatConversationResponse(
      id: _readString(json['id']),
      propertyId: _readString(json['propertyId']),
      propertyName: _readString(json['propertyName']),
      bookingId: _readNullableString(json['bookingId']),
      customerUserId: _readString(json['customerUserId']),
      customerName: _readString(json['customerName']),
      hostUserId: _readNullableString(json['hostUserId']),
      status: _readString(json['status']),
      lastMessageAt: _readNullableDateTime(json['lastMessageAt']),
      customerLastReadAt: _readNullableDateTime(json['customerLastReadAt']),
      hostLastReadAt: _readNullableDateTime(json['hostLastReadAt']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  final String id;
  final String propertyId;
  final String propertyName;
  final String? bookingId;
  final String customerUserId;
  final String customerName;
  final String? hostUserId;
  final String status;
  final DateTime? lastMessageAt;
  final DateTime? customerLastReadAt;
  final DateTime? hostLastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation toDomain() {
    return ChatConversation(
      id: id,
      propertyId: propertyId,
      propertyName: propertyName,
      bookingId: bookingId,
      customerUserId: customerUserId,
      customerName: customerName,
      hostUserId: hostUserId,
      status: status,
      lastMessageAt: lastMessageAt,
      customerLastReadAt: customerLastReadAt,
      hostLastReadAt: hostLastReadAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ChatMessageResponse {
  const ChatMessageResponse({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, Object?> json) {
    return ChatMessageResponse(
      id: _readString(json['id']),
      conversationId: _readString(json['conversationId']),
      senderUserId: _readString(json['senderUserId']),
      senderName: _readString(json['senderName']),
      body: _readString(json['body']),
      createdAt: _readDateTime(json['createdAt']),
    );
  }

  final String id;
  final String conversationId;
  final String senderUserId;
  final String senderName;
  final String body;
  final DateTime createdAt;

  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderUserId: senderUserId,
      senderName: senderName,
      body: body,
      createdAt: createdAt,
    );
  }
}

String _readString(Object? value) {
  if (value is String) {
    return value;
  }
  throw const FormatException('Unable to read chat response.');
}

String? _readNullableString(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

DateTime _readDateTime(Object? value) {
  if (value is String) {
    return DateTime.parse(value);
  }
  throw const FormatException('Unable to read chat response.');
}

DateTime? _readNullableDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }
  return null;
}
