import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:flutter/material.dart';

class PropertyReviewSummary extends StatelessWidget {
  const PropertyReviewSummary({
    required this.distribution,
    required this.rating,
    required this.reviewCount,
    super.key,
  });

  final List<RatingDistributionData> distribution;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review summary',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.textSecondary,
                size: 15,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (final item in distribution)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              child: Text(
                                '${item.stars}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: item.fraction,
                                  minHeight: 7,
                                  color: const Color(0xFFFBBC04),
                                  backgroundColor: AppColors.gray200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 42,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const _RatingStars(rating: 4),
                  const SizedBox(height: 4),
                  Text(
                    '$reviewCount reviews',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFFBBC04),
          size: 18,
        ),
      ),
    );
  }
}
