import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/views/PlaceDetailPage.dart';
import '../controllers/favorite_page_controller.dart';

class FavoritePageView extends StatelessWidget {
  const FavoritePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritePageController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: controller.fetchFavorites,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.fetchFavorites,
          );
        }

        if (controller.favorites.isEmpty) {
          return const _EmptyView();
        }

        return RefreshIndicator(
          color: const Color(0xFFFF6B35),
          backgroundColor: const Color(0xFF1A1A1A),
          onRefresh: controller.fetchFavorites,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: controller.favorites.length,
            itemBuilder: (_, i) {
              final place = controller.favorites[i];
              return _FavoriteCard(
                place: place,
                onTap: () => Get.to(
                  () => PlaceDetailPage(place: place),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 400),
                ),
                onRemove: () => controller.toggleFavorite(place),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─── Single favorite card ─────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final TouristPlace place;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.place,
    required this.onTap,
    required this.onRemove,
  });

  Color get _accent {
    switch (TouristPlace.parseCategory(place.category)) {
      case PlaceCategory.touristic:
        return const Color(0xFFFF6B35);
      case PlaceCategory.cultural:
        return const Color(0xFFB06AE8);
      case PlaceCategory.nature:
        return const Color(0xFF3ECF8E);
      case PlaceCategory.beach:
        return const Color(0xFF38BDF8);
      case PlaceCategory.market:
        return const Color(0xFFFF8C42);
      case PlaceCategory.historic:
        return const Color(0xFFD4A843);
    }
  }

  bool get _isNetwork =>
      place.imageAsset.startsWith('http://') ||
      place.imageAsset.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: place.imageAsset.isEmpty
                    ? _imagePlaceholder()
                    : _isNetwork
                    ? Image.network(
                        place.imageAsset,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : _loadingPlaceholder(),
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : Image.asset(
                        place.imageAsset,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      ),
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Name
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Distance + rating
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 12,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place.distance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${place.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Remove button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.bookmark_remove_outlined,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: const Color(0xFF252525),
    child: const Icon(Icons.image_outlined, color: Colors.white24, size: 32),
  );

  Widget _loadingPlaceholder() => Container(
    color: const Color(0xFF252525),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFF6B35),
        ),
      ),
    ),
  );
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6B35).withOpacity(0.08),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 42,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the bookmark icon on any place\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white38, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
