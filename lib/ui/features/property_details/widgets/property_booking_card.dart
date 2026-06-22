import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PropertyBookingCard extends StatelessWidget {
  const PropertyBookingCard({
    required this.checkIn,
    required this.checkOut,
    required this.canBook,
    required this.onBookNow,
    super.key,
    this.unavailableMessage,
  });

  final String checkIn;
  final String checkOut;
  final bool canBook;
  final VoidCallback onBookNow;
  final String? unavailableMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BookingDate(label: 'CHECK-IN', date: checkIn),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BookingDate(label: 'CHECK-OUT', date: checkOut),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              key: const Key('property_book_now_button'),
              onPressed: canBook ? onBookNow : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                disabledBackgroundColor: AppColors.gray400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Book Now'),
            ),
          ),
          if (!canBook && unavailableMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    unavailableMessage!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingDate extends StatelessWidget {
  const _BookingDate({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            height: 1.6,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primaryDark,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
