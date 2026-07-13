import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/utils/currency_formatter.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NearbyMapView extends StatefulWidget {
  const NearbyMapView({
    required this.stays,
    required this.onBack,
    required this.onStaySelected,
    super.key,
  });

  final List<StayCardData> stays;
  final VoidCallback onBack;
  final ValueChanged<StayCardData> onStaySelected;

  @override
  State<NearbyMapView> createState() => _NearbyMapViewState();
}

class _NearbyMapViewState extends State<NearbyMapView> {
  static const _defaultCenter = LatLng(16.0544, 108.2022);

  String? _selectedStayId;

  List<StayCardData> get _mappedStays =>
      widget.stays.where((stay) => stay.hasCoordinates).toList(growable: false);

  @override
  void initState() {
    super.initState();
    final stays = _mappedStays;
    _selectedStayId = stays.isEmpty ? null : stays.first.id;
  }

  @override
  void didUpdateWidget(covariant NearbyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stays = _mappedStays;
    if (!stays.any((stay) => stay.id == _selectedStayId)) {
      _selectedStayId = stays.isEmpty ? null : stays.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stays = _mappedStays;
    final selectedStay = _findSelectedStay(stays);
    final points = stays
        .map((stay) => LatLng(stay.latitude!, stay.longitude!))
        .toList(growable: false);
    final initialCenter = points.isEmpty ? _defaultCenter : points.first;

    return ColoredBox(
      color: const Color(0xFFE6EDF2),
      child: Stack(
        children: [
          FlutterMap(
            key: ValueKey(stays.map((stay) => stay.id).join(',')),
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.5,
              initialCameraFit: points.length > 1
                  ? CameraFit.coordinates(
                      coordinates: points,
                      padding: const EdgeInsets.fromLTRB(48, 150, 48, 220),
                      maxZoom: 14,
                    )
                  : null,
            ),
            children: [
              // ponytail: public OSM tiles cover MVP traffic; switch to a
              // hosted tile provider before scale.
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bingcook.bingcook',
              ),
              MarkerLayer(
                markers: stays.map(_buildMarker).toList(growable: false),
              ),
            ],
          ),
          _MapHeader(
            count: stays.length,
            onBack: widget.onBack,
            usingDefaultArea: stays.isEmpty,
          ),
          Positioned(
            right: 12,
            bottom: selectedStay == null ? 104 : 190,
            child: const _MapAttribution(),
          ),
          if (selectedStay == null)
            const Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _NoMappedStays(),
            )
          else
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _PropertyPreview(
                stay: selectedStay,
                onViewStay: () => widget.onStaySelected(selectedStay),
              ),
            ),
        ],
      ),
    );
  }

  Marker _buildMarker(StayCardData stay) {
    final selected = stay.id == _selectedStayId;
    return Marker(
      point: LatLng(stay.latitude!, stay.longitude!),
      width: 108,
      height: 54,
      alignment: Alignment.topCenter,
      child: Semantics(
        button: true,
        label: 'Select ${stay.name}, ${formatVnd(stay.price)} per night',
        child: GestureDetector(
          key: Key('nearby_map_marker_${stay.id}'),
          onTap: () => setState(() => _selectedStayId = stay.id),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.slate900 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.slate900 : AppColors.gray200,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x260F172A),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  formatVnd(stay.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.slate900,
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: selected ? AppColors.slate900 : Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  StayCardData? _findSelectedStay(List<StayCardData> stays) {
    for (final stay in stays) {
      if (stay.id == _selectedStayId) {
        return stay;
      }
    }
    return stays.isEmpty ? null : stays.first;
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.count,
    required this.onBack,
    required this.usingDefaultArea,
  });

  final int count;
  final VoidCallback onBack;
  final bool usingDefaultArea;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220F172A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                key: const Key('nearby_map_back_button'),
                onPressed: onBack,
                tooltip: 'Back to stays',
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby stays',
                      key: Key('nearby_map_title'),
                      style: TextStyle(
                        color: AppColors.slate900,
                        fontFamily: 'Manrope',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      usingDefaultArea
                          ? 'Da Nang default area'
                          : count == 1
                          ? '1 stay on map'
                          : '$count stays on map',
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.layers_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyPreview extends StatelessWidget {
  const _PropertyPreview({required this.stay, required this.onViewStay});

  final StayCardData stay;
  final VoidCallback onViewStay;

  @override
  Widget build(BuildContext context) {
    final address = stay.address.isEmpty ? stay.location : stay.address;

    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x330F172A),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                        stay.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.slate900,
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.slate400,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.slate500,
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatVnd(stay.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'per night',
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 19,
                ),
                const SizedBox(width: 4),
                Text(
                  stay.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${stay.reviewCount} reviews',
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontFamily: 'Manrope',
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  key: const Key('nearby_map_view_stay_button'),
                  onPressed: onViewStay,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('View stay'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMappedStays extends StatelessWidget {
  const _NoMappedStays();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off_outlined, color: AppColors.slate500),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No stays with map coordinates. Showing the default Da Nang area.',
              style: TextStyle(
                color: AppColors.slate700,
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '(c) OpenStreetMap contributors',
        style: TextStyle(
          color: AppColors.slate500,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
