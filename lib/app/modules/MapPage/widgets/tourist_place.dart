import 'package:google_maps_flutter/google_maps_flutter.dart';

class TouristPlace {
  final String id;
  final String name;
  final String distance;
  final int podcasts;
  final LatLng position;
  final String imageAsset;

  const TouristPlace({
    required this.id,
    required this.name,
    required this.distance,
    required this.podcasts,
    required this.position,
    required this.imageAsset,
  });
}
