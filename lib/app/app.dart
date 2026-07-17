import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_router.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/theme/app_theme.dart';
import 'package:bingcook/ui/features/splash/views/splash_view.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    _router = const AppRouter();
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
    return Provider.value(
      value: _dependencies,
      child: MaterialApp(
        title: 'BingCook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: widget.initialRoute,
        onGenerateRoute: _router.onGenerateRoute,
        home: widget.initialRoute == null
            ? _SplashEntry(
                duration: widget.splashDuration,
                authRepository: _dependencies.authRepository,
              )
            : null,
      ),
    );
  }
}

class _SplashEntry extends StatelessWidget {
  const _SplashEntry({required this.duration, required this.authRepository});

  final Duration duration;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return SplashView(
      duration: duration,
      onFinished: () => unawaited(_finish(context)),
    );
  }

  Future<void> _finish(BuildContext context) async {
    final repository = authRepository;
    if (repository is RestorableAuthRepository) {
      await (repository as RestorableAuthRepository).restoreSession();
    }
    if (!context.mounted) return;
    final route = repository.currentSession == null
        ? AppRoutes.login
        : AppRoutes.explore;
    Navigator.of(context).pushReplacementNamed(route);
  }
}
