import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/bookings/views/reservation_map_view.dart';
import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({required this.reservation, super.key});

  final BookingReservation reservation;

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
                        onPressed: () => _showDetails(context),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

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

class _ReservationImage extends StatelessWidget {
  const _ReservationImage({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || !imageUrl.startsWith('http')) {
      return Image.asset(AppAssets.oceanPearlHotel, fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(AppAssets.oceanPearlHotel, fit: BoxFit.cover),
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
