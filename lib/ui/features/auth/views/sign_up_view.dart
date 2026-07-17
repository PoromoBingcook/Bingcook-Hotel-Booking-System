import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_button.dart';
import 'package:bingcook/ui/core/widgets/atmospheric_background.dart';
import 'package:bingcook/ui/features/auth/view_models/sign_up_view_model.dart';
import 'package:bingcook/ui/features/auth/widgets/auth_text_field.dart';
import 'package:bingcook/ui/features/auth/widgets/brand_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(
      () => _validateOnBlur(_fullNameFocusNode, SignUpField.fullName),
    );
    _emailFocusNode.addListener(
      () => _validateOnBlur(_emailFocusNode, SignUpField.email),
    );
    _phoneFocusNode.addListener(
      () => _validateOnBlur(_phoneFocusNode, SignUpField.phone),
    );
    _passwordFocusNode.addListener(
      () => _validateOnBlur(_passwordFocusNode, SignUpField.password),
    );
    _confirmPasswordFocusNode.addListener(
      () => _validateOnBlur(
        _confirmPasswordFocusNode,
        SignUpField.confirmPassword,
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                child: Consumer<SignUpViewModel>(
                  builder: (context, viewModel, _) {
                    final errors = viewModel.errors;
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
                                focusNode: _fullNameFocusNode,
                                onTapOutside: () =>
                                    _validateField(SignUpField.fullName),
                                onChanged: (value) =>
                                    viewModel.updateInput(fullName: value),
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
                                focusNode: _emailFocusNode,
                                onTapOutside: () =>
                                    _validateField(SignUpField.email),
                                onChanged: (value) =>
                                    viewModel.updateInput(email: value),
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
                                focusNode: _phoneFocusNode,
                                onTapOutside: () =>
                                    _validateField(SignUpField.phone),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+()\-\s]'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    viewModel.updateInput(phone: value),
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                fieldKey: const Key('password_field'),
                                iconKey: const Key('password_icon'),
                                controller: _passwordController,
                                label: 'Password',
                                hint: '********',
                                iconAsset: AppAssets.password,
                                errorText: errors.password,
                                obscureText: !viewModel.isPasswordVisible,
                                focusNode: _passwordFocusNode,
                                onTapOutside: () =>
                                    _validateField(SignUpField.password),
                                onChanged: (value) =>
                                    viewModel.updateInput(password: value),
                                suffixIcon: IconButton(
                                  onPressed: viewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    viewModel.isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  color: AppColors.textSecondary,
                                  tooltip: viewModel.isPasswordVisible
                                      ? 'Hide password'
                                      : 'Show password',
                                ),
                              ),
                              const SizedBox(height: 16),
                              AuthTextField(
                                fieldKey: const Key('confirm_password_field'),
                                iconKey: const Key('confirm_password_icon'),
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                hint: '********',
                                iconAsset: AppAssets.password,
                                errorText: errors.confirmPassword,
                                obscureText: !viewModel.isPasswordVisible,
                                focusNode: _confirmPasswordFocusNode,
                                onTapOutside: () =>
                                    _validateField(SignUpField.confirmPassword),
                                onChanged: (value) => viewModel.updateInput(
                                  confirmPassword: value,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: viewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    viewModel.isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  color: AppColors.textSecondary,
                                  tooltip: viewModel.isPasswordVisible
                                      ? 'Hide password'
                                      : 'Show password',
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                label: viewModel.isSubmitting
                                    ? 'Signing up...'
                                    : 'Sign Up',
                                backgroundColor: AppColors.primary,
                                onPressed: viewModel.isSubmitting
                                    ? null
                                    : _submit,
                              ),
                              if (viewModel.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  viewModel.errorMessage!,
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

  void _validateOnBlur(FocusNode focusNode, SignUpField field) {
    if (!focusNode.hasFocus) {
      _validateField(field);
    }
  }

  void _validateField(SignUpField field) {
    context.read<SignUpViewModel>().validateField(field);
  }

  Future<void> _submit() async {
    final viewModel = context.read<SignUpViewModel>();
    final isValid = await viewModel.submit(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
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
