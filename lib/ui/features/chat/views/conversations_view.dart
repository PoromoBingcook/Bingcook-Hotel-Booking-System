import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/chat/view_models/conversations_view_model.dart';
import 'package:flutter/material.dart';

class ConversationsView extends StatelessWidget {
  const ConversationsView({
    required this.viewModel,
    required this.onBack,
    required this.onConversationSelected,
    super.key,
  });

  final ConversationsViewModel viewModel;
  final VoidCallback onBack;
  final ValueChanged<ChatConversation> onConversationSelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('messages_back_button'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Messages'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    if (viewModel.isLoading && viewModel.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null && viewModel.conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: viewModel.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (viewModel.conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 48, color: AppColors.gray400),
            SizedBox(height: 12),
            Text('No messages yet'),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView.separated(
        key: const Key('conversations_list'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.conversations.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, index) {
          final preview = viewModel.conversations[index];
          final conversation = preview.conversation;
          return ListTile(
            key: Key('conversation_${conversation.id}'),
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEAF2FF),
              child: Text(
                conversation.propertyName.isEmpty
                    ? 'B'
                    : conversation.propertyName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              '${conversation.propertyName} Support',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              preview.latestMessage?.body ?? 'Conversation started',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => onConversationSelected(conversation),
          );
        },
      ),
    );
  }
}
