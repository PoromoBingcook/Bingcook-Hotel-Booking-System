import 'dart:async';

import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:bingcook/ui/features/chat/view_models/chat_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a conversation for the selected property', () async {
    final repository = _ChatRepository(
      conversations: [_conversation(propertyId: 'another-property')],
    );
    final viewModel = ChatViewModel(
      chatRepository: repository,
      authRepository: _AuthRepository(),
      initialPropertyId: 'selected-property',
    );

    await viewModel.load();

    expect(repository.createdPropertyId, 'selected-property');
    expect(viewModel.conversation?.propertyId, 'selected-property');
    expect(repository.loadedConversationId, 'selected-property-chat');
    expect(repository.markedConversationId, 'selected-property-chat');
  });

  test(
    'reuses the open conversation belonging to the selected property',
    () async {
      final selected = _conversation(propertyId: 'selected-property');
      final repository = _ChatRepository(
        conversations: [
          _conversation(propertyId: 'another-property'),
          selected,
        ],
      );
      final viewModel = ChatViewModel(
        chatRepository: repository,
        authRepository: _AuthRepository(),
        initialPropertyId: 'selected-property',
      );

      await viewModel.load();

      expect(repository.createdPropertyId, isNull);
      expect(viewModel.conversation?.id, selected.id);
    },
  );

  test(
    'sends a real repository message into the active conversation',
    () async {
      final repository = _ChatRepository(
        conversations: [_conversation(propertyId: 'selected-property')],
      );
      final viewModel = ChatViewModel(
        chatRepository: repository,
        authRepository: _AuthRepository(),
        initialPropertyId: 'selected-property',
      );
      await viewModel.load();

      final sent = await viewModel.send('  Is early check-in available?  ');

      expect(sent, isTrue);
      expect(repository.sentBody, 'Is early check-in available?');
      expect(viewModel.messages.single.body, 'Is early check-in available?');
    },
  );

  test('adds messages pushed by the SignalR conversation stream', () async {
    final repository = _ChatRepository(
      conversations: [_conversation(propertyId: 'selected-property')],
    );
    final realtime = _ChatRealtimeService();
    final viewModel = ChatViewModel(
      chatRepository: repository,
      authRepository: _AuthRepository(),
      realtimeService: realtime,
      initialPropertyId: 'selected-property',
    );
    await viewModel.load();

    realtime.add(
      ChatMessage(
        id: 'host-message',
        conversationId: 'selected-property-chat',
        senderUserId: 'host-1',
        senderName: 'Hotel Support',
        body: 'Your room is ready.',
        createdAt: DateTime(2026, 7, 6, 11),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(realtime.watchedConversationId, 'selected-property-chat');
    expect(viewModel.messages.single.body, 'Your room is ready.');
    viewModel.dispose();
  });
  test(
    'does not duplicate a sent message that arrives from realtime first',
    () async {
      final realtime = _ChatRealtimeService();
      final repository =
          _ChatRepository(
              conversations: [_conversation(propertyId: 'selected-property')],
            )
            ..onSendCreated = (message) async {
              realtime.add(message);
              await Future<void>.delayed(Duration.zero);
            };
      final viewModel = ChatViewModel(
        chatRepository: repository,
        authRepository: _AuthRepository(),
        realtimeService: realtime,
        initialPropertyId: 'selected-property',
      );
      await viewModel.load();

      final sent = await viewModel.send('sure');

      expect(sent, isTrue);
      expect(viewModel.messages, hasLength(1));
      expect(viewModel.messages.single.body, 'sure');
      viewModel.dispose();
    },
  );
}

ChatConversation _conversation({required String propertyId}) =>
    ChatConversation(
      id: '$propertyId-chat',
      propertyId: propertyId,
      propertyName: 'Ocean Pearl Hotel',
      customerUserId: 'customer-1',
      customerName: 'Jane Cook',
      status: 'Open',
      createdAt: DateTime(2026, 7, 6),
      updatedAt: DateTime(2026, 7, 6),
    );

class _ChatRepository implements ChatRepository {
  _ChatRepository({required this.conversations});

  final List<ChatConversation> conversations;
  String? createdPropertyId;
  String? loadedConversationId;
  String? markedConversationId;
  String? sentBody;
  FutureOr<void> Function(ChatMessage message)? onSendCreated;

  @override
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  }) async {
    createdPropertyId = propertyId;
    return _conversation(propertyId: propertyId);
  }

  @override
  Future<List<ChatConversation>> fetchConversations() async => conversations;

  @override
  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) async {
    loadedConversationId = conversationId;
    return [];
  }

  @override
  Future<void> markRead({required String conversationId}) async {
    markedConversationId = conversationId;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    sentBody = body;
    final message = ChatMessage(
      id: 'message-1',
      conversationId: conversationId,
      senderUserId: 'customer-1',
      senderName: 'Jane Cook',
      body: body,
      createdAt: DateTime(2026, 7, 6, 10),
    );
    final callback = onSendCreated;
    if (callback != null) await callback(message);
    return message;
  }
}

class _AuthRepository implements AuthRepository {
  @override
  AuthSession get currentSession => const AuthSession(
    token: 'jwt-token',
    user: AuthUser(
      id: 'customer-1',
      fullName: 'Jane Cook',
      email: 'jane@example.com',
      phone: '0900000000',
      role: 'Customer',
    ),
  );

  @override
  Future<AuthSession> login({
    required String identity,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => throw UnimplementedError();
}

class _ChatRealtimeService implements ChatRealtimeService {
  final _controller = StreamController<ChatMessage>.broadcast();
  String? watchedConversationId;

  void add(ChatMessage message) => _controller.add(message);

  @override
  Stream<ChatMessage> watchConversation(String conversationId) {
    watchedConversationId = conversationId;
    return _controller.stream;
  }

  @override
  Future<void> disconnect() => _controller.close();
}
