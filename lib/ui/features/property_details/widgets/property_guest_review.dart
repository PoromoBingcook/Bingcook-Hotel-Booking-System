import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:flutter/material.dart';

class PropertyGuestReview extends StatelessWidget {
  const PropertyGuestReview({required this.review, this.onEdit, super.key});

  final GuestReviewData review;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.gray200,
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.gray500,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.author,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFBBC04),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.timeAgo,
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
            if (onEdit != null)
              TextButton.icon(
                key: Key('edit_review_${review.id}'),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.comment,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
