import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GuestInformationSection extends StatelessWidget {
  const GuestInformationSection({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Guest Information'),
        const SizedBox(height: 12),
        _GuestField(
          label: 'Full Name',
          controller: nameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 12),
        _GuestField(
          label: 'Email Address',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 12),
        _GuestField(
          label: 'Phone Number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
      ],
    );
  }
}

class _GuestField extends StatelessWidget {
  const _GuestField({
    required this.label,
    required this.controller,
    required this.textInputAction,
    required this.autofillHints,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            style: const TextStyle(color: AppColors.hint, fontSize: 14),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
