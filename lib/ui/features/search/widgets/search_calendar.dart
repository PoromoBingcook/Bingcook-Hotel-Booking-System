import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchCalendar extends StatelessWidget {
  const SearchCalendar({
    required this.checkIn,
    required this.checkOut,
    required this.onDateSelected,
    super.key,
  });

  final DateTime checkIn;
  final DateTime? checkOut;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _monthNames = [
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

  @override
  Widget build(BuildContext context) {
    final year = checkIn.year;
    final month = checkIn.month;
    final firstWeekday = DateTime(year, month).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateSummary(label: 'Check-in', date: checkIn),
              ),
              Container(width: 28, height: 1, color: AppColors.gray200),
              Expanded(
                child: _DateSummary(label: 'Check-out', date: checkOut),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${_monthNames[month - 1]} $year',
            style: const TextStyle(
              color: AppColors.slate900,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final weekday in _weekdays)
                Expanded(
                  child: Text(
                    weekday,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 38,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(year, month, day);
              final isStart = _isSameDay(date, checkIn);
              final isEnd = checkOut != null && _isSameDay(date, checkOut!);
              final isInRange =
                  checkOut != null &&
                  date.isAfter(checkIn) &&
                  date.isBefore(checkOut!);

              return _CalendarDay(
                day: day,
                monthName: _monthNames[month - 1],
                isStart: isStart,
                isEnd: isEnd,
                isInRange: isInRange,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }
    return '${_monthNames[date.month - 1]} ${date.day}';
  }
}

class _DateSummary extends StatelessWidget {
  const _DateSummary({required this.label, required this.date});

  final String label;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: label == 'Check-in'
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate500,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          SearchCalendar.formatDate(date),
          style: const TextStyle(
            color: AppColors.slate900,
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.monthName,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.onTap,
  });

  final int day;
  final String monthName;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEndpoint = isStart || isEnd;

    return Semantics(
      button: true,
      label: '$monthName $day',
      selected: isEndpoint || isInRange,
      child: InkWell(
        key: Key('calendar_day_$day'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isEndpoint
                ? AppColors.primaryDark
                : isInRange
                ? const Color(0xFFE8F1FF)
                : Colors.transparent,
            borderRadius: isEndpoint ? BorderRadius.circular(8) : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: isEndpoint
                  ? Colors.white
                  : isInRange
                  ? AppColors.primaryDark
                  : AppColors.slate800,
              fontSize: 12,
              fontWeight: isEndpoint ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
