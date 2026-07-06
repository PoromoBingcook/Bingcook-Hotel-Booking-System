import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart';

class ConversationPreview {
  const ConversationPreview({required this.conversation, this.latestMessage});

  final ChatConversation conversation;
  final ChatMessage? latestMessage;
}

class ConversationsViewModel extends ChangeNotifier {
  ConversationsViewModel({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;
  List<ConversationPreview> _conversations = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationPreview> get conversations =>
      List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final conversations = await _chatRepository.fetchConversations();
      final previews = await Future.wait(
        conversations.map((conversation) async {
          final messages = await _chatRepository.fetchMessages(
            conversationId: conversation.id,
          );
          return ConversationPreview(
            conversation: conversation,
            latestMessage: messages.isEmpty ? null : messages.last,
          );
        }),
      );
      previews.sort((a, b) {
        final aTime = a.latestMessage?.createdAt ?? a.conversation.updatedAt;
        final bTime = b.latestMessage?.createdAt ?? b.conversation.updatedAt;
        return bTime.compareTo(aTime);
      });
      _conversations = previews;
    } on ChatRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your messages.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
