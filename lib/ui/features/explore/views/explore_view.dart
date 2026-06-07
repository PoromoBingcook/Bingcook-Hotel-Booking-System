import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/explore/widgets/stay_card.dart';
import 'package:flutter/material.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key, this.onSearchRequested, this.onStaySelected});

  final VoidCallback? onSearchRequested;
  final ValueChanged<StayCardData>? onStaySelected;

  static const _stays = [
    StayCardData(
      imageAsset: AppAssets.oceanPearlHotel,
      type: 'Hotel',
      name: 'Ocean Pearl Hotel',
      location: 'Da Nang · Vo Nguyen Giap',
      rating: 4.8,
      reviewCount: 26,
      amenities: ['Wi-Fi', 'Pool'],
      price: 68,
    ),
    StayCardData(
      imageAsset: AppAssets.blueGardenHomestay,
      type: 'Homestay',
      name: 'Blue Garden Homestay',
      location: 'Hoi An · Cam Chau',
      rating: 4.8,
      reviewCount: 26,
      amenities: ['Wi-Fi', 'Park'],
      price: 68,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const Text(
                  'Find your next stay',
                  style: TextStyle(
                    color: AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: 30,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.75,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hotels, motels, homestays',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  key: const Key('explore_search_card'),
                  onTap: onSearchRequested,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 34,
                          child: Icon(
                            Icons.search_rounded,
                            color: AppColors.gray600,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  color: AppColors.gray900,
                                  fontFamily: 'Manrope',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Jun 14 - Jun 15 (1 night) · 2 adults',
                                style: TextStyle(
                                  color: AppColors.gray600,
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  height: 1.43,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recommended stays',
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '24 results',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._stays.expand(
                  (stay) => [
                    StayCard(
                      data: stay,
                      onTap: stay.name == 'Ocean Pearl Hotel'
                          ? () => onStaySelected?.call(stay)
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
