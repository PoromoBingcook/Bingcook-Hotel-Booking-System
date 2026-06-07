import 'package:bingcook/app/routes/app_router.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/theme/app_theme.dart';
import 'package:bingcook/ui/features/splash/views/splash_view.dart';
import 'package:flutter/material.dart';

class BingCookApp extends StatelessWidget {
  const BingCookApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
    this.initialRoute,
  });

  final Duration splashDuration;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BingCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: initialRoute == null
          ? _SplashEntry(duration: splashDuration)
          : null,
    );
  }
}

class _SplashEntry extends StatelessWidget {
  const _SplashEntry({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SplashView(
      duration: duration,
      onFinished: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
      },
    );
  }
}
