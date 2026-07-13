import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/features/select_room/view_models/select_room_view_model.dart';
import 'package:bingcook/ui/features/select_room/widgets/room_option_card.dart';
import 'package:bingcook/ui/features/select_room/widgets/select_room_footer.dart';
import 'package:bingcook/ui/features/select_room/widgets/select_room_property_context.dart';
import 'package:flutter/material.dart';

class SelectRoomView extends StatelessWidget {
  const SelectRoomView({
    required this.data,
    required this.viewModel,
    required this.onBack,
    required this.onContinue,
    required this.isSaved,
    required this.onSavedToggle,
    super.key,
  });

  final SelectRoomData data;
  final SelectRoomViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool isSaved;
  final VoidCallback onSavedToggle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 448),
            color: AppColors.background,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SelectRoomHeader(
                      isFavorite: isSaved,
                      onBack: onBack,
                      onFavorite: onSavedToggle,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        children: [
                          SelectRoomPropertyContext(data: data),
                          const SizedBox(height: 16),
                          for (
                            var index = 0;
                            index < data.rooms.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == data.rooms.length - 1 ? 0 : 14,
                              ),
                              child: RoomOptionCard(
                                room: data.rooms[index],
                                selected:
                                    viewModel.selectedRoomId ==
                                    data.rooms[index].id,
                                onSelected: () =>
                                    viewModel.selectRoom(data.rooms[index]),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SelectRoomFooter(
                      nights: data.nights,
                      total: viewModel.totalPrice,
                      canContinue: viewModel.canContinue,
                      isLoading: viewModel.isCreatingDraft,
                      errorMessage: viewModel.errorMessage,
                      onContinue: onContinue,
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

class _SelectRoomHeader extends StatelessWidget {
  const _SelectRoomHeader({
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
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Select Room',
            key: Key('select_room_title'),
            style: TextStyle(
              color: AppColors.primaryDark,
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              key: const Key('select_room_back_button'),
              onPressed: onBack,
              tooltip: 'Back to Property Details',
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              color: AppColors.primaryDark,
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              key: const Key('select_room_favorite_button'),
              onPressed: onFavorite,
              tooltip: isFavorite ? 'Remove from saved' : 'Save property',
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 21,
              ),
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
