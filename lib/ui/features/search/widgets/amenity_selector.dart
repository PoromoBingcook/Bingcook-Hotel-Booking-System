import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AmenitySelector extends StatelessWidget {
  const AmenitySelector({
    required this.amenities,
    required this.selectedAmenities,
    required this.onToggle,
    super.key,
  });

  final List<String> amenities;
  final Set<String> selectedAmenities;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final amenity in amenities)
          FilterChip(
            key: Key('amenity_$amenity'),
            label: Text(amenity),
            selected: selectedAmenities.contains(amenity),
            onSelected: (_) => onToggle(amenity),
            showCheckmark: true,
            checkmarkColor: Colors.white,
            selectedColor: AppColors.primaryDark,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selectedAmenities.contains(amenity)
                  ? AppColors.primaryDark
                  : AppColors.outline,
            ),
            labelStyle: TextStyle(
              color: selectedAmenities.contains(amenity)
                  ? Colors.white
                  : AppColors.slate700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}
