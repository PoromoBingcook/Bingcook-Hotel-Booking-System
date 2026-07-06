import 'package:bingcook/domain/models/chat.dart';

class StaffChatPreview {
  const StaffChatPreview({
    required this.conversation,
    required this.latestMessage,
    required this.needsReply,
  });

  final ChatConversation conversation;
  final ChatMessage? latestMessage;
  final bool needsReply;
}
