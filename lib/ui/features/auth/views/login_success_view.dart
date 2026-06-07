import 'dart:ui';

import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoginSuccessView extends StatefulWidget {
  const LoginSuccessView({
    super.key,
    this.animationDuration = const Duration(milliseconds: 2200),
  });

  final Duration animationDuration;

  @override
  State<LoginSuccessView> createState() => _LoginSuccessViewState();
}

class _LoginSuccessViewState extends State<LoginSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.explore);
            }
          });
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFE8F0FE), AppColors.background],
                radius: 1.2,
              ),
            ),
          ),
          const _SuccessBlobs(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _iconScale,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33005BBF),
                              blurRadius: 15,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Redirecting to your home\nfeed...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 192,
                      height: 4,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return LinearProgressIndicator(
                            key: const Key('login_success_progress'),
                            value: _controller.value,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(999),
                            color: AppColors.primaryDark,
                            backgroundColor: const Color(0xFFEDEEEF),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBlobs extends StatelessWidget {
  const _SuccessBlobs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.2,
        child: SizedBox(
          width: 500,
          height: 500,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFAACBFF),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 256, height: 256),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFD8E2FF),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 256, height: 256),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
