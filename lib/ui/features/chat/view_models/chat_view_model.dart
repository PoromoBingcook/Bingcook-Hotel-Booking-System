import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
    this.initialPropertyId = '11111111-1111-1111-1111-111111111111',
  }) : _chatRepository = chatRepository,
       _authRepository = authRepository;

  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;
  final String initialPropertyId;

  ChatConversation? _conversation;
  List<ChatMessage> _messages = const [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  ChatConversation? get conversation => _conversation;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _authRepository.currentSession?.user.id;
  String get displayName =>
      _authRepository.currentSession?.user.fullName ?? 'Guest';

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final conversations = await _chatRepository.fetchConversations();
      _conversation = conversations.isNotEmpty
          ? conversations.first
          : await _chatRepository.createConversation(
              propertyId: initialPropertyId,
            );
      _messages = await _chatRepository.fetchMessages(
        conversationId: _conversation!.id,
      );
      await _chatRepository.markRead(conversationId: _conversation!.id);
    } on ChatRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to open BingCook chat.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> send(String body) async {
    final trimmed = body.trim();
    final conversation = _conversation;
    if (trimmed.isEmpty || conversation == null || _isSending) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = await _chatRepository.sendMessage(
        conversationId: conversation.id,
        body: trimmed,
      );
      _messages = [..._messages, message];
      return true;
    } on ChatRepositoryException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to send your message.';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
