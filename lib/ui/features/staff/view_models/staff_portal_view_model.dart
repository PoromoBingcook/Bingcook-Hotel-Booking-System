import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/ui/features/staff/models/staff_chat_preview.dart';
import 'package:flutter/foundation.dart';

class StaffPortalViewModel extends ChangeNotifier {
  StaffPortalViewModel({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
  }) : _chatRepository = chatRepository,
       _authRepository = authRepository;

  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;

  List<StaffChatPreview> _chats = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StaffChatPreview> get chats => List.unmodifiable(_chats);
  List<StaffChatPreview> get urgentChats =>
      _chats.where((chat) => chat.needsReply).toList(growable: false);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get staffName =>
      _authRepository.currentSession?.user.fullName ?? 'Staff';

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final conversations = await _chatRepository.fetchConversations();
      final previews = await Future.wait(conversations.map(_loadPreview));
      previews.sort((a, b) {
        final aTime = a.latestMessage?.createdAt ?? a.conversation.updatedAt;
        final bTime = b.latestMessage?.createdAt ?? b.conversation.updatedAt;
        return bTime.compareTo(aTime);
      });
      _chats = previews;
    } on ChatRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load staff conversations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StaffChatPreview> _loadPreview(ChatConversation conversation) async {
    final messages = await _chatRepository.fetchMessages(
      conversationId: conversation.id,
      take: 1,
    );
    final latest = messages.isEmpty ? null : messages.last;
    final hostReadAt = conversation.hostLastReadAt;
    final unread =
        latest != null &&
        (hostReadAt == null || latest.createdAt.isAfter(hostReadAt));
    final fromCustomer = latest?.senderUserId == conversation.customerUserId;
    return StaffChatPreview(
      conversation: conversation,
      latestMessage: latest,
      needsReply: unread && fromCustomer,
    );
  }
}
