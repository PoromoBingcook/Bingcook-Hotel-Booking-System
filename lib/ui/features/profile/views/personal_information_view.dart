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
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Personal Information',
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
                  _ReadOnlyInformationRow(
                    key: const Key('personal_information_full_name_field'),
                    icon: Icons.person_outline_rounded,
                    label: 'Full Name',
                    value: _value(user?.fullName),
                  ),
                  const Divider(height: 1),
                  _ReadOnlyInformationRow(
                    key: const Key('personal_information_email_field'),
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _value(user?.email),
                  ),
                  const Divider(height: 1),
                  _ReadOnlyInformationRow(
                    key: const Key('personal_information_phone_field'),
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: _value(user?.phone),
                  ),
                  const Divider(height: 1),
                  _ReadOnlyInformationRow(
                    icon: Icons.badge_outlined,
                    label: 'Role',
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
    return trimmed == null || trimmed.isEmpty ? 'Not updated' : trimmed;
  }
}

class _ReadOnlyInformationRow extends StatelessWidget {
  const _ReadOnlyInformationRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
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
          Icon(icon, color: AppColors.gray400, size: 24),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.gray400,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
