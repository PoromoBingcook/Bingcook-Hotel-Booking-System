import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.brandMark, width: 21, height: 20),
            const SizedBox(width: 8),
            const Text(
              'BingCook',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 22),
              color: AppColors.textSecondary,
              tooltip: 'Close',
            ),
          ],
        ),
      ),
    );
  }
}
