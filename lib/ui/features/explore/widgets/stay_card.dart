import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:flutter/material.dart';

class StayCard extends StatelessWidget {
  const StayCard({required this.data, super.key, this.onTap});

  final StayCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: onTap == null ? null : 'Open ${data.name} details',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  data.imageAsset,
                  width: 128,
                  height: 128,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 128),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _Badge(
                            label: data.type.toUpperCase(),
                            background: const Color(0xFFDBEAFE),
                            foreground: const Color(0xFF2563EB),
                          ),
                          const _Badge(
                            label: 'AVAILABLE',
                            background: Color(0xFFDCFCE7),
                            foreground: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFFB7185),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              data.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.gray400,
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '★ ${data.rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data.reviewCount} reviews',
                            style: const TextStyle(
                              color: AppColors.gray400,
                              fontFamily: 'Manrope',
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              children: data.amenities
                                  .map((amenity) => _Amenity(label: amenity))
                                  .toList(),
                            ),
                          ),
                          Text(
                            '\$${data.price}/night',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontFamily: 'Manrope',
          fontSize: 10,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Amenity extends StatelessWidget {
  const _Amenity({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.gray500,
          fontFamily: 'Manrope',
          fontSize: 10,
        ),
      ),
    );
  }
}
