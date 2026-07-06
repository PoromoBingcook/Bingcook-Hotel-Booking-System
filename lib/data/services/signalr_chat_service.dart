import 'dart:async';

import 'package:bingcook/data/models/chat_api_models.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRChatService implements ChatRealtimeService {
  SignalRChatService({
    required Uri baseUrl,
    required AuthRepository authRepository,
  }) : _hubUrl = baseUrl.replace(path: '/hubs/chat').toString(),
       _authRepository = authRepository;

  final String _hubUrl;
  final AuthRepository _authRepository;
  HubConnection? _connection;
  StreamController<ChatMessage>? _controller;
  String? _conversationId;

  @override
  Stream<ChatMessage> watchConversation(String conversationId) {
    final previousConnection = _connection;
    final previousController = _controller;
    late final StreamController<ChatMessage> controller;
    controller = StreamController<ChatMessage>.broadcast(
      onCancel: () => _disconnectController(controller),
    );
    _connection = null;
    _controller = controller;
    _conversationId = conversationId;
    unawaited(previousController?.close());
    unawaited(_connect(conversationId, controller, previousConnection));
    return controller.stream;
  }

  Future<void> _connect(
    String conversationId,
    StreamController<ChatMessage> controller,
    HubConnection? previousConnection,
  ) async {
    await previousConnection?.stop();

    final options = HttpConnectionOptions(
      accessTokenFactory: () async =>
          _authRepository.currentSession?.token ?? '',
    );
    final connection = HubConnectionBuilder()
        .withUrl(_hubUrl, options: options)
        .withAutomaticReconnect(
          retryDelays: const [0, 2000, 5000, 10000, 30000],
        )
        .build();
    _connection = connection;
    connection.on('message.created', _onMessageCreated);
    connection.onreconnected(({connectionId}) {
      final activeConversation = _conversationId;
      if (activeConversation != null) {
        unawaited(
          connection.invoke('JoinConversation', args: [activeConversation]),
        );
      }
    });

    try {
      await connection.start();
      if (_connection != connection || _conversationId != conversationId) {
        await connection.stop();
        return;
      }
      await connection.invoke('JoinConversation', args: [conversationId]);
    } catch (error, stackTrace) {
      if (_controller == controller && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  void _onMessageCreated(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;
    final value = arguments.first;
    if (value is! Map) return;
    try {
      final json = value.map((key, value) => MapEntry(key.toString(), value));
      final message = ChatMessageResponse.fromJson(json).toDomain();
      if (message.conversationId == _conversationId) {
        _controller?.add(message);
      }
    } on FormatException {
      // Ignore malformed hub events; the initial REST load remains authoritative.
    }
  }

  @override
  Future<void> disconnect() async {
    final connection = _connection;
    final conversationId = _conversationId;
    _connection = null;
    _conversationId = null;
    if (connection != null) {
      if (connection.state == HubConnectionState.Connected &&
          conversationId != null) {
        try {
          await connection.invoke('LeaveConversation', args: [conversationId]);
        } catch (_) {
          // The connection may already be closing.
        }
      }
      await connection.stop();
    }
    await _controller?.close();
    _controller = null;
  }

  Future<void> _disconnectController(
    StreamController<ChatMessage> controller,
  ) async {
    if (_controller != controller) return;
    await disconnect();
  }
}
