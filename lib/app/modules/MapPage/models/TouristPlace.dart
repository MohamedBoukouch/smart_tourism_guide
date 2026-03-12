import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PlaceCategory { touristic, cultural, nature, beach, market, historic }

class TouristPlace {
  final String id;
  final String name;
  final String description;
  final List<String> localisation; // [lat, lng] as strings from Firestore
  final String category; // raw string e.g. "nature"
  final double rating;
  final String distance;
  final String openingHours;
  final String imageAsset; // main image URL
  final List<String> images; // gallery image URLs
  final List<String> videoUrls; // video URLs

  // coordinates stored as doubles for convenience
  final double x; // latitude
  final double y; // longitude

  TouristPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.localisation,
    required this.category,
    required this.rating,
    required this.distance,
    required this.openingHours,
    required this.imageAsset,
    required this.images,
    required this.videoUrls,
    required this.x,
    required this.y,
  });

  // ✅ LatLng getter used by the map controller and map view
  LatLng get location => LatLng(x, y);

  // ✅ Parse raw category string → enum
  static PlaceCategory parseCategory(String value) {
    switch (value) {
      case 'touristic':
        return PlaceCategory.touristic;
      case 'cultural':
        return PlaceCategory.cultural;
      case 'nature':
        return PlaceCategory.nature;
      case 'beach':
        return PlaceCategory.beach;
      case 'market':
        return PlaceCategory.market;
      case 'historic':
        return PlaceCategory.historic;
      default:
        return PlaceCategory.touristic;
    }
  }

  // ✅ Factory that builds from a Firestore document
  factory TouristPlace.fromFirestore(String id, Map<String, dynamic> data) {
    final loc = List<dynamic>.from(data['localisation'] ?? []);

    final double x = loc.isNotEmpty
        ? double.tryParse(loc[0].toString()) ?? 0.0
        : 0.0;
    final double y = loc.length > 1
        ? double.tryParse(loc[1].toString()) ?? 0.0
        : 0.0;

    return TouristPlace(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      localisation: loc.map((e) => e.toString()).toList(),
      category: data['category'] as String? ?? 'touristic',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      distance: data['distance'] as String? ?? '',
      openingHours: data['openingHours'] as String? ?? '',
      imageAsset: data['imageAsset'] as String? ?? '',
      images: List<String>.from(data['images'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      x: x,
      y: y,
    );
  }
}
