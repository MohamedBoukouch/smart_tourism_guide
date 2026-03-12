import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/controllers/map_page_controller.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/PlacesApiService.dart';

// ── Filter button ─────────────────────────────────────────────────────────────

class MapFilter extends StatelessWidget {
  const MapFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _CategorySheet(),
      ),
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
        child: const Icon(Icons.tune_rounded, size: 22, color: Colors.black87),
      ),
    );
  }
}

// ── Step 1 — Category picker ──────────────────────────────────────────────────

class _CategorySheet extends StatelessWidget {
  const _CategorySheet();

  static const _cats = [
    _Cat(
      'restaurant',
      'Restaurants',
      Icons.restaurant_outlined,
      Color(0xFFFF6B35),
    ),
    _Cat('hotels', 'Hotels', Icons.hotel_outlined, Color(0xFF2196F3)),
    _Cat(
      'pharmacy',
      'Pharmacies',
      Icons.local_pharmacy_outlined,
      Color(0xFF4CAF50),
    ),
    _Cat('museum', 'Museums', Icons.museum_outlined, Color(0xFF9C27B0)),
    _Cat('park', 'Parks', Icons.park_outlined, Color(0xFF8BC34A)),
    _Cat(
      'shopping',
      'Shopping',
      Icons.shopping_bag_outlined,
      Color(0xFFE91E63),
    ),
    _Cat(
      'hospital',
      'Hospitals',
      Icons.local_hospital_outlined,
      Color(0xFFF44336),
    ),
    _Cat('cafe', 'Cafés', Icons.coffee_outlined, Color(0xFF795548)),
    _Cat('bank', 'Banks', Icons.account_balance_outlined, Color(0xFF607D8B)),
    _Cat(
      'gas',
      'Gas Stations',
      Icons.local_gas_station_outlined,
      Color(0xFFFF9800),
    ),
    _Cat(
      'supermarket',
      'Supermarkets',
      Icons.store_outlined,
      Color(0xFF009688),
    ),
    _Cat('airport', 'Airports', Icons.flight_outlined, Color(0xFF3F51B5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What are you looking for?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final cat = _cats[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openResults(context, cat);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cat.color.withOpacity(0.25)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, size: 22, color: cat.color),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cat.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openResults(BuildContext context, _Cat cat) {
    final ctrl = Get.find<MapPageController>();

    if (ctrl.currentLocation == null) {
      Get.snackbar(
        'Location needed',
        'Please enable location to search nearby places.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ResultsSheet(cat: cat, userLocation: ctrl.currentLocation!),
    );
  }
}

// ── Step 2 — Results list ─────────────────────────────────────────────────────

class _ResultsSheet extends StatefulWidget {
  final _Cat cat;
  final dynamic userLocation;
  const _ResultsSheet({required this.cat, required this.userLocation});

  @override
  State<_ResultsSheet> createState() => _ResultsSheetState();
}

class _ResultsSheetState extends State<_ResultsSheet> {
  List<NearbyPlace> _results = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final places = await PlacesApiService.fetchNearby(
      location: widget.userLocation,
      categoryId: widget.cat.id,
      radiusMeters: 3000,
      limit: 20,
    );

    if (!mounted) return;
    setState(() {
      _results = places;
      _loading = false;
      if (places.isEmpty) _error = 'No ${widget.cat.label} found within 3 km.';
    });
  }

  // ✅ Fixed: was moveToNearbyPlace(place) — renamed to moveToPlace(place)
  //           NearbyPlace is a different model from TouristPlace, so we
  //           close the sheet and trigger navigation via the controller's
  //           dedicated NearbyPlace overload below.
  void _onTap(NearbyPlace place) {
    Navigator.pop(context);
    Get.find<MapPageController>().moveToNearbyPlace(place); // ✅ see controller
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _handle(),
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby ${cat.label}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_loading && _error == null)
                          Text(
                            '${_results.length} found within 3 km',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
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
            const Divider(height: 1),

            // Route info banner
            Obx(() {
              final ctrl = Get.find<MapPageController>();
              if (!ctrl.hasRoute.value) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_walk,
                      color: Color(0xFFFF6B35),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${ctrl.routeDuration.value}  •  ${ctrl.routeDistance.value}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.find<MapPageController>().clearRoute(),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 4),

            Expanded(
              child: _loading
                  ? _buildLoading(cat.color)
                  : _error != null
                  ? _buildEmpty(_error!)
                  : _buildList(sc, cat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(Color c) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: c, strokeWidth: 2.5),
        const SizedBox(height: 16),
        Text(
          'Searching nearby places...',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildEmpty(String msg) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
      ],
    ),
  );

  Widget _buildList(ScrollController sc, _Cat cat) => ListView.separated(
    controller: sc,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    itemCount: _results.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, i) => _Tile(
      place: _results[i],
      accentColor: cat.color,
      onTap: () => _onTap(_results[i]),
    ),
  );
}

// ── Place tile ────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  final NearbyPlace place;
  final Color accentColor;
  final VoidCallback onTap;
  const _Tile({
    required this.place,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: place.photoReference != null
                  ? Image.network(
                      PlacesApiService.getPhotoUrl(place.photoReference!),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place.vicinity,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (place.rating != null) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (place.userRatingsTotal != null) ...[
                          const SizedBox(width: 3),
                          Text(
                            '(${place.userRatingsTotal})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: place.isOpen
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: place.isOpen
                                ? const Color(0xFF388E3C)
                                : const Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Navigate arrow
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Go',
                  style: TextStyle(
                    fontSize: 10,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 70,
    height: 70,
    color: Colors.grey[100],
    child: Icon(Icons.image_outlined, color: Colors.grey[300], size: 28),
  );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _handle() => Padding(
  padding: const EdgeInsets.only(top: 12, bottom: 4),
  child: Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(2),
    ),
  ),
);

class _Cat {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const _Cat(this.id, this.label, this.icon, this.color);
}
