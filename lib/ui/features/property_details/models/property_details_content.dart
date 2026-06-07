import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';

abstract final class PropertyDetailsContent {
  static const oceanPearl = PropertyDetailsData(
    imageAsset: AppAssets.propertyDetails,
    name: 'Ocean Pearl Hotel',
    location: 'Da Nang · Vo Nguyen Giap',
    rating: 4.8,
    reviewCount: 26,
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
    ratingDistribution: [
      RatingDistributionData(stars: 5, fraction: 0.85),
      RatingDistributionData(stars: 4, fraction: 0.15),
      RatingDistributionData(stars: 3, fraction: 0.04),
      RatingDistributionData(stars: 2, fraction: 0.02),
      RatingDistributionData(stars: 1, fraction: 0.20),
    ],
    summaryRating: 4.4,
    summaryReviewCount: 766,
    reviews: [
      GuestReviewData(
        author: 'Alex Thompson',
        rating: 5,
        timeAgo: '2 months ago',
        comment:
            'The high-speed fiber internet was a game-changer for my remote '
            'work. The suite is exactly as described—modern, clean, and very '
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
    ],
  );
}
