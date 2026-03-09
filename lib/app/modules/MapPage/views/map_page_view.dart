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
          place.position,
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
              Positioned.fill(
                child: Obx(
                  () => GoogleMap(
                    initialCameraPosition: ctrl.initialPosition,
                    markers: Set<Marker>.from(ctrl.markers),
                    circles: Set<Circle>.from(ctrl.circles),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (mapCtrl) {
                      ctrl.mapController = mapCtrl;
                      ctrl.onMapCreatedReady();
                    },
                    onCameraMove: (_) => ctrl.refreshZoom(),
                    onCameraIdle: () => ctrl.refreshZoom(),
                  ),
                ),
              ),
              Obx(() {
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
                          podcasts: place.podcasts,
                          onTap: () => Get.to(
                            () => PlaceDetailPage(place: place),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 400),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const Positioned(top: 16, left: 16, child: BackIcon()),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: const [
                    MapLocation(),
                    SizedBox(height: 12),
                    MapFilter(),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 16,
                child: Column(
                  children: [
                    _ZoomButton(icon: Icons.add, onTap: ctrl.zoomIn),
                    const SizedBox(height: 8),
                    _ZoomButton(icon: Icons.remove, onTap: ctrl.zoomOut),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});
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
