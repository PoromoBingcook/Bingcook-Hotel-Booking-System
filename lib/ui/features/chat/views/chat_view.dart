import 'dart:async';

import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/chat/view_models/chat_view_model.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({required this.viewModel, required this.onBack, super.key});

  final ChatViewModel viewModel;
  final VoidCallback onBack;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.load());
    widget.viewModel.addListener(_scrollAfterMessageChange);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_scrollAfterMessageChange);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7FAFF),
          body: SafeArea(
            child: Column(
              children: [
                _ChatHeader(
                  title: widget.viewModel.conversation == null
                      ? 'Live Chat'
                      : '${widget.viewModel.conversation!.propertyName} Support',
                  onBack: widget.onBack,
                ),
                Expanded(child: _buildBody()),
                if (widget.viewModel.errorMessage != null)
                  _InlineError(message: widget.viewModel.errorMessage!),
                _MessageComposer(
                  controller: _messageController,
                  isSending: widget.viewModel.isSending,
                  onSubmitted: _sendMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (widget.viewModel.isLoading) {
      return const _ChatLoadingState();
    }

    if (widget.viewModel.messages.isEmpty) {
      return _EmptyChatState(
        name: widget.viewModel.displayName,
        onSuggestionSelected: (message) {
          _messageController.text = message;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: message.length),
          );
        },
      );
    }

    return ListView.builder(
      key: const Key('chat_messages_list'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      itemCount: widget.viewModel.messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _DateDivider(label: 'Today');
        }

        final message = widget.viewModel.messages[index - 1];
        final isMine = message.senderUserId == widget.viewModel.currentUserId;
        return _MessageBubble(message: message, isMine: isMine);
      },
    );
  }

  Future<void> _sendMessage() async {
    final sent = await widget.viewModel.send(_messageController.text);
    if (sent) {
      _messageController.clear();
    }
  }

  void _scrollAfterMessageChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 18, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gray900,
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({
    required this.name,
    required this.onSuggestionSelected,
  });

  final String name;
  final ValueChanged<String> onSuggestionSelected;

  static const _suggestions = [
    'Is early check-in available?',
    'Can I change my booking dates?',
    'Do you offer airport pickup?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
      children: [
        const SizedBox(height: 34),
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x141A73E8),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.primary,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Hello, $name',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gray900,
            fontFamily: 'Manrope',
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'BingCook support is here to help with your stay.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final suggestion in _suggestions)
              ActionChip(
                onPressed: () => onSuggestionSelected(suggestion),
                label: Text(suggestion),
                labelStyle: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD5E5FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final background = isMine ? AppColors.primary : const Color(0xFFEAF2FF);
    final foreground = isMine ? Colors.white : AppColors.gray900;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(14, 11, 12, 9),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 5),
              bottomRight: Radius.circular(isMine ? 5 : 16),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.body,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.72),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        12 + MediaQuery.viewInsetsOf(context).bottom * 0,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Attach',
            onPressed: () {},
            icon: const Icon(
              Icons.attach_file_rounded,
              color: AppColors.slate800,
              size: 24,
            ),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => unawaited(onSubmitted()),
                decoration: const InputDecoration(
                  hintText: 'Type your message here',
                  prefixIcon: Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: AppColors.gray500,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 12, right: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            height: 48,
            child: FilledButton(
              onPressed: isSending ? null : () => unawaited(onSubmitted()),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.slate800,
                disabledBackgroundColor: AppColors.slate400,
                shape: const CircleBorder(),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.gray500,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD4D4)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
