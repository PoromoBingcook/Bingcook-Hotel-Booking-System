import 'package:bingcook/app/dependencies/app_dependencies.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/features/auth/view_models/login_view_model.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/views/login_success_view.dart';
import 'package:bingcook/ui/features/auth/views/login_view.dart';
import 'package:bingcook/ui/features/auth/views/sign_up_view.dart';
import 'package:bingcook/ui/features/navigation/views/main_shell.dart';
import 'package:bingcook/ui/features/staff/views/staff_portal_view.dart';
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
          AppRoutes.staffPortal => _buildStaffPortal(context),
          AppRoutes.explore => _buildAuthenticatedHome(context),
          _ => LoginView(
            viewModel: LoginViewModel(
              authRepository: _dependencies.authRepository,
            ),
          ),
        };
      },
    );
  }

  Widget _buildAuthenticatedHome(BuildContext context) {
    void logout() {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

    final role = _dependencies.authRepository.currentSession?.user.role;
    if (usesStaffPortal(role)) {
      return _buildStaffPortal(context);
    }

    return MainShell(
      authRepository: _dependencies.authRepository,
      productRepository: _dependencies.productRepository,
      bookingRepository: _dependencies.bookingRepository,
      chatRepository: _dependencies.chatRepository,
      chatRealtimeService: _dependencies.chatRealtimeService,
      onLogoutCompleted: logout,
    );
  }

  Widget _buildStaffPortal(BuildContext context) {
    return StaffPortalView(
      authRepository: _dependencies.authRepository,
      chatRepository: _dependencies.chatRepository,
      onLoggedOut: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      },
    );
  }
}

bool usesStaffPortal(String? role) {
  final normalized = role?.trim().toLowerCase();
  return normalized == 'host' || normalized == 'admin' || normalized == 'staff';
}
