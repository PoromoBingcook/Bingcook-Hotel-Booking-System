import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/features/auth/view_models/login_view_model.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/login_success_view.dart';
import 'package:bingcook/ui/features/auth/views/login_view.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter({required AppDependencies dependencies})
    : _dependencies = dependencies;

  final AppDependencies _dependencies;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return switch (settings.name) {
          AppRoutes.signUp => SignUpView(
            viewModel: SignUpViewModel(
              authRepository: _dependencies.authRepository,
            ),
          ),
          AppRoutes.login => LoginView(
            viewModel: LoginViewModel(
              authRepository: _dependencies.authRepository,
            ),
          ),
          AppRoutes.loginSuccess => const LoginSuccessView(),
          AppRoutes.explore => MainShell(
            authRepository: _dependencies.authRepository,
            productRepository: _dependencies.productRepository,
            bookingRepository: _dependencies.bookingRepository,
            onLogoutCompleted: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          ),
          _ => SignUpView(
            viewModel: SignUpViewModel(
              authRepository: _dependencies.authRepository,
            ),
          ),
        };
      },
    );
  }
}
