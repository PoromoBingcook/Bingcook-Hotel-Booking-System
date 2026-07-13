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
          color: const Color(0xFFF6F7FA),
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              key: const Key('profile_scroll_view'),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileTopBar(
                    unreadNotifications: unreadNotifications,
                    onMessagesRequested: onMessagesRequested,
                    onNotificationsRequested: onNotificationsRequested,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  sliver: SliverList.list(
                    children: [
                      _IdentityHeader(
                        name: viewModel.displayName,
                        role: viewModel.roleLabel,
                        onEdit: onPersonalInformationRequested,
                      ),
                      const SizedBox(height: 30),
                      _SectionLabel('PERSONAL INFORMATION'),
                      const SizedBox(height: 12),
                      _InformationCard(
                        fullName: viewModel.displayName,
                        email: viewModel.email,
                        phone: viewModel.phone,
                        onTap: onPersonalInformationRequested,
                      ),
                      const SizedBox(height: 30),
                      const _SectionLabel('ACCOUNT SETTINGS'),
                      const SizedBox(height: 12),
                      _ActionCard(
                        items: [
                          _ProfileActionItem(
                            icon: Icons.credit_card_rounded,
                            label: 'Payment Methods',
                          ),
                          _ProfileActionItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                          ),
                          _ProfileActionItem(
                            key: const Key('profile_notifications_item'),
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            badgeCount: unreadNotifications,
                            onTap: onNotificationsRequested,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionLabel('BINGCOOK SUPPORT'),
                      const SizedBox(height: 12),
                      _ActionCard(
                        items: [
                          _ProfileActionItem(
                            key: const Key('profile_messages_item'),
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Messages',
                            onTap: onMessagesRequested,
                          ),
                          _ProfileActionItem(
                            key: const Key('profile_support_item'),
                            icon: Icons.support_agent_rounded,
                            label: 'Contact Support',
                            onTap: onSupportRequested,
                          ),
                          _ProfileActionItem(
                            icon: Icons.rate_review_outlined,
                            label: 'My Reviews',
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _LogoutButton(
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
          ),
        );
      },
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.unreadNotifications,
    required this.onMessagesRequested,
    required this.onNotificationsRequested,
  });

  final int unreadNotifications;
  final VoidCallback onMessagesRequested;
  final VoidCallback onNotificationsRequested;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 2),
            const Expanded(
              child: Text(
                'Profile',
                key: Key('profile_title'),
                style: TextStyle(
                  color: AppColors.gray900,
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              key: const Key('profile_messages_button'),
              tooltip: 'Messages',
              onPressed: onMessagesRequested,
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            _NotificationButton(
              unreadCount: unreadNotifications,
              onPressed: onNotificationsRequested,
            ),
          ],
        ),
      ),
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
        IconButton(
          key: const Key('profile_notifications_button'),
          tooltip: 'Notifications',
          onPressed: onPressed,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
            size: 27,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: _NotificationBadge(count: unreadCount),
          ),
      ],
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({
    required this.name,
    required this.role,
    required this.onEdit,
  });

  final String name;
  final String role;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileAvatar(name: name, onEdit: onEdit),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.gray900,
            fontFamily: 'Manrope',
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.gray600,
            fontFamily: 'Manrope',
            fontSize: 16,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.onEdit});

  final String name;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'B' : name.trim()[0].toUpperCase();

    return SizedBox(
      width: 118,
      height: 118,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDE2EA), width: 4),
                color: const Color(0xFFEAF2FF),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Manrope',
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 8,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('profile_avatar_edit_button'),
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.gray600,
        fontFamily: 'Manrope',
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.onTap,
  });

  final String fullName;
  final String email;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: InkWell(
        key: const Key('profile_personal_info_item'),
        onTap: onTap,
        child: Column(
          children: [
            _InformationRow(
              label: 'FULL NAME',
              value: fullName,
              icon: Icons.person_outline_rounded,
            ),
            const Divider(height: 1, color: Color(0xFFE9EBEF)),
            _InformationRow(
              label: 'EMAIL',
              value: email,
              icon: Icons.mail_outline_rounded,
            ),
            const Divider(height: 1, color: Color(0xFFE9EBEF)),
            _InformationRow(
              label: 'PHONE',
              value: phone,
              icon: Icons.phone_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: AppColors.outline, size: 28),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.items});

  final List<_ProfileActionItem> items;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index != items.length - 1)
              const Divider(height: 1, color: Color(0xFFE9EBEF)),
          ],
        ],
      ),
    );
  }
}

class _ProfileActionItem extends StatelessWidget {
  const _ProfileActionItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      child: Semantics(
        button: enabled,
        label: label,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 22),
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: 19,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                _NotificationBadge(count: badgeCount),
                const SizedBox(width: 10),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray400,
                size: 30,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E5EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('profile_notification_badge'),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
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
          label: Text(isLoading ? 'Logging out' : 'Log Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: Color(0xFFF5CACA)),
            backgroundColor: Colors.white,
            minimumSize: const Size.fromHeight(58),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
