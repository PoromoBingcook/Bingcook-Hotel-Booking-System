import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/login_success_view.dart';
import 'package:bingcook/ui/features/auth/views/login_view.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.signUp => SignUpView(viewModel: SignUpViewModel()),
      AppRoutes.login => const LoginView(),
      AppRoutes.loginSuccess => const LoginSuccessView(),
      AppRoutes.explore => const MainShell(),
      _ => SignUpView(viewModel: SignUpViewModel()),
    };

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
