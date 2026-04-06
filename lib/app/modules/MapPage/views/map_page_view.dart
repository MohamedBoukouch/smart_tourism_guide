import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/views/PlaceDetailPage.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/widgets/PlaceCardMarker.dart';
import 'package:smart_tourism_guide/app/widgets/CustomAppBar.dart';
import 'package:smart_tourism_guide/app/widgets/back_icon.dart';
import '../controllers/map_page_controller.dart';
import '../widgets/map_filter.dart';
import '../widgets/map_location.dart';

class MapPageView extends StatefulWidget {
  const MapPageView({Key? key}) : super(key: key);

  @override
  State<MapPageView> createState() => _MapPageViewState();
}

class _MapPageViewState extends State<MapPageView>
    with SingleTickerProviderStateMixin {
  final MapPageController controller = Get.put(MapPageController());
  final Map<String, Offset?> _positions = {};
  late final Ticker _ticker;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _updatePositions());
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _updatePositions() async {
    if (_updating || controller.mapController == null) return;
    _updating = true;
    bool changed = false;
    for (final place in controller.touristPlaces) {
      try {
        final sc = await controller.mapController!.getScreenCoordinate(
          place.location, // ✅ was place.position — now uses the LatLng getter
        );
        final ratio = ui.window.devicePixelRatio;
        final newOffset = Offset(sc.x / ratio, sc.y / ratio);
        if (_positions[place.id] != newOffset) {
          _positions[place.id] = newOffset;
          changed = true;
        }
      } catch (_) {}
    }
    if (changed && mounted) setState(() {});
    _updating = false;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final double baseCardW = screenW * 0.75;
    const double baseCardH = 114.0;

    return GetBuilder<MapPageController>(
      builder: (ctrl) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: Stack(
            children: [
              // ── 1. Google Map — always full screen ─────────────────────
              Positioned.fill(
                child: Obx(
                  () => GoogleMap(
                    initialCameraPosition: ctrl.initialPosition,
                    markers: Set<Marker>.from(ctrl.markers),
                    circles: Set<Circle>.from(ctrl.circles),
                    polylines: Set<Polyline>.from(ctrl.polylines),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    onTap: (_) => ctrl.onMapTapped(),
                    onMapCreated: (mapCtrl) {
                      ctrl.mapController = mapCtrl;
                      ctrl.onMapCreatedReady();
                    },
                    onCameraMove: (_) => ctrl.refreshZoom(),
                    onCameraIdle: () => ctrl.refreshZoom(),
                  ),
                ),
              ),

              // ── 2. Place cards (hidden while navigating) ───────────────
              Obx(() {
                if (ctrl.isNavigating.value) return const SizedBox.shrink();
                final scale = ctrl.cardScale;
                final scaledCardW = baseCardW * scale;
                final scaledCardH = baseCardH * scale;
                return Stack(
                  children: ctrl.touristPlaces.map((place) {
                    final Offset? pos = _positions[place.id];
                    final double left = pos != null
                        ? pos.dx - scaledCardW / 2
                        : screenW / 2 - scaledCardW / 2;
                    final double top = pos != null
                        ? pos.dy - scaledCardH
                        : screenH / 2 - scaledCardH;
                    return Positioned(
                      left: left,
                      top: top,
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: PlaceCardMarker(
                          imagePath: place.imageAsset,
                          name: place.name,
                          distance: place.distance,
                          // ✅ podcasts removed — not in model
                          onTap: () => Get.to(
                            () => PlaceDetailPage(place: place),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 400),
                          ),
                          podcasts: 00,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              // ── 3. Top-left button ─────────────────────────────────────
              Positioned(
                top: 16,
                left: 16,
                child: Obx(
                  () => ctrl.isNavigating.value
                      ? _MapBtn(
                          icon: Icons.my_location,
                          onTap: ctrl.fitRoute,
                          tooltip: 'Re-center',
                        )
                      : const BackIcon(),
                ),
              ),

              // ── 4. Top-right buttons (hidden while navigating) ─────────
              Obx(() {
                if (ctrl.isNavigating.value) return const SizedBox.shrink();
                return Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: const [
                      MapLocation(),
                      SizedBox(height: 12),
                      MapFilter(),
                    ],
                  ),
                );
              }),

              // ── 5. Zoom +/- (always visible, above nav panel) ──────────
              Obx(() {
                final bottomOffset = ctrl.hasRoute.value ? 150.0 : 40.0;
                return Positioned(
                  bottom: bottomOffset,
                  right: 16,
                  child: Column(
                    children: [
                      _MapBtn(icon: Icons.add, onTap: ctrl.zoomIn),
                      const SizedBox(height: 8),
                      _MapBtn(icon: Icons.remove, onTap: ctrl.zoomOut),
                    ],
                  ),
                );
              }),

              // ── 6. Navigation bottom panel ─────────────────────────────
              Obx(() {
                if (!ctrl.hasRoute.value) return const SizedBox.shrink();
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _NavPanel(ctrl: ctrl),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Navigation bottom panel ──────────────────────────────────────────────────

class _NavPanel extends StatelessWidget {
  final MapPageController ctrl;
  const _NavPanel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              // Walking icon circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: Color(0xFFFF6B35),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Duration + distance
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ctrl.routeDuration.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        ctrl.routeDistance.value,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Start / active + Stop
              Obx(
                () => ctrl.isNavigating.value
                    ? Row(
                        children: [
                          // Active indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Live',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Stop button
                          GestureDetector(
                            onTap: ctrl.stopNavigation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Stop',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Start button
                          GestureDetector(
                            onTap: ctrl.startNavigation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.navigation_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Go',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Close route
                          GestureDetector(
                            onTap: ctrl.clearRoute,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Small map button ─────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _MapBtn({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }
}
