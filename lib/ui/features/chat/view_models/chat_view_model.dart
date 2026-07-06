import 'dart:async';

import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:flutter/foundation.dart';

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
    ChatRealtimeService? realtimeService,
    this.initialPropertyId = '11111111-1111-1111-1111-111111111111',
    this.initialBookingId,
    this.initialConversation,
  }) : _chatRepository = chatRepository,
       _authRepository = authRepository,
       _realtimeService = realtimeService;

  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;
  final ChatRealtimeService? _realtimeService;
  final String initialPropertyId;
  final String? initialBookingId;
  final ChatConversation? initialConversation;

  ChatConversation? _conversation;
  List<ChatMessage> _messages = const [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  StreamSubscription<ChatMessage>? _messageSubscription;

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
      if (initialConversation != null) {
        _conversation = initialConversation;
      } else {
        final conversations = await _chatRepository.fetchConversations();
        _conversation =
            _findPropertyConversation(conversations) ??
            await _chatRepository.createConversation(
              propertyId: initialPropertyId,
              bookingId: initialBookingId,
            );
      }
      _messages = await _chatRepository.fetchMessages(
        conversationId: _conversation!.id,
      );
      await _chatRepository.markRead(conversationId: _conversation!.id);
      _listenForMessages();
    } on ChatRepositoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to open BingCook chat.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenForMessages() {
    final conversation = _conversation;
    final realtimeService = _realtimeService;
    if (conversation == null || realtimeService == null) return;
    unawaited(_messageSubscription?.cancel());
    _messageSubscription = realtimeService
        .watchConversation(conversation.id)
        .listen((message) {
          if (_messages.any((existing) => existing.id == message.id)) return;
          _messages = [..._messages, message];
          notifyListeners();
          unawaited(_chatRepository.markRead(conversationId: conversation.id));
        });
  }

  @override
  void dispose() {
    unawaited(_messageSubscription?.cancel());
    super.dispose();
  }

  ChatConversation? _findPropertyConversation(
    List<ChatConversation> conversations,
  ) {
    for (final conversation in conversations) {
      final matchesProperty = conversation.propertyId == initialPropertyId;
      final matchesBooking = initialBookingId == null
          ? conversation.bookingId == null
          : conversation.bookingId == initialBookingId;
      if (matchesProperty && matchesBooking && conversation.status == 'Open') {
        return conversation;
      }
    }
    return null;
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
