import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchDestinationField extends StatelessWidget {
  const SearchDestinationField({
    required this.destination,
    required this.onClear,
    super.key,
  });

  final String destination;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: AppColors.slate500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              destination.isEmpty ? 'Add destination' : destination,
              style: TextStyle(
                color: destination.isEmpty
                    ? AppColors.gray400
                    : AppColors.slate800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (destination.isNotEmpty)
            IconButton(
              key: const Key('destination_clear_button'),
              onPressed: onClear,
              tooltip: 'Clear destination',
              icon: const Icon(Icons.cancel_outlined, size: 18),
              color: AppColors.slate500,
            ),
        ],
      ),
    );
  }
}
