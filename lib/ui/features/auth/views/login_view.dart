import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_button.dart';
import 'package:bingcook/ui/features/auth/view_models/login_view_model.dart';
import 'package:bingcook/ui/features/auth/widgets/login_text_field.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 80,
                      maxWidth: 448,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListenableBuilder(
                              listenable: widget.viewModel,
                              builder: (context, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _LoginHeader(),
                                    const SizedBox(height: 42),
                                    LoginTextField(
                                      fieldKey: const Key(
                                        'login_identity_field',
                                      ),
                                      controller: _emailController,
                                      label: 'Email',
                                      hint: 'email@example.com',
                                      iconAsset: AppAssets.email,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 20),
                                    LoginTextField(
                                      fieldKey: const Key(
                                        'login_password_field',
                                      ),
                                      controller: _passwordController,
                                      label: 'Password',
                                      hint: '........',
                                      iconAsset: AppAssets.password,
                                      obscureText:
                                          !widget.viewModel.isPasswordVisible,
                                      suffixIcon: IconButton(
                                        onPressed: widget
                                            .viewModel
                                            .togglePasswordVisibility,
                                        icon: Icon(
                                          widget.viewModel.isPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                        ),
                                        color: AppColors.slate400,
                                        tooltip:
                                            widget.viewModel.isPasswordVisible
                                            ? 'Hide password'
                                            : 'Show password',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: widget.viewModel.rememberMe,
                                            onChanged: (value) {
                                              widget.viewModel.setRememberMe(
                                                value ?? false,
                                              );
                                            },
                                            activeColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide.none,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: AppColors.slate500,
                                            fontFamily: 'Manrope',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontFamily: 'Manrope',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 28),
                                    AppButton(
                                      key: const Key('login_button'),
                                      label: widget.viewModel.isSubmitting
                                          ? 'Logging in...'
                                          : 'Login',
                                      height: 58,
                                      borderRadius: 8,
                                      fontWeight: FontWeight.w700,
                                      backgroundColor: AppColors.primary,
                                      shadowColor: AppColors.primary,
                                      onPressed: widget.viewModel.isSubmitting
                                          ? null
                                          : _submit,
                                    ),
                                    if (widget.viewModel.errorMessage !=
                                        null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.viewModel.errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFF43F5E),
                                          fontFamily: 'Manrope',
                                          fontSize: 14,
                                          height: 1.43,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 124),
                            AppButton(
                              label: 'Login with Google',
                              height: 58,
                              borderRadius: 8,
                              fontWeight: FontWeight.w700,
                              backgroundColor: const Color(0xFF42A5F5),
                              onPressed: () {},
                              trailing: Container(
                                width: 26,
                                height: 26,
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(AppAssets.google),
                              ),
                            ),
                            const SizedBox(height: 23),
                            Center(
                              child: TextButton(
                                key: const Key('open_sign_up_button'),
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(AppRoutes.signUp);
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: AppColors.slate500,
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: 'Sign up',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = await widget.viewModel.submit(
      identity: _emailController.text,
      password: _passwordController.text,
    );

    if (!isValid || !mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacementNamed(AppRoutes.loginSuccess);
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'B',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BingCook',
                  style: TextStyle(
                    color: AppColors.slate800,
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Book calm stays anywhere',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Welcome back',
          style: TextStyle(
            color: AppColors.slate900,
            fontFamily: 'Manrope',
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Login to manage reservations,\n'
          'messages, and booking notifications.',
          style: TextStyle(
            color: AppColors.slate500,
            fontFamily: 'Manrope',
            fontSize: 15,
            height: 1.63,
          ),
        ),
      ],
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -100,
            top: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x1A1A73E8), Color(0x001A73E8)],
                ),
              ),
              child: SizedBox(width: 400, height: 400),
            ),
          ),
          Positioned(
            right: -150,
            top: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x141A73E8),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 350, height: 350),
            ),
          ),
        ],
      ),
    );
  }
}

