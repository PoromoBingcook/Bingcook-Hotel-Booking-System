import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:bingcook/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:bingcook/ui/features/checkout/widgets/checkout_footer.dart';
import 'package:bingcook/ui/features/checkout/widgets/checkout_summary_card.dart';
import 'package:bingcook/ui/features/checkout/widgets/guest_information_section.dart';
import 'package:bingcook/ui/features/checkout/widgets/payment_method_section.dart';
import 'package:bingcook/ui/features/checkout/widgets/price_breakdown_card.dart';
import 'package:flutter/material.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({
    required this.data,
    required this.viewModel,
    required this.onBack,
    required this.onConfirmed,
    super.key,
  });

  final CheckoutData data;
  final CheckoutViewModel viewModel;
  final VoidCallback onBack;
  final ValueChanged<BookingCheckout> onConfirmed;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.fullName);
    _emailController = TextEditingController(text: widget.data.email);
    _phoneController = TextEditingController(text: widget.data.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 448),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CheckoutHeader(onBack: widget.onBack),
                Expanded(
                  child: ListenableBuilder(
                    listenable: widget.viewModel,
                    builder: (context, _) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          CheckoutSummaryCard(data: widget.data),
                          const SizedBox(height: 24),
                          GuestInformationSection(
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                          ),
                          const SizedBox(height: 24),
                          PaymentMethodSection(
                            methods: widget.data.paymentMethods,
                            selectedMethod:
                                widget.viewModel.selectedPaymentMethod,
                            onSelected: widget.viewModel.selectPaymentMethod,
                            onAddCard: () {},
                          ),
                          if (widget.viewModel.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.viewModel.errorMessage!,
                              key: const Key('checkout_error_message'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          PriceBreakdownCard(
                            rows: widget.data.priceRows,
                            total: widget.data.total,
                          ),
                          const SizedBox(height: 22),
                          const _TermsText(),
                        ],
                      );
                    },
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    return CheckoutFooter(
                      isLoading: widget.viewModel.isSubmitting,
                      onConfirm: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final success = await widget.viewModel.submit(
      data: widget.data,
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: _phoneController.text,
    );
    final checkout = widget.viewModel.checkout;
    if (success && checkout != null && mounted) {
      widget.onConfirmed(checkout);
    }
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Color(0xFFE8F0FE))),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('checkout_back_button'),
            onPressed: onBack,
            tooltip: 'Back to Select Room',
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            color: AppColors.primaryDark,
          ),
          const Text(
            'BingCook',
            key: Key('checkout_title'),
            style: TextStyle(
              color: AppColors.primaryDark,
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: null,
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle_outlined, size: 21),
            color: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        text: 'By clicking "Confirm Booking", you agree to our\n',
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: AppColors.primaryDark,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: ' and Cancellation Policy.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        height: 1.45,
      ),
    );
  }
}
