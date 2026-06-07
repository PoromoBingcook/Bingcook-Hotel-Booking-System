import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentTrustBadges extends StatelessWidget {
  const PaymentTrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TrustBadge(asset: AppAssets.checkoutPci, label: 'PCI COMPLIANT'),
        SizedBox(width: 24),
        _TrustBadge(asset: AppAssets.checkoutSsl, label: '256-BIT SSL'),
        SizedBox(width: 24),
        _TrustBadge(asset: AppAssets.checkoutSecure, label: 'SECURE PAY'),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.40,
      child: Column(
        children: [
          SvgPicture.asset(
            asset,
            width: 22,
            height: 26,
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'JetBrains Mono',
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
