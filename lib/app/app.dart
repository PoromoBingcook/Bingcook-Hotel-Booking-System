import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_router.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/theme/app_theme.dart';
import 'package:bingcook/ui/features/splash/views/splash_view.dart';
import 'package:flutter/material.dart';

class BingCookApp extends StatefulWidget {
  const BingCookApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
    this.initialRoute,
    this.dependencies,
  });

  final Duration splashDuration;
  final String? initialRoute;
  final AppDependencies? dependencies;

  @override
  State<BingCookApp> createState() => _BingCookAppState();
}

class _BingCookAppState extends State<BingCookApp> {
  late final AppDependencies _dependencies;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _dependencies = widget.dependencies ?? AppDependencies.production();
    _router = AppRouter(dependencies: _dependencies);
  }

  @override
  void dispose() {
    if (widget.dependencies == null) {
      _dependencies.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BingCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: widget.initialRoute,
      onGenerateRoute: _router.onGenerateRoute,
      home: widget.initialRoute == null
          ? _SplashEntry(duration: widget.splashDuration)
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
