import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';

class PlaceDetailPage extends StatefulWidget {
  final TouristPlace place;
  const PlaceDetailPage({Key? key, required this.place}) : super(key: key);

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  int _selectedImageIndex = 0;

  TouristPlace get place => widget.place;

  Color _categoryColor(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.touristic:
        return const Color(0xFFFF6B35);
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

  String _categoryLabel(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.touristic:
        return 'Touristic';
      case PlaceCategory.cultural:
        return 'Cultural';
      case PlaceCategory.nature:
        return 'Nature';
      case PlaceCategory.beach:
        return 'Beach';
      case PlaceCategory.market:
        return 'Market';
      case PlaceCategory.historic:
        return 'Historic';
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(place.category);
    final screenW = MediaQuery.of(context).size.width;
    // How many extra images beyond the 3 shown
    final extraCount = place.images.length > 3 ? place.images.length - 3 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top image carousel + header ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image ───────────────────────────────────────
                    Stack(
                      children: [
                        // Main image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          child: Image.asset(
                            place.images.isNotEmpty
                                ? place.images[_selectedImageIndex]
                                : place.imageAsset,
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 260,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        // Back button top-left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        // Notification bell top-right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: catColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Thumbnail strip bottom of image
                        if (place.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              children: [
                                for (
                                  int i = 0;
                                  i < place.images.length && i < 3;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedImageIndex = i,
                                      ),
                                      child: Container(
                                        width: 64,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: _selectedImageIndex == i
                                              ? Border.all(
                                                  color: Colors.white,
                                                  width: 2.5,
                                                )
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            place.images[i],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // +N more
                                if (extraCount > 0)
                                  Container(
                                    width: 64,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black.withOpacity(0.55),
                                    ),
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
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Brand name + PREMIUM badge ─────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Place name styled like "GIROUETTE"
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: place.name
                                          .toUpperCase()
                                          .replaceFirst(
                                            place.name.toUpperCase().contains(
                                                  'O',
                                                )
                                                ? 'O'
                                                : '',
                                            '',
                                          ),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: catColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Premium badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFD54F),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium,
                                      size: 14,
                                      color: Color(0xFFFFB300),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _categoryLabel(
                                        place.category,
                                      ).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFFF8F00),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── +Videos count ──────────────────────────────
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '+${place.podcasts * 50} ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: catColor,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Vidéos',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les Incontournables – Histoire – Art – Culture Etc.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Podcasts / listening hours ─────────────────
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${place.podcasts * 2} ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: catColor,
                                  ),
                                ),
                                const TextSpan(
                                  text: "HEURES D'ÉCOUTES",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les Incontournables – Histoire – Art – Politique Et Des Monuments',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Description ────────────────────────────────
                          Text(
                            place.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Info chips row ─────────────────────────────
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.star_rounded,
                                label: '${place.rating}',
                                color: const Color(0xFFFFC107),
                              ),
                              _InfoChip(
                                icon: Icons.access_time_outlined,
                                label: place.openingHours,
                                color: catColor,
                              ),
                              _InfoChip(
                                icon: Icons.location_on_outlined,
                                label: place.distance,
                                color: catColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // ── Address ────────────────────────────────────
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 13,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.address,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '${place.podcasts * 2} Podcasts • Start Listening',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Footer links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FooterLink(text: 'Conditions Générales'),
                      const Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      _FooterLink(text: 'Propulsé Par App'),
                      const Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      _FooterLink(text: 'Restaurer'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer link ──────────────────────────────────────────────────────────────
class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
