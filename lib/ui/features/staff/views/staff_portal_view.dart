import 'dart:async';

import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/chat/view_models/chat_view_model.dart';
import 'package:bingcook/ui/features/chat/views/chat_view.dart';
import 'package:bingcook/ui/features/staff/models/staff_chat_preview.dart';
import 'package:bingcook/ui/features/staff/view_models/staff_portal_view_model.dart';
import 'package:bingcook/ui/features/staff/widgets/staff_bottom_navigation.dart';
import 'package:flutter/material.dart';

class StaffPortalView extends StatefulWidget {
  const StaffPortalView({
    required this.authRepository,
    required this.chatRepository,
    required this.onLoggedOut,
    this.chatRealtimeService,
    super.key,
  });

  final AuthRepository authRepository;
  final ChatRepository chatRepository;
  final VoidCallback onLoggedOut;
  final ChatRealtimeService? chatRealtimeService;

  @override
  State<StaffPortalView> createState() => _StaffPortalViewState();
}

class _StaffPortalViewState extends State<StaffPortalView> {
  late final StaffPortalViewModel _viewModel;
  int _selectedIndex = 0;
  ChatViewModel? _activeChat;
  Timer? _dashboardRefreshTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = StaffPortalViewModel(
      chatRepository: widget.chatRepository,
      authRepository: widget.authRepository,
    );
    unawaited(_viewModel.load());
    _dashboardRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _activeChat != null) return;
      // ponytail: polling fallback, replace with a staff conversations stream when available.
      unawaited(_viewModel.load());
    });
  }

  @override
  void dispose() {
    _dashboardRefreshTimer?.cancel();
    _activeChat?.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeChat = _activeChat;
    if (activeChat != null) {
      return ChatView(
        viewModel: activeChat,
        onBack: () {
          final closingChat = _activeChat;
          setState(() => _activeChat = null);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => closingChat?.dispose(),
          );
          unawaited(_viewModel.load());
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StaffHeader(name: _viewModel.staffName, onLogout: _logout),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _ChatsDashboard(viewModel: _viewModel, onOpenChat: _openChat),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) =>
                        _BookingsOverview(chats: _viewModel.chats),
                  ),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) =>
                        _ReservationsOverview(chats: _viewModel.chats),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StaffBottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  void _openChat(StaffChatPreview preview) {
    _activeChat?.dispose();
    setState(() {
      _activeChat = ChatViewModel(
        chatRepository: widget.chatRepository,
        authRepository: widget.authRepository,
        initialConversation: preview.conversation,
        realtimeService: widget.chatRealtimeService,
        refreshInterval: const Duration(seconds: 2),
      );
    });
  }

  Future<void> _logout() async {
    await widget.authRepository.logout();
    widget.onLoggedOut();
  }
}

class _StaffHeader extends StatelessWidget {
  const _StaffHeader({required this.name, required this.onLogout});
  final String name;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFDBEAFE),
            child: Text(
              name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Staff Portal',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.primaryDark,
          ),
          PopupMenuButton<String>(
            tooltip: 'Staff menu',
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatsDashboard extends StatelessWidget {
  const _ChatsDashboard({required this.viewModel, required this.onOpenChat});
  final StaffPortalViewModel viewModel;
  final ValueChanged<StaffChatPreview> onOpenChat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading && viewModel.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage != null && viewModel.chats.isEmpty) {
          return _PortalError(
            message: viewModel.errorMessage!,
            onRetry: viewModel.load,
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              if (viewModel.urgentChats.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.error, size: 17, color: AppColors.error),
                    const SizedBox(width: 7),
                    Text(
                      'Urgent Replies Needed (${viewModel.urgentChats.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 164,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.urgentChats.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) => _UrgentChatCard(
                      preview: viewModel.urgentChats[index],
                      onReply: () => onOpenChat(viewModel.urgentChats[index]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                'Recent Messages',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (viewModel.chats.isEmpty)
                const _EmptyPortalState(
                  icon: Icons.forum_outlined,
                  text: 'No customer conversations yet.',
                )
              else
                for (final preview in viewModel.chats)
                  _RecentMessageTile(
                    preview: preview,
                    onTap: () => onOpenChat(preview),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _UrgentChatCard extends StatelessWidget {
  const _UrgentChatCard({required this.preview, required this.onReply});
  final StaffChatPreview preview;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.conversation.customerName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            preview.conversation.propertyName,
            style: const TextStyle(color: AppColors.gray600, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              preview.latestMessage?.body ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onReply,
              icon: const Icon(Icons.reply_rounded, size: 17),
              label: const Text('Reply Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentMessageTile extends StatelessWidget {
  const _RecentMessageTile({required this.preview, required this.onTap});
  final StaffChatPreview preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final message = preview.latestMessage;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDBEAFE),
        child: Text(preview.conversation.customerName.substring(0, 1)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              preview.conversation.customerName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (message != null)
            Text(
              _time(message.createdAt),
              style: const TextStyle(color: AppColors.gray500, fontSize: 11),
            ),
        ],
      ),
      subtitle: Text(
        message?.body ?? 'Conversation started',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: preview.needsReply
          ? const CircleAvatar(radius: 4, backgroundColor: AppColors.error)
          : const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _BookingsOverview extends StatelessWidget {
  const _BookingsOverview({required this.chats});
  final List<StaffChatPreview> chats;

  @override
  Widget build(BuildContext context) {
    final unread = chats.where((chat) => chat.needsReply).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Operations Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            const _MetricCard(icon: Icons.login_rounded, label: 'Check-ins'),
            const _MetricCard(icon: Icons.logout_rounded, label: 'Check-outs'),
            const _MetricCard(
              icon: Icons.receipt_long_outlined,
              label: 'New Bookings',
            ),
            _MetricCard(
              icon: Icons.chat_rounded,
              label: 'Unread Chats',
              value: unread.toString().padLeft(2, '0'),
              highlighted: unread > 0,
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Today’s Agenda',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const _EmptyPortalState(
          icon: Icons.event_available_outlined,
          text: 'No operational agenda is available yet.',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    this.value = '00',
    this.highlighted = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFE8F0FF) : Colors.white,
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.gray200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.gray600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ReservationsOverview extends StatelessWidget {
  const _ReservationsOverview({required this.chats});
  final List<StaffChatPreview> chats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Reservations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            Icon(Icons.calendar_month_outlined, color: AppColors.primaryDark),
          ],
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('All')),
            Chip(label: Text('Pending')),
            Chip(label: Text('Confirmed')),
            Chip(label: Text('Checked-in')),
          ],
        ),
        const SizedBox(height: 30),
        const _EmptyPortalState(
          icon: Icons.calendar_today_outlined,
          text: 'Staff reservation data is not exposed by the backend yet.',
        ),
      ],
    );
  }
}

class _EmptyPortalState extends StatelessWidget {
  const _EmptyPortalState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gray400, size: 38),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _PortalError extends StatelessWidget {
  const _PortalError({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

String _time(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
}
