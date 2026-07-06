import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReservationMapView extends StatefulWidget {
  const ReservationMapView({required this.reservation, super.key});

  final BookingReservation reservation;

  @override
  State<ReservationMapView> createState() => _ReservationMapViewState();
}

class _ReservationMapViewState extends State<ReservationMapView> {
  WebViewController? _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    final latitude = widget.reservation.latitude;
    final longitude = widget.reservation.longitude;
    if (latitude == null || longitude == null) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress),
        ),
      )
      ..loadRequest(buildOpenStreetMapUri(latitude, longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('reservation_map_back_button'),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to reservations',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.reservation.propertyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _controller == null
          ? const _MissingLocation()
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_progress < 100)
                  LinearProgressIndicator(value: _progress / 100),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.reservation.propertyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

Uri buildOpenStreetMapUri(double latitude, double longitude) {
  const span = 0.008;
  final west = longitude - span;
  final south = latitude - span;
  final east = longitude + span;
  final north = latitude + span;
  return Uri.https('www.openstreetmap.org', '/export/embed.html', {
    'bbox': '$west,$south,$east,$north',
    'layer': 'mapnik',
    'marker': '$latitude,$longitude',
  });
}

class _MissingLocation extends StatelessWidget {
  const _MissingLocation();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: AppColors.gray400,
            ),
            SizedBox(height: 12),
            Text(
              'This property does not have map coordinates yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      ),
    );
  }
}
