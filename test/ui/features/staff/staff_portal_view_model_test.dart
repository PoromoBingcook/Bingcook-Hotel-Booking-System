import 'package:bingcook/domain/models/auth_session.dart';
import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/ui/features/staff/view_models/staff_portal_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds recent and urgent cards from repository messages', () async {
    final conversation = ChatConversation(
      id: 'conversation-1',
      propertyId: 'property-1',
      propertyName: 'Ocean Pearl Hotel',
      customerUserId: 'customer-1',
      customerName: 'Michael T.',
      status: 'Open',
      hostLastReadAt: DateTime(2026, 7, 6, 8),
      createdAt: DateTime(2026, 7, 6, 7),
      updatedAt: DateTime(2026, 7, 6, 9),
    );
    final repository = _ChatRepository(conversation);
    final viewModel = StaffPortalViewModel(
      chatRepository: repository,
      authRepository: _AuthRepository(),
    );

    await viewModel.load();

    expect(
      viewModel.chats.single.latestMessage?.body,
      'The AC is not working.',
    );
    expect(
      viewModel.urgentChats.single.conversation.customerName,
      'Michael T.',
    );
    expect(repository.requestedTake, 1);
  });
}

class _ChatRepository implements ChatRepository {
  _ChatRepository(this.conversation);
  final ChatConversation conversation;
  int? requestedTake;

  @override
  Future<List<ChatConversation>> fetchConversations() async => [conversation];

  @override
  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) async {
    requestedTake = take;
    return [
      ChatMessage(
        id: 'message-1',
        conversationId: conversationId,
        senderUserId: 'customer-1',
        senderName: 'Michael T.',
        body: 'The AC is not working.',
        createdAt: DateTime(2026, 7, 6, 9),
      ),
    ];
  }

  @override
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  }) => throw UnimplementedError();

  @override
  Future<void> markRead({required String conversationId}) =>
      throw UnimplementedError();

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) => throw UnimplementedError();
}

class _AuthRepository implements AuthRepository {
  @override
  AuthSession get currentSession => const AuthSession(
    token: 'staff-token',
    user: AuthUser(
      id: 'staff-1',
      fullName: 'Marco Staff',
      email: 'marco@example.com',
      phone: null,
      role: 'Admin',
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
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => throw UnimplementedError();
}
