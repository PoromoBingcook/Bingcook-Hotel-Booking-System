import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:bingcook/ui/features/bookings/widgets/reservation_card.dart';
import 'package:flutter/material.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({
    required this.viewModel,
    this.onReservationCancelled,
    this.onResumePayment,
    super.key,
  });

  final BookingsViewModel viewModel;
  final VoidCallback? onReservationCancelled;
  final ValueChanged<BookingReservation>? onResumePayment;

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
                key: Key('bookings_title'),
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
                    value: BookingListTab.active,
                    label: Text('Active'),
                  ),
                  ButtonSegment(
                    value: BookingListTab.past,
                    label: Text('Past'),
                  ),
                  ButtonSegment(
                    value: BookingListTab.canceled,
                    label: Text('Canceled'),
                  ),
                ],
                selected: {viewModel.selectedTab},
                showSelectedIcon: false,
                onSelectionChanged: (tabs) => viewModel.selectTab(tabs.first),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _content(context)),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
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
        child: Text(switch (viewModel.selectedTab) {
          BookingListTab.active => 'No active reservations yet.',
          BookingListTab.past => 'No past reservations yet.',
          BookingListTab.canceled => 'No canceled reservations yet.',
        }, style: const TextStyle(color: AppColors.gray600)),
      );
    }
    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        itemCount: reservations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final reservation = reservations[index];
          final canCancel =
              viewModel.selectedTab == BookingListTab.active &&
              viewModel.canCancel(reservation);
          final canResume =
              viewModel.selectedTab == BookingListTab.active &&
              viewModel.canResumePayment(reservation);
          return ReservationCard(
            reservation: reservation,
            paymentCountdown: canResume
                ? viewModel.paymentCountdown(reservation)
                : null,
            onResumePayment: canResume
                ? () => onResumePayment?.call(reservation)
                : null,
            isCancelling:
                viewModel.cancellingBookingId == reservation.bookingId,
            onCancel: canCancel
                ? () => _confirmCancellation(context, reservation)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    BookingReservation reservation,
  ) async {
    final hasSuccessfulPayment =
        reservation.paymentStatus?.toLowerCase() == 'success';
    final isPendingPayment =
        reservation.bookingStatus.toLowerCase() == 'pendingpayment';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text(
          '${isPendingPayment ? 'This closes the PayOS payment link and releases the room immediately.' : 'Cancellation is available until 24 hours before the 14:00 check-in time.'}'
          '${hasSuccessfulPayment ? ' Your successful payment remains recorded. Refund handling is separate.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep reservation'),
          ),
          FilledButton(
            key: const Key('confirm_booking_cancellation'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel reservation'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await viewModel.cancel(reservation);
    if (!context.mounted) {
      return;
    }
    final message = success
        ? viewModel.successMessage
        : viewModel.actionErrorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (success) {
      onReservationCancelled?.call();
    }
  }
}
