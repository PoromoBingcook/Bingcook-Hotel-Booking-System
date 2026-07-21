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
      PropertyAmenityType.selfCheckIn => Icons.key_rounded,
      PropertyAmenityType.airConditioning => Icons.ac_unit_rounded,
      PropertyAmenityType.breakfast => Icons.breakfast_dining_rounded,
      PropertyAmenityType.pets => Icons.pets_rounded,
      PropertyAmenityType.restaurant => Icons.restaurant_rounded,
      PropertyAmenityType.spa => Icons.spa_rounded,
      PropertyAmenityType.airportShuttle => Icons.airport_shuttle_rounded,
      PropertyAmenityType.laundry => Icons.local_laundry_service_rounded,
      PropertyAmenityType.bar => Icons.local_bar_rounded,
      PropertyAmenityType.roomService => Icons.room_service_rounded,
      PropertyAmenityType.beach => Icons.beach_access_rounded,
      PropertyAmenityType.kitchen => Icons.kitchen_rounded,
      PropertyAmenityType.television => Icons.tv_rounded,
      PropertyAmenityType.elevator => Icons.elevator_rounded,
      PropertyAmenityType.generic => Icons.check_circle_outline_rounded,
    };
  }
}
