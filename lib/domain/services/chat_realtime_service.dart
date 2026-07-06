import 'package:bingcook/domain/models/chat.dart';

abstract interface class ChatRealtimeService {
  Stream<ChatMessage> watchConversation(String conversationId);

  Future<void> disconnect();
}
