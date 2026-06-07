import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AddCardFooter extends StatelessWidget {
  const AddCardFooter({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E3E4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              key: const Key('save_card_button'),
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save and Continue',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'By adding this card, you agree to our Payment Terms',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
