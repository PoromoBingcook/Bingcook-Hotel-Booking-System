import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_amenities_grid.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_booking_card.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_guest_review.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_review_summary.dart';
import 'package:flutter/material.dart';

class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({
    required this.data,
    required this.viewModel,
    required this.onBack,
    required this.onBookNow,
    super.key,
  });

  final PropertyDetailsData data;
  final PropertyDetailsViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            color: AppColors.background,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PropertyHeader(
                      isFavorite: viewModel.isFavorite,
                      onBack: onBack,
                      onFavorite: viewModel.toggleFavorite,
                    ),
                    Expanded(
                      child: ListView(
                        key: const Key('property_details_scroll_view'),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _TypeBadge(label: data.type),
                              Text(
                                '\$${data.pricePerNight}/night',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.name,
                            key: const Key('property_details_title'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                              fontSize: 23,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  data.location,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFBBC04),
                                size: 16,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                data.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${data.reviewCount} reviews)',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: _PropertyImage(data: data),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PropertyBookingCard(
                            checkIn: data.checkIn,
                            checkOut: data.checkOut,
                            onBookNow: onBookNow,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data.description.isEmpty
                                  ? 'A comfortable stay with convenient access to nearby attractions.'
                                  : data.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Amenities'),
                          const SizedBox(height: 14),
                          PropertyAmenitiesGrid(amenities: data.amenities),
                          const SizedBox(height: 24),
                          PropertyReviewSummary(
                            distribution: data.ratingDistribution,
                            rating: data.summaryRating,
                            reviewCount: data.summaryReviewCount,
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('Guest Reviews'),
                          const SizedBox(height: 16),
                          for (
                            var index = 0;
                            index < data.reviews.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == data.reviews.length - 1
                                    ? 0
                                    : 24,
                              ),
                              child: PropertyGuestReview(
                                review: data.reviews[index],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontFamily: 'Manrope',
          fontSize: 11,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.data});

  final PropertyDetailsData data;

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _FallbackImage(data),
      );
    }

    return _FallbackImage(data);
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage(this.data);

  final PropertyDetailsData data;

  @override
  Widget build(BuildContext context) {
    return Image.asset(data.imageAsset, fit: BoxFit.cover);
  }
}

class _PropertyHeader extends StatelessWidget {
  const _PropertyHeader({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            key: const Key('property_back_button'),
            onPressed: onBack,
            tooltip: 'Back to Explore',
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primaryDark,
          ),
          const Text(
            'Property Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            key: const Key('property_favorite_button'),
            onPressed: onFavorite,
            tooltip: isFavorite ? 'Remove from saved' : 'Save property',
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            color: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'Manrope',
        fontSize: 19,
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
