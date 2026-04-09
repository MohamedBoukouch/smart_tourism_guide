import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/views/PlaceDetailPage.dart';
import '../controllers/favorite_page_controller.dart';

class FavoritePageView extends StatefulWidget {
  const FavoritePageView({super.key});

  @override
  State<FavoritePageView> createState() => _FavoritePageViewState();
}

class _FavoritePageViewState extends State<FavoritePageView> {
  int _selectedTab = 1; // 0 = Favoris, 1 = En Cours, 2 = Téléchargés

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritePageController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF8C00),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── List ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
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
                color: const Color(0xFFFF8C00),
                onRefresh: controller.fetchFavorites,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.favorites.length,
                  itemBuilder: (_, i) {
                    final place = controller.favorites[i];
                    return _MonumentCard(
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Item
// ─────────────────────────────────────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8C00) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && isSelected) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Monument Card  (matches the image: white card, orange underline, − button)
// ─────────────────────────────────────────────────────────────────────────────
class _MonumentCard extends StatelessWidget {
  final TouristPlace place;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _MonumentCard({
    required this.place,
    required this.onTap,
    required this.onRemove,
  });

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: place.imageAsset.isEmpty
                          ? _placeholder()
                          : _isNetwork
                          ? Image.network(
                              place.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : Image.asset(
                              place.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Épisode 3 · ${place.distance}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF8C00),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Remove button
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF8C00),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 16,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orange bottom underline
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
  );
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  const _NavIcon({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFFFF8C00) : Colors.grey.shade400,
          size: 26,
        ),
        if (isActive)
          Positioned(
            bottom: -4,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFFF8C00),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error views (kept light-themed to match)
// ─────────────────────────────────────────────────────────────────────────────
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
              color: const Color(0xFFFF8C00).withOpacity(0.08),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 42,
              color: Color(0xFFFF8C00),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun élément en cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à explorer des monuments\npour les retrouver ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

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
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
                  color: const Color(0xFFFF8C00),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Réessayer',
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
