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
import 'package:provider/provider.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        final dependencies = context.read<AppDependencies>();
        return switch (settings.name) {
          AppRoutes.signUp => ChangeNotifierProvider(
            create: (_) =>
                SignUpViewModel(authRepository: dependencies.authRepository),
            child: const SignUpView(),
          ),
          AppRoutes.login => ChangeNotifierProvider(
            create: (_) =>
                LoginViewModel(authRepository: dependencies.authRepository),
            child: const LoginView(),
          ),
          AppRoutes.loginSuccess => const LoginSuccessView(),
          AppRoutes.staffPortal => _buildStaffPortal(context, dependencies),
          AppRoutes.explore => _buildAuthenticatedHome(context, dependencies),
          _ => ChangeNotifierProvider(
            create: (_) =>
                LoginViewModel(authRepository: dependencies.authRepository),
            child: const LoginView(),
          ),
        };
      },
    );
  }

  Widget _buildAuthenticatedHome(
    BuildContext context,
    AppDependencies dependencies,
  ) {
    void logout() {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

    final role = dependencies.authRepository.currentSession?.user.role;
    if (usesStaffPortal(role)) {
      return _buildStaffPortal(context, dependencies);
    }

    return MainShell(
      authRepository: dependencies.authRepository,
      productRepository: dependencies.productRepository,
      bookingRepository: dependencies.bookingRepository,
      chatRepository: dependencies.chatRepository,
      notificationRepository: dependencies.notificationRepository,
      savedPropertyRepository: dependencies.savedPropertyRepository,
      reviewRepository: dependencies.reviewRepository,
      chatRealtimeService: dependencies.chatRealtimeService,
      onLogoutCompleted: logout,
    );
  }

  Widget _buildStaffPortal(BuildContext context, AppDependencies dependencies) {
    return StaffPortalView(
      authRepository: dependencies.authRepository,
      chatRepository: dependencies.chatRepository,
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
