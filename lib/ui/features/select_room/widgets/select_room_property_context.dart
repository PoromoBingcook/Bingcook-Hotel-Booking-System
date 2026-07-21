import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class SelectRoomPropertyContext extends StatelessWidget {
  const SelectRoomPropertyContext({required this.data, super.key});

  final SelectRoomData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _PropertyImage(data: data),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.propertyName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 3,
                  runSpacing: 3,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      data.dateRange,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '•',
                        style: TextStyle(color: AppColors.gray400),
                      ),
                    ),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      '${data.guests} guests',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.data});

  final SelectRoomData data;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      imageUrl: data.propertyImageUrl,
      width: 56,
      height: 56,
      sourceWidth: 168,
      fallback: _FallbackImage(data),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage(this.data);

  final SelectRoomData data;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      data.propertyImageAsset,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
    );
  }
}
