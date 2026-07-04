import 'package:bingcook/domain/models/chat.dart';

abstract interface class ChatRepository {
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  });

  Future<List<ChatConversation>> fetchConversations();

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  });

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  });

  Future<void> markRead({required String conversationId});
}

class ChatRepositoryException implements Exception {
  const ChatRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
