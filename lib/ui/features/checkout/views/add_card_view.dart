import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/checkout/view_models/add_card_view_model.dart';
import 'package:bingcook/ui/features/checkout/widgets/add_card_footer.dart';
import 'package:bingcook/ui/features/checkout/widgets/add_card_form.dart';
import 'package:bingcook/ui/features/checkout/widgets/payment_card_preview.dart';
import 'package:bingcook/ui/features/checkout/widgets/payment_trust_badges.dart';
import 'package:flutter/material.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({
    required this.viewModel,
    required this.onBack,
    required this.onSave,
    super.key,
  });

  final AddCardViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  late final TextEditingController _cardholderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  String _cardholderName = 'John Doe';
  String _expiryDate = '';

  @override
  void initState() {
    super.initState();
    _cardholderController = TextEditingController(text: _cardholderName);
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
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
                _AddCardHeader(onBack: widget.onBack),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      PaymentCardPreview(
                        cardholderName: _cardholderName,
                        expiryDate: _expiryDate,
                      ),
                      const SizedBox(height: 32),
                      ListenableBuilder(
                        listenable: widget.viewModel,
                        builder: (context, _) {
                          return AddCardForm(
                            cardholderController: _cardholderController,
                            cardNumberController: _cardNumberController,
                            expiryController: _expiryController,
                            cvvController: _cvvController,
                            onCardholderChanged: (value) =>
                                setState(() => _cardholderName = value),
                            onExpiryChanged: (value) =>
                                setState(() => _expiryDate = value),
                            saveForFuture: widget.viewModel.saveForFuture,
                            onToggleSave: widget.viewModel.toggleSaveForFuture,
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      const PaymentTrustBadges(),
                    ],
                  ),
                ),
                AddCardFooter(onSave: widget.onSave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCardHeader extends StatelessWidget {
  const _AddCardHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            key: const Key('add_card_back_button'),
            onPressed: onBack,
            tooltip: 'Back to Checkout',
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            color: AppColors.textSecondary,
          ),
          const Text(
            'Add Card Details',
            key: Key('add_card_title'),
            style: TextStyle(
              color: AppColors.primaryDark,
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFEDEEEF),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
