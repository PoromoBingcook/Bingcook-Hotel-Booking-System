import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StaffBottomNavigation extends StatelessWidget {
  const StaffBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
    (icon: Icons.assignment_outlined, label: 'Bookings'),
    (icon: Icons.calendar_today_outlined, label: 'Reservations'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.gray100)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == selectedIndex;
            final color = selected ? AppColors.primary : AppColors.gray400;
            return Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: item.label,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 26, color: color),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
