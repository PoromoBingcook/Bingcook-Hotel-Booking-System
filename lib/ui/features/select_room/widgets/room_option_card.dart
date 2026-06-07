import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:flutter/material.dart';

class RoomOptionCard extends StatelessWidget {
  const RoomOptionCard({
    required this.room,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final RoomOptionData room;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF2F7FF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('room_card_${room.id}'),
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primaryDark : AppColors.outline,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 8.8,
                    child: Image.asset(room.imageAsset, fit: BoxFit.cover),
                  ),
                  if (room.badge != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _RoomBadge(badge: room.badge!),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Manrope',
                                  fontSize: 17,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.group_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Up to ${room.maxGuests} guests',
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
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${room.pricePerNight}',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const TextSpan(
                                text: '/night',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final feature in room.features)
                          _RoomFeature(label: feature),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.outline),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          room.policyPositive
                              ? Icons.check_circle_outline_rounded
                              : Icons.history_rounded,
                          color: room.policyPositive
                              ? AppColors.success
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            room.policy,
                            style: TextStyle(
                              color: room.policyPositive
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryDark
                                  : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: selected
                              ? const CircleAvatar(
                                  radius: 6,
                                  backgroundColor: AppColors.primaryDark,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomBadge extends StatelessWidget {
  const _RoomBadge({required this.badge});

  final RoomBadge badge;

  @override
  Widget build(BuildContext context) {
    final isBestSeller = badge == RoomBadge.bestSeller;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBestSeller ? AppColors.primary : const Color(0xFF3F608D),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isBestSeller ? 'BEST SELLER' : 'PREMIUM',
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RoomFeature extends StatelessWidget {
  const _RoomFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }
}
