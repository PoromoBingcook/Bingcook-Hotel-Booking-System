import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CheckoutFooter extends StatelessWidget {
  const CheckoutFooter({required this.onConfirm, super.key});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Color(0xFFE8F0FE))),
      ),
      child: SizedBox(
        height: 48,
        child: FilledButton.icon(
          key: const Key('confirm_booking_button'),
          onPressed: onConfirm,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 17),
          label: const Text('Confirm Booking'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
