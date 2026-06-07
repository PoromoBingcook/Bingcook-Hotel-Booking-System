import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PaymentCardPreview extends StatelessWidget {
  const PaymentCardPreview({
    required this.cardholderName,
    required this.expiryDate,
    super.key,
  });

  final String cardholderName;
  final String expiryDate;

  @override
  Widget build(BuildContext context) {
    final holder = cardholderName.trim().isEmpty
        ? 'NAME SURNAME'
        : cardholderName.trim().toUpperCase();
    final expiry = expiryDate.trim().isEmpty ? 'MM/YY' : expiryDate.trim();

    return Container(
      height: 176,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sim_card_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Icon(
                Icons.payments_outlined,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '••••  ••••  ••••  ••••',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'JetBrains Mono',
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _CardLabel(label: 'CARD HOLDER', value: holder),
              ),
              const SizedBox(width: 12),
              _CardLabel(label: 'EXPIRES', value: expiry, alignEnd: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 8,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.3,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
