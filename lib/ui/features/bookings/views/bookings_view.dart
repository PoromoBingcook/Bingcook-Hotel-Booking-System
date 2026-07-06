import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:bingcook/ui/features/bookings/widgets/reservation_card.dart';
import 'package:flutter/material.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({required this.viewModel, super.key});

  final BookingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Text(
                'My Reservations',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontFamily: 'Manrope',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<BookingListTab>(
                segments: const [
                  ButtonSegment(
                    value: BookingListTab.upcoming,
                    label: Text('Upcoming'),
                  ),
                  ButtonSegment(
                    value: BookingListTab.past,
                    label: Text('Past'),
                  ),
                ],
                selected: {viewModel.selectedTab},
                showSelectedIcon: false,
                onSelectionChanged: (tabs) => viewModel.selectTab(tabs.first),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 44,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 12),
              Text(viewModel.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: viewModel.load,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    final reservations = viewModel.visibleReservations;
    if (reservations.isEmpty) {
      return Center(
        child: Text(
          viewModel.selectedTab == BookingListTab.upcoming
              ? 'No upcoming reservations yet.'
              : 'No past reservations yet.',
          style: const TextStyle(color: AppColors.gray600),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        itemCount: reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) =>
            ReservationCard(reservation: reservations[index]),
      ),
    );
  }
}
