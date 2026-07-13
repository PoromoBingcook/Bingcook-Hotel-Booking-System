import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/explore/widgets/stay_card.dart';
import 'package:bingcook/ui/features/saved/view_models/saved_stays_view_model.dart';
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
                      child: StayCard(
                        data: viewModel.stays[index],
                        isSaved: true,
                        onTap: () => onStaySelected(viewModel.stays[index]),
                        onSavedToggle: () =>
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
