import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: Icons.search_rounded, label: 'Explore'),
    (icon: Icons.favorite_border_rounded, label: 'Saved'),
    (icon: Icons.confirmation_number_outlined, label: 'Bookings'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
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
            final selected = selectedIndex == index;
            final color = selected ? AppColors.primary : AppColors.gray400;

            return Expanded(
              child: InkWell(
                key: Key('bottom_nav_$index'),
                onTap: () => onSelected(index),
                child: Semantics(
                  selected: selected,
                  label: item.label,
                  button: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 28, color: color),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          height: 1.5,
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
