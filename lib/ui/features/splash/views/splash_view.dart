import 'dart:async';

import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/atmospheric_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashView extends StatefulWidget {
  const SplashView({
    required this.duration,
    required this.onFinished,
    super.key,
  });

  final Duration duration;
  final VoidCallback onFinished;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AtmosphericBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 144,
                  height: 144,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x331A73E8),
                              blurRadius: 24,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      SvgPicture.asset(
                        AppAssets.splashLogo,
                        width: 144,
                        height: 144,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BingCook',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: AppColors.primaryDark,
                    fontSize: 32,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.64,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adventure begins with a single tap.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
