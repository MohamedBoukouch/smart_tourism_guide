import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_tourism_guide/app/widgets/CustomAppBar.dart';
import 'package:smart_tourism_guide/app/widgets/back_icon.dart';
import '../controllers/map_page_controller.dart';
import '../widgets/map_filter.dart';
import '../widgets/map_location.dart';

class MapPageView extends GetView<MapPageController> {
  const MapPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapPageController>(
      init: MapPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: Stack(
            children: [
              // ── Google Map ───────────────────────────────────────────
              Obx(
                () => GoogleMap(
                  initialCameraPosition: controller.initialPosition,
                  markers: Set<Marker>.from(controller.markers),
                  circles: Set<Circle>.from(controller.circles),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (ctrl) => controller.mapController = ctrl,
                  onTap: (_) => controller.dismissCard(),
                ),
              ),

              // ── Back button ──────────────────────────────────────────
              const Positioned(top: 16, left: 16, child: BackIcon()),

              // ── Right top buttons ────────────────────────────────────
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

              // ── Zoom buttons bottom right ────────────────────────────
              Positioned(
                bottom: 120,
                right: 16,
                child: Column(
                  children: [
                    _ZoomButton(icon: Icons.add, onTap: controller.zoomIn),
                    const SizedBox(height: 8),
                    _ZoomButton(icon: Icons.remove, onTap: controller.zoomOut),
                  ],
                ),
              ),

              // ── Tourist place info card ──────────────────────────────
              Obx(() {
                final place = controller.selectedPlace.value;
                if (place == null) return const SizedBox.shrink();
                return Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: _PlaceCard(place: place),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Zoom Button ──────────────────────────────────────────────────────────────

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

// ─── Place Info Card ──────────────────────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  final TouristPlace place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              place.imageAsset,
              width: 90,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        place.distance,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${place.podcasts} Podcasts',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
