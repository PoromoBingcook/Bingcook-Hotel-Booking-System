import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentResultView extends StatelessWidget {
  const PaymentResultView({
    required this.checkout,
    required this.onBackToExplore,
    super.key,
  });

  final BookingCheckout checkout;
  final VoidCallback onBackToExplore;

  bool get _isPayOS => checkout.paymentMethod.toLowerCase() == 'payos';

  @override
  Widget build(BuildContext context) {
    final checkoutUrl = checkout.checkoutUrl;

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
                _PaymentResultHeader(onBack: onBackToExplore),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    children: [
                      Icon(
                        _isPayOS
                            ? Icons.qr_code_2_rounded
                            : Icons.check_circle_rounded,
                        color: AppColors.primaryDark,
                        size: 56,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isPayOS ? 'PayOS checkout ready' : 'Booking confirmed',
                        key: const Key('payment_result_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkout.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatusCard(checkout: checkout),
                      if (checkoutUrl != null) ...[
                        const SizedBox(height: 16),
                        _CopyValueCard(
                          title: 'Checkout URL',
                          value: checkoutUrl,
                          buttonLabel: 'Copy PayOS Link',
                        ),
                      ],
                      if (checkout.qrCode != null) ...[
                        const SizedBox(height: 16),
                        _CopyValueCard(
                          title: 'PayOS QR Payload',
                          value: checkout.qrCode!,
                          buttonLabel: 'Copy QR Payload',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentResultHeader extends StatelessWidget {
  const _PaymentResultHeader({required this.onBack});

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
            key: const Key('payment_result_back_button'),
            onPressed: onBack,
            tooltip: 'Back to Explore',
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.primaryDark,
          ),
          const Text(
            'BingCook',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.checkout});

  final BookingCheckout checkout;

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
        children: [
          _StatusRow(label: 'Booking', value: checkout.bookingStatus),
          const SizedBox(height: 10),
          _StatusRow(label: 'Payment', value: checkout.paymentStatus),
          const SizedBox(height: 10),
          _StatusRow(label: 'Amount', value: _money(checkout.amount)),
          if (checkout.transactionCode != null) ...[
            const SizedBox(height: 10),
            _StatusRow(label: 'Code', value: checkout.transactionCode!),
          ],
        ],
      ),
    );
  }

  static String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CopyValueCard extends StatelessWidget {
  const _CopyValueCard({
    required this.title,
    required this.value,
    required this.buttonLabel,
  });

  final String title;
  final String value;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8F0FE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title copied')));
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
