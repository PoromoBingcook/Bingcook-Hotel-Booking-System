class ChatConversation {
  const ChatConversation({
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
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderUserId;
  final String senderName;
  final String body;
  final DateTime createdAt;
}
