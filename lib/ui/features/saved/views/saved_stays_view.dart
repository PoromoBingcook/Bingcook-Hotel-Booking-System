import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/utils/currency_formatter.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/saved/view_models/saved_stays_view_model.dart';
import 'package:bingcook/ui/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class SavedStaysView extends StatelessWidget {
  const SavedStaysView({
    required this.viewModel,
    required this.onStaySelected,
    required this.onToggleSaved,
    super.key,
  });

  final SavedStaysViewModel viewModel;
  final ValueChanged<StayCardData> onStaySelected;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading && viewModel.stays.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.stays.isEmpty) {
            return _SavedState(
              icon: Icons.cloud_off_rounded,
              title: viewModel.errorMessage!,
              actionLabel: 'Retry',
              onAction: viewModel.load,
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView(
              key: const Key('saved_stays_list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Saved stays',
                        key: Key('saved_stays_title'),
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontFamily: 'Manrope',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${viewModel.stays.length}',
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (viewModel.stays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: _SavedState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No saved stays yet',
                    ),
                  )
                else
                  for (var index = 0; index < viewModel.stays.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == viewModel.stays.length - 1 ? 0 : 14,
                      ),
                      child: _SavedStayCard(
                        data: viewModel.stays[index],
                        onTap: () => onStaySelected(viewModel.stays[index]),
                        onDismissed: () =>
                            onToggleSaved(viewModel.stays[index].id),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SavedStayCard extends StatelessWidget {
  const _SavedStayCard({
    required this.data,
    required this.onTap,
    required this.onDismissed,
  });

  final StayCardData data;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('saved_stay_card_${data.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.favorite_border_rounded,
          color: Color(0xFFEF4444),
        ),
      ),
      child: Semantics(
        button: true,
        label: 'Open ${data.name} details',
        child: InkWell(
          key: Key('saved_stay_${data.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gray100),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _SavedStayImage(data: data),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 112),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          children: [
                            _SavedBadge(
                              label: data.type.toUpperCase(),
                              background: const Color(0xFFE8F0FF),
                              foreground: AppColors.primary,
                            ),
                            _SavedBadge(
                              label: data.isAvailable
                                  ? 'AVAILABLE'
                                  : 'SOLD OUT',
                              background: data.isAvailable
                                  ? const Color(0xFFDDFBE8)
                                  : const Color(0xFFFEE2E2),
                              foreground: data.isAvailable
                                  ? AppColors.success
                                  : const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontFamily: 'Manrope',
                            fontSize: 19,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFFB7185),
                              size: 14,
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
                                  fontSize: 12,
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
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
                              color: AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              data.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${data.reviewCount} reviews',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.gray400,
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: data.amenities
                              .take(3)
                              .map((amenity) => _SavedAmenity(label: amenity))
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${formatVnd(data.price)}/night',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedStayImage extends StatelessWidget {
  const _SavedStayImage({required this.data});

  final StayCardData data;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      imageUrl: data.imageUrl,
      width: 142,
      height: 112,
      sourceWidth: 426,
      fallback: _SavedFallbackImage(data: data),
    );
  }
}

class _SavedFallbackImage extends StatelessWidget {
  const _SavedFallbackImage({required this.data});

  final StayCardData data;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      data.imageAsset,
      width: 142,
      height: 112,
      fit: BoxFit.cover,
    );
  }
}

class _SavedBadge extends StatelessWidget {
  const _SavedBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontFamily: 'Manrope',
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SavedAmenity extends StatelessWidget {
  const _SavedAmenity({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.gray500,
          fontFamily: 'Manrope',
          fontSize: 11,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SavedState extends StatelessWidget {
  const _SavedState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.gray400),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gray600,
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
