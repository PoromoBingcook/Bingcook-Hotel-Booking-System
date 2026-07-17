import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PropertyBookingCard extends StatelessWidget {
  const PropertyBookingCard({
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.canBook,
    required this.onDatesChanged,
    required this.onIncrementGuests,
    required this.onDecrementGuests,
    required this.onBookNow,
    super.key,
    this.unavailableMessage,
  });

  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final bool canBook;
  final ValueChanged<DateTimeRange> onDatesChanged;
  final VoidCallback onIncrementGuests;
  final VoidCallback onDecrementGuests;
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
              const SizedBox(width: 12),
              Expanded(
                child: _BookingDate(label: 'CHECK-OUT', date: checkOut),
              ),
              IconButton(
                key: const Key('property_edit_dates_button'),
                onPressed: () => _selectDates(context),
                tooltip: 'Change check-in and check-out dates',
                icon: const Icon(Icons.edit_calendar_outlined),
                color: AppColors.primaryDark,
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.gray200),
          Row(
            children: [
              const Icon(
                Icons.people_outline_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  guests == 1 ? '1 guest' : '$guests guests',
                  key: const Key('property_guests_label'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const Key('property_guests_decrement_button'),
                onPressed: guests > 1 ? onDecrementGuests : null,
                tooltip: 'Decrease guests',
                icon: const Icon(Icons.remove_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '$guests',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                key: const Key('property_guests_increment_button'),
                onPressed: onIncrementGuests,
                tooltip: 'Increase guests',
                icon: const Icon(Icons.add_rounded, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Future<void> _selectDates(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initialStart = checkIn.isBefore(today)
        ? today
        : DateUtils.dateOnly(checkIn);
    final initialEnd = checkOut.isAfter(initialStart)
        ? DateUtils.dateOnly(checkOut)
        : initialStart.add(const Duration(days: 1));
    final defaultLastDate = today.add(const Duration(days: 730));
    final selected = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: initialEnd.isAfter(defaultLastDate)
          ? initialEnd
          : defaultLastDate,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'Choose your stay',
      saveText: 'Update',
    );

    if (selected != null) {
      onDatesChanged(selected);
    }
  }
}

class _BookingDate extends StatelessWidget {
  const _BookingDate({required this.label, required this.date});

  final String label;
  final DateTime date;

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
        Text(
          _formatDate(date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
