import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GuestCounterCard extends StatelessWidget {
  const GuestCounterCard({
    required this.adults,
    required this.children,
    required this.onIncrementAdults,
    required this.onDecrementAdults,
    required this.onIncrementChildren,
    required this.onDecrementChildren,
    super.key,
  });

  final int adults;
  final int children;
  final VoidCallback onIncrementAdults;
  final VoidCallback onDecrementAdults;
  final VoidCallback onIncrementChildren;
  final VoidCallback onDecrementChildren;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _GuestRow(
            id: 'adults',
            title: 'Adults',
            subtitle: 'Ages 13 or above',
            count: adults,
            canDecrement: adults > 1,
            onIncrement: onIncrementAdults,
            onDecrement: onDecrementAdults,
          ),
          const Divider(height: 1, color: AppColors.gray200),
          _GuestRow(
            id: 'children',
            title: 'Children',
            subtitle: 'Ages 2-12',
            count: children,
            canDecrement: children > 0,
            onIncrement: onIncrementChildren,
            onDecrement: onDecrementChildren,
          ),
        ],
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String id;
  final String title;
  final String subtitle;
  final int count;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          _CounterButton(
            key: Key('${id}_decrement_button'),
            icon: Icons.remove,
            tooltip: 'Decrease $title',
            onPressed: canDecrement ? onDecrement : null,
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$count',
              key: Key('${id}_count_$count'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CounterButton(
            key: Key('${id}_increment_button'),
            icon: Icons.add,
            tooltip: 'Increase $title',
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      style: IconButton.styleFrom(
        side: BorderSide(
          color: onPressed == null ? AppColors.gray200 : AppColors.outline,
        ),
      ),
      icon: Icon(icon, size: 18),
      color: AppColors.slate700,
      disabledColor: AppColors.gray200,
    );
  }
}
