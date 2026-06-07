import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardForm extends StatelessWidget {
  const AddCardForm({
    required this.cardholderController,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.onCardholderChanged,
    required this.onExpiryChanged,
    required this.saveForFuture,
    required this.onToggleSave,
    super.key,
  });

  final TextEditingController cardholderController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final ValueChanged<String> onCardholderChanged;
  final ValueChanged<String> onExpiryChanged;
  final bool saveForFuture;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardField(
            label: 'Cardholder Name',
            controller: cardholderController,
            hintText: 'John Doe',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.creditCardName],
            onChanged: onCardholderChanged,
          ),
          const SizedBox(height: 24),
          _CardField(
            label: 'Card Number',
            controller: cardNumberController,
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            suffixIcon: const Icon(Icons.contactless_rounded, size: 22),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _CardField(
                  label: 'Expiry Date',
                  controller: expiryController,
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  onChanged: onExpiryChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CardField(
                  label: 'CVV',
                  controller: cvvController,
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  suffixIcon: const Tooltip(
                    message: 'Three or four digits on your card',
                    child: Icon(Icons.info_outline_rounded, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save for future use',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Fast checkout on your next trip',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('save_card_switch'),
                value: saveForFuture,
                onChanged: (_) => onToggleSave(),
                activeTrackColor: AppColors.primaryDark,
                thumbColor: WidgetStateProperty.all(Colors.white),
              ),
              SizedBox(
                key: Key(
                  saveForFuture
                      ? 'save_card_switch_on'
                      : 'save_card_switch_off',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textInputAction,
    required this.autofillHints,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE1E3E4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final parts = <String>[];
    for (var index = 0; index < digits.length; index += 4) {
      parts.add(digits.substring(index, (index + 4).clamp(0, digits.length)));
    }
    final text = parts.join(' ');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final text = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
