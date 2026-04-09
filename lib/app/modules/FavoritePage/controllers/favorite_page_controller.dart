import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';

class FavoritePageController extends GetxController {
  final RxList<TouristPlace> favorites = <TouristPlace>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Currently signed-in user's UID. Adjust if you use a different auth flow.
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onReady() {
    super.onReady();
    fetchFavorites();
  }

  // ── Fetch all favorites for the current user ──────────────────────────────
  //
  // Firestore structure expected:
  //   users/{uid}/favorites/{placeId}   →  same fields as places/{placeId}
  //
  // OR (flat approach) — store only placeId strings, then look up each place:
  //   users/{uid}/favorites/{placeId}  →  { placeId: "abc123" }
  //   places/{placeId}                 →  full place document
  //
  // This controller uses the FLAT approach so each favorite document only
  // stores `{ placeId: "..." }`, and we look up the full place from /places.
  // That way a single source of truth exists for place data.
  Future<void> fetchFavorites() async {
    if (_uid == null) {
      errorMessage.value = 'Please sign in to see your favorites.';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Get list of saved place IDs
      final favSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('favorites')
          .get();

      if (favSnapshot.docs.isEmpty) {
        favorites.clear();
        isLoading.value = false;
        return;
      }

      final placeIds = favSnapshot.docs
          .map((d) => d.data()['placeId'] as String? ?? d.id)
          .toList();

      // 2. Fetch actual place documents in one batched call
      //    Firestore `whereIn` supports up to 30 items per query.
      final List<TouristPlace> loaded = [];
      for (int i = 0; i < placeIds.length; i += 30) {
        final chunk = placeIds.sublist(
          i,
          i + 30 > placeIds.length ? placeIds.length : i + 30,
        );
        final placesSnap = await FirebaseFirestore.instance
            .collection('places')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in placesSnap.docs) {
          loaded.add(TouristPlace.fromFirestore(doc.id, doc.data()));
        }
      }

      favorites.value = loaded;
    } catch (e) {
      errorMessage.value = 'Could not load favorites: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Toggle favorite (add / remove) ───────────────────────────────────────
  Future<void> toggleFavorite(TouristPlace place) async {
    if (_uid == null) {
      Get.snackbar(
        'Sign in required',
        'Please sign in to save favorites.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(place.id);

    final isFav = favorites.any((p) => p.id == place.id);

    if (isFav) {
      await ref.delete();
      favorites.removeWhere((p) => p.id == place.id);
      Get.snackbar(
        'Removed',
        '${place.name} removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      await ref.set({'placeId': place.id});
      favorites.add(place);
      Get.snackbar(
        '❤️ Saved',
        '${place.name} added to favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B35),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isFavorite(String placeId) => favorites.any((p) => p.id == placeId);
}
