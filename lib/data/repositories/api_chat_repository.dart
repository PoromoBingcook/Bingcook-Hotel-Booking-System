import 'package:bingcook/data/services/chat_api_service.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';

class ApiChatRepository implements ChatRepository {
  const ApiChatRepository({
    required ChatApiService chatApiService,
    required AuthRepository authRepository,
  }) : _chatApiService = chatApiService,
       _authRepository = authRepository;

  final ChatApiService _chatApiService;
  final AuthRepository _authRepository;

  @override
  Future<ChatConversation> createConversation({
    required String propertyId,
    String? bookingId,
  }) async {
    try {
      final response = await _chatApiService.createConversation(
        token: _token(),
        propertyId: propertyId,
        bookingId: bookingId,
      );
      return response.toDomain();
    } on ChatRepositoryException {
      rethrow;
    } on ChatApiException catch (error) {
      throw ChatRepositoryException(error.message);
    } on FormatException {
      throw const ChatRepositoryException('Unable to read chat response.');
    } catch (_) {
      throw const ChatRepositoryException('Unable to reach BingCook server.');
    }
  }

  @override
  Future<List<ChatConversation>> fetchConversations() async {
    try {
      final response = await _chatApiService.fetchConversations(
        token: _token(),
      );
      return response.map((item) => item.toDomain()).toList(growable: false);
    } on ChatRepositoryException {
      rethrow;
    } on ChatApiException catch (error) {
      throw ChatRepositoryException(error.message);
    } on FormatException {
      throw const ChatRepositoryException('Unable to read chat response.');
    } catch (_) {
      throw const ChatRepositoryException('Unable to reach BingCook server.');
    }
  }

  @override
  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    DateTime? before,
    int take = 50,
  }) async {
    try {
      final response = await _chatApiService.fetchMessages(
        token: _token(),
        conversationId: conversationId,
        before: before,
        take: take,
      );
      return response.map((item) => item.toDomain()).toList(growable: false);
    } on ChatRepositoryException {
      rethrow;
    } on ChatApiException catch (error) {
      throw ChatRepositoryException(error.message);
    } on FormatException {
      throw const ChatRepositoryException('Unable to read chat response.');
    } catch (_) {
      throw const ChatRepositoryException('Unable to reach BingCook server.');
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    try {
      final response = await _chatApiService.sendMessage(
        token: _token(),
        conversationId: conversationId,
        body: body,
      );
      return response.toDomain();
    } on ChatRepositoryException {
      rethrow;
    } on ChatApiException catch (error) {
      throw ChatRepositoryException(error.message);
    } on FormatException {
      throw const ChatRepositoryException('Unable to read chat response.');
    } catch (_) {
      throw const ChatRepositoryException('Unable to reach BingCook server.');
    }
  }

  @override
  Future<void> markRead({required String conversationId}) async {
    try {
      await _chatApiService.markRead(
        token: _token(),
        conversationId: conversationId,
      );
    } on ChatRepositoryException {
      rethrow;
    } on ChatApiException catch (error) {
      throw ChatRepositoryException(error.message);
    } catch (_) {
      throw const ChatRepositoryException('Unable to reach BingCook server.');
    }
  }

  String _token() {
    final token = _authRepository.currentSession?.token;
    if (token == null || token.isEmpty) {
      throw const ChatRepositoryException('Please login before opening chat.');
    }
    return token;
  }
}
