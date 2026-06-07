import 'dart:ui';

import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({
    required this.child,
    super.key,
    this.topBlobOpacity = 0.2,
    this.bottomBlobOpacity = 0.3,
  });

  final Widget child;
  final double topBlobOpacity;
  final double bottomBlobOpacity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -70,
            top: -180,
            child: _BlurredBlob(
              size: const Size(250, 450),
              color: const Color(0xFFA7C8FC).withValues(alpha: topBlobOpacity),
            ),
          ),
          Positioned(
            right: -90,
            bottom: -200,
            child: _BlurredBlob(
              size: const Size(290, 520),
              color: const Color(
                0xFFD8E2FF,
              ).withValues(alpha: bottomBlobOpacity),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  const _BlurredBlob({required this.size, required this.color});

  final Size size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
