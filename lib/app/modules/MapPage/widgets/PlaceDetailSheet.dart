import 'package:flutter/material.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';

class PlaceDetailSheet extends StatefulWidget {
  final TouristPlace place;
  final VoidCallback onClose;
  

  const PlaceDetailSheet({super.key, required this.place, required this.onClose});

  @override
  State<PlaceDetailSheet> createState() => _PlaceDetailSheetState();
}

class _PlaceDetailSheetState extends State<PlaceDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animController.reverse();
    widget.onClose();
  }

  String _categoryLabel(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.touristic:
        return 'Touristique';
      case PlaceCategory.cultural:
        return 'Culturel';
      case PlaceCategory.nature:
        return 'Nature';
      case PlaceCategory.beach:
        return 'Plage';
      case PlaceCategory.market:
        return 'Marché';
      case PlaceCategory.historic:
        return 'Historique';
    }
  }

  Color _categoryColor(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.touristic:
        return const Color(0xFFFFC107);
      case PlaceCategory.cultural:
        return const Color(0xFF9C27B0);
      case PlaceCategory.nature:
        return const Color(0xFF4CAF50);
      case PlaceCategory.beach:
        return const Color(0xFF2196F3);
      case PlaceCategory.market:
        return const Color(0xFFFF5722);
      case PlaceCategory.historic:
        return const Color(0xFF795548);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    // ✅ category is a String in the model — parse it to enum here
    final PlaceCategory cat = TouristPlace.parseCategory(place.category);
    final catColor = _categoryColor(cat);

    // ✅ videoUrls is List<String> — use .isNotEmpty instead of != null
    final bool hasVideo = place.videoUrls.isNotEmpty;

    // ✅ total media = images + video count
    final int totalMedia =
        place.images.length + (hasVideo ? place.videoUrls.length : 0);
    final int extraCount = totalMedia > 4 ? totalMedia - 4 : 0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Main hero image ──────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: _PlaceImage(
                      // ✅ imageAsset is now a URL from Firestore — use Image.network
                      imageUrl: place.images.isNotEmpty
                          ? place.images[_selectedImageIndex]
                          : place.imageAsset,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _close,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categoryLabel(cat), // ✅ uses parsed enum
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Thumbnail strip ──────────────────────────────────────
              if (place.images.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      // First 3 images
                      for (int i = 0; i < place.images.length && i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImageIndex = i),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  _PlaceImage(
                                    imageUrl: place.images[i], // ✅ network URL
                                    height: 54,
                                    width: 70,
                                  ),
                                  if (_selectedImageIndex == i)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: catColor,
                                            width: 2.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // "+N more" tile
                      if (extraCount > 0 && place.images.length > 3)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              _PlaceImage(
                                imageUrl: place.images[3], // ✅ network URL
                                height: 54,
                                width: 70,
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '+$extraCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // ✅ Video badge — uses videoUrls.isNotEmpty
                      if (hasVideo) _VideoBadge(color: catColor),
                    ],
                  ),
                ),

              // ── Title + rating ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC107),
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Meta info row ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    _MetaChip(
                      icon: Icons.location_on_outlined,
                      label: place.distance,
                      color: Colors.grey[600]!,
                    ),
                    const SizedBox(width: 12),
                    _MetaChip(
                      icon: Icons.access_time_outlined,
                      label: place.openingHours,
                      color: Colors.grey[600]!,
                    ),
                    const Spacer(),
                    // ✅ podcasts field removed — show video count instead
                    if (hasVideo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFC107),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              // ✅ shows actual video count from videoUrls
                              '${place.videoUrls.length} Vidéo${place.videoUrls.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF795548),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Address (from localisation list) ─────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.map_outlined, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        // ✅ localisation is List<String> of [lat, lng]
                        // Display them as coordinates or use a reverse geocoded address
                        place.localisation.isNotEmpty
                            ? place.localisation.join(', ')
                            : 'Localisation non disponible',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Description ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  place.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.55,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── CTA Button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to detail page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.explore_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Explorer ce lieu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

class _VideoBadge extends StatelessWidget {
  final Color color;
  const _VideoBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Vidéo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Displays a NETWORK image (URLs from Firestore) with a grey fallback.
/// Previously used Image.asset — updated to Image.network.
class _PlaceImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;

  const _PlaceImage({
    required this.imageUrl,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          width: width,
          color: const Color(0xFFEEEEEE),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF6B35),
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => Container(
        height: height,
        width: width,
        color: const Color(0xFFEEEEEE),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 28),
          ],
        ),
      ),
    );
  }
}
