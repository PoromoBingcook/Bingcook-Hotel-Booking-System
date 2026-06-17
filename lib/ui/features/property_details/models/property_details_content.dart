import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';

abstract final class PropertyDetailsContent {
  static const oceanPearl = PropertyDetailsData(
    imageAsset: AppAssets.propertyDetails,
    imageUrl: null,
    name: 'Ocean Pearl Hotel',
    type: 'Hotel',
    description: 'Beachfront hotel near My Khe Beach.',
    location: 'Da Nang - Vo Nguyen Giap',
    rating: 4.8,
    reviewCount: 26,
    pricePerNight: 68,
    checkIn: 'Oct 24, 2023',
    checkOut: 'Oct 28, 2023',
    amenities: [
      PropertyAmenityData(type: PropertyAmenityType.wifi, label: 'Free Wifi'),
      PropertyAmenityData(
        type: PropertyAmenityType.pool,
        label: 'Infinity Pool',
      ),
      PropertyAmenityData(type: PropertyAmenityType.gym, label: 'Gym Facility'),
      PropertyAmenityData(
        type: PropertyAmenityType.parking,
        label: 'Private Parking',
      ),
    ],
    ratingDistribution: _dummyRatingDistribution,
    summaryRating: 4.4,
    summaryReviewCount: 766,
    reviews: _dummyReviews,
  );

  static PropertyDetailsData fromStay(StayCardData stay) {
    final amenities = stay.amenities.isEmpty
        ? _fallbackAmenities
        : stay.amenities
              .map(
                (amenity) => PropertyAmenityData(
                  type: _amenityTypeFor(amenity),
                  label: amenity,
                ),
              )
              .toList(growable: false);

    return PropertyDetailsData(
      imageAsset: stay.imageAsset,
      imageUrl: stay.imageUrl,
      name: stay.name,
      type: stay.type,
      description: stay.description,
      location: _formatLocation(stay),
      rating: stay.rating,
      reviewCount: stay.reviewCount,
      pricePerNight: stay.price,
      checkIn: 'Oct 24, 2023',
      checkOut: 'Oct 28, 2023',
      amenities: amenities,
      ratingDistribution: _dummyRatingDistribution,
      summaryRating: stay.rating == 0 ? 4.4 : stay.rating,
      summaryReviewCount: stay.reviewCount == 0 ? 766 : stay.reviewCount,
      reviews: _dummyReviews,
    );
  }

  static String _formatLocation(StayCardData stay) {
    if (stay.city.isEmpty || stay.address.isEmpty) {
      return stay.location;
    }
    return '${stay.city} - ${stay.address}';
  }

  static PropertyAmenityType _amenityTypeFor(String amenity) {
    final normalized = amenity.toLowerCase();
    if (normalized.contains('pool')) {
      return PropertyAmenityType.pool;
    }
    if (normalized.contains('gym') || normalized.contains('fitness')) {
      return PropertyAmenityType.gym;
    }
    if (normalized.contains('park')) {
      return PropertyAmenityType.parking;
    }
    return PropertyAmenityType.wifi;
  }

  static const _fallbackAmenities = [
    PropertyAmenityData(type: PropertyAmenityType.wifi, label: 'Free Wifi'),
    PropertyAmenityData(type: PropertyAmenityType.pool, label: 'Pool'),
    PropertyAmenityData(type: PropertyAmenityType.gym, label: 'Gym Facility'),
    PropertyAmenityData(
      type: PropertyAmenityType.parking,
      label: 'Private Parking',
    ),
  ];

  static const _dummyRatingDistribution = [
    RatingDistributionData(stars: 5, fraction: 0.85),
    RatingDistributionData(stars: 4, fraction: 0.15),
    RatingDistributionData(stars: 3, fraction: 0.04),
    RatingDistributionData(stars: 2, fraction: 0.02),
    RatingDistributionData(stars: 1, fraction: 0.20),
  ];

  static const _dummyReviews = [
    GuestReviewData(
      author: 'Alex Thompson',
      rating: 5,
      timeAgo: '2 months ago',
      comment:
          'The high-speed fiber internet was a game-changer for my remote '
          'work. The suite is exactly as described: modern, clean, and very '
          'comfortable. Highly recommended for digital nomads!',
    ),
    GuestReviewData(
      author: 'Sarah Jenkins',
      rating: 4,
      timeAgo: '3 months ago',
      comment:
          'Beautiful views and excellent service. The workstations are '
          'ergonomic and actually comfortable for long hours. Only minor '
          'issue was the lobby coffee, but there are great cafes nearby.',
    ),
  ];
}
