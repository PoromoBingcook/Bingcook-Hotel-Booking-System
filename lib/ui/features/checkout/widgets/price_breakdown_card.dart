import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:flutter/material.dart';

class PriceBreakdownCard extends StatelessWidget {
  const PriceBreakdownCard({
    required this.rows,
    required this.total,
    super.key,
  });

  final List<PriceBreakdownRow> rows;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: const Color(0xFFE8F0FE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PriceRow(label: row.label, value: _money(row.amount)),
            ),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: 8),
          _PriceRow(label: 'Total', value: _money(total), emphasized: true),
        ],
      ),
    );
  }

  static String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasized ? AppColors.textPrimary : AppColors.textSecondary,
      fontFamily: emphasized ? 'Manrope' : null,
      fontSize: emphasized ? 18 : 13,
      fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: style.copyWith(
            color: emphasized ? AppColors.primaryDark : style.color,
          ),
        ),
      ],
    );
  }
}
