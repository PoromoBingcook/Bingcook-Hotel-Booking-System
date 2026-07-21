import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/bookings/views/reservation_map_view.dart';
import 'package:bingcook/ui/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({
    required this.reservation,
    this.onCancel,
    this.onResumePayment,
    this.paymentCountdown,
    this.isCancelling = false,
    super.key,
  });

  final BookingReservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onResumePayment;
  final String? paymentCountdown;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 176,
                width: double.infinity,
                child: _ReservationImage(url: reservation.propertyImageUrl),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _StatusBadge(status: reservation.bookingStatus),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.propertyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${_date(reservation.checkIn)} – ${_date(reservation.checkOut)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          _money(reservation.totalPrice),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _showFullWidthDetails(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      key: Key('reservation_map_${reservation.bookingId}'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ReservationMapView(reservation: reservation),
                        ),
                      ),
                      tooltip: 'View hotel on map',
                      icon: const Icon(Icons.map_outlined),
                    ),
                  ],
                ),
                if (onResumePayment != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 17,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Payment expires in $paymentCountdown',
                        key: Key(
                          'reservation_payment_countdown_${reservation.bookingId}',
                        ),
                        style: const TextStyle(
                          color: AppColors.gray600,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: Key('resume_payment_${reservation.bookingId}'),
                          onPressed: onResumePayment,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Resume payment'),
                        ),
                      ),
                      if (onCancel != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: Key('cancel_booking_${reservation.bookingId}'),
                            onPressed: isCancelling ? null : onCancel,
                            icon: isCancelling
                                ? const SizedBox.square(
                                    key: Key('cancel_booking_progress'),
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.event_busy_outlined,
                                    size: 18,
                                  ),
                            label: Text(
                              isCancelling ? 'Canceling...' : 'Cancel',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else if (onCancel != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: Key('cancel_booking_${reservation.bookingId}'),
                      onPressed: isCancelling ? null : onCancel,
                      icon: isCancelling
                          ? const SizedBox.square(
                              key: Key('cancel_booking_progress'),
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.event_busy_outlined, size: 18),
                      label: Text(
                        isCancelling ? 'Canceling...' : 'Cancel reservation',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullWidthDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.88,
        widthFactor: 1,
        child: _ReservationDetailsSheet(reservation: reservation),
      ),
    );
  }

  // ignore: unused_element
  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.propertyName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Room: ${reservation.roomName}'),
              Text(
                'Stay: ${_date(reservation.checkIn)} – ${_date(reservation.checkOut)}',
              ),
              Text(
                'Guests: ${reservation.adults} adults, ${reservation.children} children',
              ),
              Text('Rooms: ${reservation.roomQuantity}'),
              Text('Booking status: ${reservation.bookingStatus}'),
              if (reservation.paymentStatus != null)
                Text('Payment status: ${reservation.paymentStatus}'),
            ],
          ),
        ),
      ),
    );
  }

  static String _date(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  static String _money(double value) {
    final digits = value.round().toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$formatted ₫';
  }
}

class _ReservationDetailsSheet extends StatelessWidget {
  const _ReservationDetailsSheet({required this.reservation});

  final BookingReservation reservation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _DetailsHero(reservation: reservation),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                    sliver: SliverList.list(
                      children: [
                        _StaySummary(reservation: reservation),
                        const SizedBox(height: 14),
                        _DetailSection(
                          title: 'Reservation',
                          children: [
                            _DetailRow(
                              icon: Icons.meeting_room_outlined,
                              label: 'Room',
                              value: reservation.roomName,
                            ),
                            _DetailRow(
                              icon: Icons.group_outlined,
                              label: 'Guests',
                              value:
                                  '${reservation.adults} adults, ${reservation.children} children',
                            ),
                            _DetailRow(
                              icon: Icons.king_bed_outlined,
                              label: 'Rooms',
                              value: reservation.roomQuantity.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DetailSection(
                          title: 'Payment',
                          children: [
                            _DetailRow(
                              icon: Icons.payments_outlined,
                              label: 'Total',
                              value: ReservationCard._money(
                                reservation.totalPrice,
                              ),
                              emphasized: true,
                            ),
                            _DetailRow(
                              icon: Icons.credit_card_outlined,
                              label: 'Method',
                              value:
                                  reservation.paymentMethod ?? 'Not selected',
                            ),
                            _DetailRow(
                              icon: Icons.verified_outlined,
                              label: 'Payment status',
                              value: reservation.paymentStatus ?? 'Pending',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({required this.reservation});

  final BookingReservation reservation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 244,
          width: double.infinity,
          child: _ReservationImage(url: reservation.propertyImageUrl),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 12,
          child: IconButton.filled(
            tooltip: 'Close details',
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.92),
              foregroundColor: AppColors.gray900,
            ),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: _readableStatus(reservation.bookingStatus),
                    color: _statusColor(reservation.bookingStatus),
                  ),
                  if (reservation.paymentStatus != null)
                    _StatusPill(
                      label: _readableStatus(reservation.paymentStatus!),
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reservation.propertyName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  fontSize: 25,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${ReservationCard._date(reservation.checkIn)} - ${ReservationCard._date(reservation.checkOut)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaySummary extends StatelessWidget {
  const _StaySummary({required this.reservation});

  final BookingReservation reservation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Check-in',
            value: ReservationCard._date(reservation.checkIn),
            icon: Icons.login_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Check-out',
            value: ReservationCard._date(reservation.checkOut),
            icon: Icons.logout_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gray900,
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.gray900,
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: emphasized
                        ? AppColors.primaryDark
                        : AppColors.gray900,
                    fontFamily: 'Manrope',
                    fontSize: emphasized ? 18 : 15,
                    fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _readableStatus(String status) {
  return status.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');
}

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'paid') {
    return AppColors.primary;
  }
  if (normalized == 'confirmed') {
    return AppColors.success;
  }
  if (normalized == 'cancelled' ||
      normalized == 'canceled' ||
      normalized == 'expired') {
    return AppColors.gray600;
  }
  return AppColors.warning;
}

class _ReservationImage extends StatelessWidget {
  const _ReservationImage({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      imageUrl: url?.startsWith('http') == true ? url : null,
      sourceWidth: 480,
      fallback: Image.asset(AppAssets.oceanPearlHotel, fit: BoxFit.cover),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'paid'
        ? AppColors.primary
        : normalized == 'confirmed'
        ? AppColors.success
        : normalized == 'cancelled' || normalized == 'expired'
        ? AppColors.gray600
        : AppColors.warning;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        child: Text(
          status.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' '),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
