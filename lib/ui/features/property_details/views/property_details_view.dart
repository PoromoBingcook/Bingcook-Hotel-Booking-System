import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/utils/currency_formatter.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_amenities_grid.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_booking_card.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_guest_review.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_review_summary.dart';
import 'package:bingcook/ui/features/property_details/widgets/property_review_sheet.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({
    required this.data,
    required this.viewModel,
    required this.onBack,
    required this.onBookNow,
    required this.onChat,
    required this.onReviewSaved,
    required this.onStayChanged,

    required this.isSaved,
    required this.onSavedToggle,
    super.key,
  });

  final PropertyDetailsData data;
  final PropertyDetailsViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onBookNow;
  final VoidCallback onChat;
  final Future<void> Function() onReviewSaved;
  final VoidCallback onStayChanged;

  final bool isSaved;
  final VoidCallback onSavedToggle;

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
                          isFavorite: isSaved,
                          onBack: onBack,
                          onFavorite: onSavedToggle,
                        ),
                        Expanded(
                          child: ListView(
                            key: const Key('property_details_scroll_view'),
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                            children: [
                              Text(
                                '${formatVnd(data.pricePerNight)}/night',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
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
                                checkIn: viewModel.checkIn,
                                checkOut: viewModel.checkOut,
                                guests: viewModel.guests,
                                canBook: data.canBook,
                                unavailableMessage:
                                    'No available rooms for selected dates.',
                                onDatesChanged: (range) {
                                  viewModel.updateDates(range);
                                  onStayChanged();
                                },
                                onIncrementGuests: () {
                                  viewModel.incrementGuests();
                                  onStayChanged();
                                },
                                onDecrementGuests: () {
                                  viewModel.decrementGuests();
                                  onStayChanged();
                                },
                                onBookNow: onBookNow,
                              ),
                              const SizedBox(height: 24),
                              const _SectionTitle('Location'),
                              const SizedBox(height: 12),
                              _PropertyLocationMap(data: data),
                              const SizedBox(height: 24),
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
                                    ? 'Check-in time varies by room.'
                                    : data.checkInPolicy,
                              ),
                              const SizedBox(height: 10),
                              _PolicyTile(
                                icon: Icons.logout_rounded,
                                title: 'Check-out',
                                body: data.checkOutPolicy.isEmpty
                                    ? 'Check-out time varies by room.'
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
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                key: const Key('write_review_button'),
                                onPressed: viewModel.isLoadingReview
                                    ? null
                                    : () {
                                        viewModel.prepareNewReview();
                                        _openReviewSheet(context);
                                      },
                                icon: const Icon(Icons.rate_review_outlined),
                                label: Text(
                                  viewModel.isLoadingReview
                                      ? 'Loading your review...'
                                      : 'Write a review',
                                ),
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
                                    onEdit:
                                        viewModel.ownsReview(
                                          data.reviews[index].id,
                                        )
                                        ? () {
                                            if (viewModel.prepareEditReview(
                                              data.reviews[index].id,
                                            )) {
                                              _openReviewSheet(context);
                                            }
                                          }
                                        : null,
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

  Future<void> _openReviewSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PropertyReviewSheet(
        viewModel: viewModel,
        propertyId: data.id,
        onSaved: onReviewSaved,
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

class _PropertyLocationMap extends StatelessWidget {
  const _PropertyLocationMap({required this.data});

  final PropertyDetailsData data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasCoordinates) {
      return Container(
        key: const Key('property_location_unavailable'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.location_off_outlined, color: AppColors.textSecondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Map coordinates are not available for this property.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final point = LatLng(data.latitude!, data.longitude!);
    return Semantics(
      label: 'Map location for ${data.name}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          key: const Key('property_location_map'),
          height: 220,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: point, initialZoom: 15.5),
                children: [
                  // ponytail: public OSM tiles cover MVP traffic; switch both
                  // app maps to a hosted provider before scale.
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bingcook.bingcook',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryDark,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  color: Colors.white.withValues(alpha: 0.88),
                  child: const Text(
                    '(c) OpenStreetMap contributors',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
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
          const Expanded(
            child: Text(
              'Property Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
