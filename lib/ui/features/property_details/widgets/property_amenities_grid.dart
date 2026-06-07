import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:flutter/material.dart';

class PropertyAmenitiesGrid extends StatelessWidget {
  const PropertyAmenitiesGrid({required this.amenities, super.key});

  final List<PropertyAmenityData> amenities;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 60,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _iconFor(amenity.type),
                color: AppColors.primaryDark,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  amenity.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconFor(PropertyAmenityType type) {
    return switch (type) {
      PropertyAmenityType.wifi => Icons.wifi_rounded,
      PropertyAmenityType.pool => Icons.pool_rounded,
      PropertyAmenityType.gym => Icons.fitness_center_rounded,
      PropertyAmenityType.parking => Icons.local_parking_rounded,
    };
  }
}
