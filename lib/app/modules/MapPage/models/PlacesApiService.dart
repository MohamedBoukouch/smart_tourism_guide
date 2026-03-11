import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ── NearbyPlace model ─────────────────────────────────────────────────────────

class NearbyPlace {
  final String placeId;
  final String name;
  final String vicinity;
  final LatLng position;
  final double? rating;
  final int? userRatingsTotal;
  final bool isOpen;
  final String? photoReference;
  final String category;

  const NearbyPlace({
    required this.placeId,
    required this.name,
    required this.vicinity,
    required this.position,
    this.rating,
    this.userRatingsTotal,
    required this.isOpen,
    this.photoReference,
    required this.category,
  });

  factory NearbyPlace.fromOverpass(Map<String, dynamic> json, String category) {
    final lat = (json['lat'] as num).toDouble();
    final lon = (json['lon'] as num).toDouble();
    final tags = json['tags'] as Map<String, dynamic>? ?? {};

    final name =
        tags['name'] ??
        tags['name:en'] ??
        tags['brand'] ??
        _defaultName(category);

    // Build address from available tags
    final parts = <String>[];
    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    final vicinity = parts.isNotEmpty ? parts.join(', ') : 'Nearby';

    // Opening hours
    final openingHours = tags['opening_hours'] as String?;
    final isOpen = openingHours != null
        ? _isCurrentlyOpen(openingHours)
        : false;

    return NearbyPlace(
      placeId: '${json['id']}',
      name: name,
      vicinity: vicinity,
      position: LatLng(lat, lon),
      rating: null, // OSM doesn't have ratings
      userRatingsTotal: null,
      isOpen: isOpen,
      photoReference: null, // OSM doesn't have photos
      category: category,
    );
  }

  static String _defaultName(String category) {
    const names = {
      'restaurant': 'Restaurant',
      'hotels': 'Hotel',
      'pharmacy': 'Pharmacy',
      'museum': 'Museum',
      'park': 'Park',
      'shopping': 'Shop',
      'hospital': 'Hospital',
      'cafe': 'Café',
      'bank': 'Bank',
      'gas': 'Gas Station',
      'supermarket': 'Supermarket',
      'airport': 'Airport',
    };
    return names[category] ?? 'Place';
  }

  // Very simple open/closed check from OSM opening_hours string
  static bool _isCurrentlyOpen(String hours) {
    if (hours == '24/7') return true;
    // Default to unknown = false for simplicity
    return false;
  }
}

// ── RouteResult model ─────────────────────────────────────────────────────────

class RouteResult {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;

  const RouteResult({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });
}

// ── PlacesApiService — 100% FREE using OpenStreetMap ─────────────────────────
//
//  • Nearby search  → Overpass API  (overpass-api.de) — FREE, no key
//  • Routing        → OSRM API      (router.project-osrm.org) — FREE, no key
//  • No API key needed anywhere!

class PlacesApiService {
  // ── OSM amenity/tag mapping ───────────────────────────────────────────────
  static const Map<String, String> _categoryToOsm = {
    'restaurant': 'amenity=restaurant',
    'hotels': 'tourism=hotel',
    'pharmacy': 'amenity=pharmacy',
    'museum': 'tourism=museum',
    'park': 'leisure=park',
    'shopping': 'shop=mall',
    'hospital': 'amenity=hospital',
    'cafe': 'amenity=cafe',
    'bank': 'amenity=bank',
    'gas': 'amenity=fuel',
    'supermarket': 'shop=supermarket',
    'airport': 'aeroway=aerodrome',
  };

  // ── Nearby search via Overpass API ────────────────────────────────────────
  static Future<List<NearbyPlace>> fetchNearby({
    required LatLng location,
    required String categoryId,
    int radiusMeters = 2000,
    int limit = 15,
  }) async {
    final osmTag = _categoryToOsm[categoryId];
    if (osmTag == null) return [];

    // Build Overpass QL query
    final tagParts = osmTag.split('=');
    final key = tagParts[0];
    final value = tagParts[1];

    final query =
        '''
[out:json][timeout:10];
(
  node["$key"="$value"]
    (around:$radiusMeters,${location.latitude},${location.longitude});
  way["$key"="$value"]
    (around:$radiusMeters,${location.latitude},${location.longitude});
);
out center $limit;
''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');

    debugPrint(
      '🔍 Overpass query for $categoryId near ${location.latitude},${location.longitude}',
    );

    try {
      final res = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'data=${Uri.encodeComponent(query)}',
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('❌ Overpass HTTP error: ${res.statusCode}');
        return [];
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final elements = data['elements'] as List? ?? [];

      debugPrint('✅ Overpass found ${elements.length} results');

      return elements
          .where((e) {
            // For ways, use center coordinates
            if (e['type'] == 'way') {
              return e['center'] != null;
            }
            return e['lat'] != null && e['lon'] != null;
          })
          .map((e) {
            // Normalize way center to node format
            if (e['type'] == 'way' && e['center'] != null) {
              return NearbyPlace.fromOverpass({
                'id': e['id'],
                'lat': e['center']['lat'],
                'lon': e['center']['lon'],
                'tags': e['tags'] ?? {},
              }, categoryId);
            }
            return NearbyPlace.fromOverpass(
              e as Map<String, dynamic>,
              categoryId,
            );
          })
          .take(limit)
          .toList();
    } catch (e) {
      debugPrint('❌ Overpass error: $e');
      return [];
    }
  }

  // ── Routing via OSRM (free, no key) ──────────────────────────────────────
  static Future<RouteResult?> getRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking', // walking | driving | cycling
  }) async {
    // OSRM profile mapping
    final profile = mode == 'driving'
        ? 'driving'
        : mode == 'cycling'
        ? 'cycling'
        : 'foot'; // walking

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=false',
    );

    debugPrint('🗺️ OSRM route request: $url');

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      final data = json.decode(res.body) as Map<String, dynamic>;

      debugPrint('📦 OSRM status: ${data['code']}');

      if (data['code'] != 'Ok') return null;

      final route = data['routes'][0];
      final leg = route['legs'][0];
      final coords = route['geometry']['coordinates'] as List;

      // Convert [lon, lat] → LatLng
      final points = coords
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList();

      // Format distance
      final meters = (leg['distance'] as num).toDouble();
      final seconds = (leg['duration'] as num).toDouble();
      final distance = meters >= 1000
          ? '${(meters / 1000).toStringAsFixed(1)} km'
          : '${meters.toInt()} m';
      final duration = seconds >= 3600
          ? '${(seconds / 3600).toStringAsFixed(0)}h ${((seconds % 3600) / 60).toStringAsFixed(0)}min'
          : '${(seconds / 60).toStringAsFixed(0)} min';

      return RouteResult(
        polylinePoints: points,
        distance: distance,
        duration: duration,
      );
    } catch (e) {
      debugPrint('❌ OSRM error: $e');
      return null;
    }
  }

  // OSM doesn't provide photos — return empty string
  static String getPhotoUrl(String ref, {int maxWidth = 400}) => '';
}
