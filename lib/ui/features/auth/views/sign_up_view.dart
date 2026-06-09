import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_button.dart';
import 'package:bingcook/ui/core/widgets/atmospheric_background.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/widgets/auth_text_field.dart';
import 'package:bingcook/ui/features/auth/widgets/brand_header.dart';
import 'package:bingcook/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({required this.viewModel, super.key});

  final SignUpViewModel viewModel;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AtmosphericBackground(
        topBlobOpacity: 0.03,
        bottomBlobOpacity: 0.05,
        child: SafeArea(
          child: Column(
            children: [
              const BrandHeader(),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    final errors = widget.viewModel.errors;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 29, 20, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 448),
                          child: Column(
                            children: [
                              Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join us to start your adventure.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              AuthTextField(
                                fieldKey: const Key('full_name_field'),
                                iconKey: const Key('full_name_icon'),
                                controller: _fullNameController,
                                label: 'Full Name',
                                hint: 'John Doe',
                                iconAsset: AppAssets.name,
                                errorText: errors.fullName,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                fieldKey: const Key('email_field'),
                                iconKey: const Key('email_icon'),
                                controller: _emailController,
                                label: 'Email address',
                                hint: 'email@example.com',
                                iconAsset: AppAssets.email,
                                errorText: errors.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                fieldKey: const Key('phone_field'),
                                iconKey: const Key('phone_icon'),
                                controller: _phoneController,
                                label: 'Phone number',
                                hint: '+1 (555) 000-0000',
                                iconAsset: AppAssets.phone,
                                errorText: errors.phone,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+()\-\s]'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                fieldKey: const Key('password_field'),
                                iconKey: const Key('password_icon'),
                                controller: _passwordController,
                                label: 'Password',
                                hint: '••••••••',
                                iconAsset: AppAssets.password,
                                errorText: errors.password,
                                obscureText:
                                    !widget.viewModel.isPasswordVisible,
                                suffixIcon: IconButton(
                                  onPressed:
                                      widget.viewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    widget.viewModel.isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  color: AppColors.textSecondary,
                                  tooltip: widget.viewModel.isPasswordVisible
                                      ? 'Hide password'
                                      : 'Show password',
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                label: widget.viewModel.isSubmitting
                                    ? 'Signing up...'
                                    : 'Sign Up',
                                backgroundColor: AppColors.primary,
                                onPressed: widget.viewModel.isSubmitting
                                    ? null
                                    : _submit,
                              ),
                              if (widget.viewModel.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  widget.viewModel.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFF43F5E),
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    height: 1.43,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              AppButton(
                                label: 'Login with Google',
                                backgroundColor: AppColors.secondary,
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
                              const SizedBox(height: 40),
                              TextButton(
                                key: const Key('open_login_button'),
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(AppRoutes.login);
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Already have an account? ',
                                      ),
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = await widget.viewModel.submit(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (isValid) {
      if (!mounted) {
        return;
      }
      FocusScope.of(context).unfocus();
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginSuccess);
    }
  }
}
