import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/utils/currency_formatter.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_amenities_grid.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_booking_card.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_guest_review.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_review_summary.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:flutter/material.dart';

class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({
    required this.data,
    required this.viewModel,
    required this.onBack,
    required this.onBookNow,
    required this.onChat,
    super.key,
  });

  final PropertyDetailsData data;
  final PropertyDetailsViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onBookNow;
  final VoidCallback onChat;

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
                return Stack(
                  children: [
                    Column(
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
                                    '${formatVnd(data.pricePerNight)}/night',
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
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _InfoChip(label: data.type),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    label: data.canBook
                                        ? 'Rooms available'
                                        : 'Sold out',
                                    positive: data.canBook,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
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
                                canBook: data.canBook,
                                unavailableMessage:
                                    'No available rooms for selected dates.',
                                onBookNow: onBookNow,
                              ),
                              const SizedBox(height: 20),
                              if (data.description.trim().isNotEmpty) ...[
                                const _SectionTitle('Overview'),
                                const SizedBox(height: 10),
                                Text(
                                  data.description,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.55,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              const _SectionTitle('Amenities'),
                              const SizedBox(height: 14),
                              PropertyAmenitiesGrid(amenities: data.amenities),
                              const SizedBox(height: 24),
                              const _SectionTitle('Policies'),
                              const SizedBox(height: 12),
                              _PolicyTile(
                                icon: Icons.login_rounded,
                                title: 'Check-in',
                                body: data.checkInPolicy.isEmpty
                                    ? data.checkIn
                                    : data.checkInPolicy,
                              ),
                              const SizedBox(height: 10),
                              _PolicyTile(
                                icon: Icons.logout_rounded,
                                title: 'Check-out',
                                body: data.checkOutPolicy.isEmpty
                                    ? data.checkOut
                                    : data.checkOutPolicy,
                              ),
                              const SizedBox(height: 10),
                              _PolicyTile(
                                icon: Icons.event_busy_outlined,
                                title: 'Cancellation',
                                body: data.cancellationPolicy.isEmpty
                                    ? 'Free cancellation policy depends on room type.'
                                    : data.cancellationPolicy,
                              ),
                              const SizedBox(height: 24),
                              const _SectionTitle('Available Rooms'),
                              const SizedBox(height: 12),
                              if (data.rooms.isEmpty)
                                const _EmptyRoomsMessage()
                              else
                                for (
                                  var index = 0;
                                  index < data.rooms.length;
                                  index++
                                )
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == data.rooms.length - 1
                                          ? 0
                                          : 10,
                                    ),
                                    child: _RoomPreview(
                                      room: data.rooms[index],
                                    ),
                                  ),
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
                    ),
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: FloatingActionButton(
                        key: const Key('property_chat_button'),
                        onPressed: onChat,
                        tooltip: 'Chat with property',
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.chat_bubble_outline_rounded),
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
    final imageUrl = data.imageUrls.isNotEmpty
        ? data.imageUrls.first
        : data.imageUrl;
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.positive});

  final String label;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final positive = this.positive;
    final color = positive == null
        ? AppColors.primaryDark
        : positive
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomPreview extends StatelessWidget {
  const _RoomPreview({required this.room});

  final RoomOptionData room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              room.imageAsset,
              width: 72,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Up to ${room.maxGuests} guests',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${formatVnd(room.pricePerNight)}/night',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoomsMessage extends StatelessWidget {
  const _EmptyRoomsMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'No rooms available for selected dates.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
