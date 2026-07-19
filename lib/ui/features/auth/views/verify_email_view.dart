import 'package:bingcook/app/routes/app_routes.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_button.dart';
import 'package:bingcook/ui/features/auth/view_models/verify_email_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({required this.email, super.key});

  final String email;

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  static const _otpLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _VerifyEmailHeader(
              onBack: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text:
                                    'We have sent a 6-digit verification code to your email\n',
                                children: [
                                  TextSpan(
                                    text: widget.email,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              key: const Key('verify_email_message'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Inter',
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _OtpInputRow(
                              controllers: _controllers,
                              focusNodes: _focusNodes,
                              onChanged: _updateOtp,
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Didn't receive the code?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                                TextButton(
                                  key: const Key('resend_otp_button'),
                                  onPressed: _resendOtp,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Resend',
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'Verify',
                              backgroundColor: AppColors.primary,
                              borderRadius: 5,
                              height: 38,
                              fontWeight: FontWeight.w700,
                              onPressed: _verifyOtp,
                            ),
                            const Spacer(),
                            Consumer<VerifyEmailViewModel>(
                              builder: (context, viewModel, _) {
                                final message = viewModel.message;
                                if (message == null) {
                                  return const SizedBox(height: 36);
                                }
                                return _OtpStatusToast(
                                  key: const Key('otp_status_message'),
                                  message: message,
                                );
                              },
                            ),
                            const SizedBox(height: 36),
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
    );
  }

  void _updateOtp() {
    context.read<VerifyEmailViewModel>().updateOtp(
      _controllers.map((controller) => controller.text).join(),
    );
  }

  Future<void> _resendOtp() async {
    await context.read<VerifyEmailViewModel>().resend(email: widget.email);
  }

  Future<void> _verifyOtp() async {
    final verified = await context.read<VerifyEmailViewModel>().verify(
      email: widget.email,
    );
    if (!verified) {
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginSuccess);
    });
  }
}

class _VerifyEmailHeader extends StatelessWidget {
  const _VerifyEmailHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              key: const Key('verify_email_back_button'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: AppColors.primary,
              tooltip: 'Back',
            ),
          ),
          const Text(
            'Verify Email',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Manrope',
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(controllers.length, (index) {
        return SizedBox(
          width: 40,
          height: 40,
          child: TextField(
            key: Key('otp_digit_$index'),
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: index == controllers.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < focusNodes.length - 1) {
                focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
              onChanged();
            },
          ),
        );
      }),
    );
  }
}

class _OtpStatusToast extends StatelessWidget {
  const _OtpStatusToast({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E3E6),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: 212,
        height: 36,
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
