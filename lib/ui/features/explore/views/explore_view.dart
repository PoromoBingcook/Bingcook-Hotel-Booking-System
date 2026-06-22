import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/explore/view_models/explore_view_model.dart';
import 'package:bingcook/ui/features/explore/widgets/stay_card.dart';
import 'package:flutter/material.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({
    required this.viewModel,
    super.key,
    this.onSearchRequested,
    this.onStaySelected,
  });

  final ExploreViewModel viewModel;
  final VoidCallback? onSearchRequested;
  final ValueChanged<StayCardData>? onStaySelected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 34,
                              child: Icon(
                                Icons.search_rounded,
                                color: AppColors.gray600,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(
                                      color: AppColors.gray900,
                                      fontFamily: 'Manrope',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    viewModel.searchSummary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            viewModel.listTitle,
                            style: const TextStyle(
                              color: AppColors.gray900,
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          viewModel.resultCountLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildStayContent(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildStayContent() {
    if (viewModel.isLoading && viewModel.stays.isEmpty) {
      return const [
        SizedBox(height: 32),
        Center(child: CircularProgressIndicator()),
      ];
    }

    final errorMessage = viewModel.errorMessage;
    if (errorMessage != null && viewModel.stays.isEmpty) {
      return [
        _ExploreMessage(
          icon: Icons.wifi_off_rounded,
          title: errorMessage,
          actionLabel: 'Retry',
          onAction: viewModel.retry,
        ),
      ];
    }

    if (viewModel.isEmpty) {
      return const [
        _ExploreMessage(
          icon: Icons.hotel_outlined,
          title: 'No stays match your search.',
        ),
      ];
    }

    return [
      ...viewModel.stays.expand(
        (stay) => [
          StayCard(data: stay, onTap: () => onStaySelected?.call(stay)),
          const SizedBox(height: 16),
        ],
      ),
      if (viewModel.isLoading) const LinearProgressIndicator(),
    ];
  }
}

class _ExploreMessage extends StatelessWidget {
  const _ExploreMessage({
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
    final actionLabel = this.actionLabel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gray500, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.gray600,
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}
