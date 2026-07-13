import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.viewModel,
    required this.unreadNotifications,
    required this.onMessagesRequested,
    required this.onNotificationsRequested,
    required this.onPersonalInformationRequested,
    required this.onSupportRequested,
    required this.onLoggedOut,
    super.key,
  });

  final ProfileViewModel viewModel;
  final int unreadNotifications;
  final VoidCallback onMessagesRequested;
  final VoidCallback onNotificationsRequested;
  final VoidCallback onPersonalInformationRequested;
  final VoidCallback onSupportRequested;
  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ColoredBox(
          color: const Color(0xFFF5F5F5),
          child: CustomScrollView(
            key: const Key('profile_scroll_view'),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  viewModel: viewModel,
                  unreadNotifications: unreadNotifications,
                  onMessagesRequested: onMessagesRequested,
                  onNotificationsRequested: onNotificationsRequested,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                sliver: SliverList.list(
                  children: [
                    _ProfileSection(
                      title: 'Thông tin thanh toán',
                      items: [
                        _ProfileActionItem(
                          icon: Icons.credit_card_rounded,
                          label: 'Phương thức thanh toán',
                        ),
                        _ProfileActionItem(
                          icon: Icons.receipt_long_outlined,
                          label: 'Giao dịch',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ProfileSection(
                      title: 'Quản lý tài khoản',
                      items: [
                        _ProfileActionItem(
                          icon: Icons.person_outline_rounded,
                          onTap: onPersonalInformationRequested,
                          label: 'Thông tin cá nhân',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ProfileSection(
                      title: 'Hoạt động du lịch',
                      items: [
                        _ProfileActionItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Đánh giá của tôi',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ProfileSection(
                      title: 'Trợ giúp',
                      items: [
                        _ProfileActionItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Trung tâm trợ giúp',
                        ),
                        _ProfileActionItem(
                          icon: Icons.support_agent_rounded,
                          onTap: onSupportRequested,
                          label: 'Liên hệ hỗ trợ',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _LogoutTile(
                      isLoading: viewModel.isLoggingOut,
                      errorMessage: viewModel.errorMessage,
                      onPressed: () async {
                        final success = await viewModel.logout();
                        if (success) {
                          onLoggedOut();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.viewModel,
    required this.unreadNotifications,
    required this.onMessagesRequested,
    required this.onNotificationsRequested,
  });

  final ProfileViewModel viewModel;
  final int unreadNotifications;
  final VoidCallback onMessagesRequested;
  final VoidCallback onNotificationsRequested;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF003B95),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProfileAvatar(name: viewModel.displayName),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào ${viewModel.displayName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 28,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.membershipLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFC629),
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeaderIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onPressed: onMessagesRequested,
                    tooltip: 'Tin nhắn',
                  ),
                  const SizedBox(width: 8),
                  _NotificationButton(
                    unreadCount: unreadNotifications,
                    onPressed: onNotificationsRequested,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _AccountSummaryCard(email: viewModel.email),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'B' : name.trim()[0].toUpperCase();

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFC629), width: 3),
        color: const Color(0xFFEAF2FF),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF003B95),
          fontFamily: 'Manrope',
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: onPressed,
          tooltip: 'Thông báo',
        ),
        if (unreadCount > 0)
          Positioned(
          top: 4,
          right: 2,
          child: Container(
            key: const Key('profile_notification_badge'),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(
              color: Color(0xFFE11D2E),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              unreadCount > 9 ? '9+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF003B95),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tài khoản BingCook',
                  style: TextStyle(
                    color: AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});

  final String title;
  final List<_ProfileActionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Manrope',
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4E4E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  items[index],
                  if (index != items.length - 1)
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionItem extends StatelessWidget {
  const _ProfileActionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: label,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(icon, color: Colors.black, size: 28),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({
    required this.isLoading,
    required this.errorMessage,
    required this.onPressed,
  });

  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('profile_logout_button'),
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(isLoading ? 'Đang đăng xuất' : 'Đăng xuất'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: Color(0xFFFFD4D4)),
            backgroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
