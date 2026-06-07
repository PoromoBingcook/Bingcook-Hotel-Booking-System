import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    required this.methods,
    required this.selectedMethod,
    required this.onSelected,
    required this.onAddCard,
    super.key,
  });

  final List<PaymentMethodData> methods;
  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onSelected;
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < methods.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == methods.length - 1 ? 0 : 8,
            ),
            child: _PaymentMethodCard(
              method: methods[index],
              selected: methods[index].type == selectedMethod,
              onTap: () => onSelected(methods[index].type),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAddCard,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 16),
            label: const Text('Add a card'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodData method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: method.title,
      child: InkWell(
        key: Key('payment_method_${method.type.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 78,
          padding: EdgeInsets.all(selected ? 16 : 17),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.outline,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryDark.withValues(alpha: 0.10)
                      : const Color(0xFFEDEEEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  method.iconAsset,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      method.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                key: selected
                    ? Key('payment_method_${method.type.name}_selected')
                    : null,
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primaryDark : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
