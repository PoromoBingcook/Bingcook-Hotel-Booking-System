import 'package:bingcook/domain/models/auth_user.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PersonalInformationView extends StatelessWidget {
  const PersonalInformationView({
    required this.user,
    required this.onBack,
    super.key,
  });

  final AuthUser? user;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          key: const Key('personal_information_back_button'),
          tooltip: 'Quay lại',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('personal_information_view'),
          padding: const EdgeInsets.all(16),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE4E4E4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InformationRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Họ và tên',
                    value: _value(user?.fullName),
                  ),
                  const Divider(height: 1),
                  _InformationRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _value(user?.email),
                  ),
                  const Divider(height: 1),
                  _InformationRow(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: _value(user?.phone),
                  ),
                  const Divider(height: 1),
                  _InformationRow(
                    icon: Icons.badge_outlined,
                    label: 'Vai trò',
                    value: _value(user?.role),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _value(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
