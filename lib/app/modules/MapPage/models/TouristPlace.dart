import 'package:google_maps_flutter/google_maps_flutter.dart';

enum PlaceCategory { touristic, cultural, nature, beach, market, historic }

class TouristPlace {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final String imageAsset;
  final List<String> images;
  final String? videoUrl;
  final String distance;
  final int podcasts;
  final PlaceCategory category;
  final double rating;
  final String openingHours;
  final String address;

  const TouristPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.imageAsset,
    required this.images,
    this.videoUrl,
    required this.distance,
    required this.podcasts,
    required this.category,
    required this.rating,
    required this.openingHours,
    required this.address,
  });
}

// All 5 places within ~3 km of 37.437072, -122.149775 (Palo Alto / Stanford area)
final List<TouristPlace> staticTouristPlaces = [
  TouristPlace(
    id: '1',
    name: 'Bellagio Fountains',
    description:
        'The Bellagio Fountains are one of the most spectacular free shows in Las Vegas. More than 1,000 fountains choreographed to music dance every 15 minutes at night.',
    position: LatLng(37.437072, -122.149775),
    imageAsset: 'assets/images/test_image.png',
    images: ['assets/images/test_image.png'],
    videoUrl: 'https://example.com/videos/bellagio_fountains.mp4',
    distance: '0.3 km',
    podcasts: 7,
    category: PlaceCategory.touristic,
    rating: 4.9,
    openingHours: '15:00 – 00:00',
    address: '3600 S Las Vegas Blvd, Las Vegas, NV 89109',
  ),
  TouristPlace(
    id: '2',
    name: 'Stanford Oval',
    description:
        'The Stanford Oval is a beautiful open green space at the heart of Stanford University campus, surrounded by iconic palm trees and historic sandstone buildings.',
    position: LatLng(37.434900, -122.166200),
    imageAsset: 'assets/images/test_image.png',
    images: ['assets/images/test_image.png'],
    videoUrl: null,
    distance: '1.2 km',
    podcasts: 4,
    category: PlaceCategory.cultural,
    rating: 4.6,
    openingHours: '07:00 – 22:00',
    address: 'Serra Mall, Stanford, CA 94305',
  ),
  TouristPlace(
    id: '3',
    name: 'Palo Alto Baylands',
    description:
        'The Baylands Nature Preserve is one of the largest remaining tracts of marshland in the San Francisco Bay. Ideal for birdwatching, hiking and enjoying the bay views.',
    position: LatLng(37.458300, -122.107800),
    imageAsset: 'assets/images/test_image.png',
    images: ['assets/images/test_image.png'],
    videoUrl: null,
    distance: '2.8 km',
    podcasts: 5,
    category: PlaceCategory.nature,
    rating: 4.7,
    openingHours: '08:00 – 20:00',
    address: '2500 Embarcadero Rd, Palo Alto, CA 94303',
  ),
  TouristPlace(
    id: '4',
    name: 'California Ave Market',
    description:
        'The California Avenue Farmers Market is a vibrant weekly outdoor market offering fresh local produce, artisan goods, gourmet food stalls and live music every Saturday.',
    position: LatLng(37.429500, -122.143100),
    imageAsset: 'assets/images/test_image.png',
    images: ['assets/images/test_image.png'],
    videoUrl: null,
    distance: '0.7 km',
    podcasts: 3,
    category: PlaceCategory.market,
    rating: 4.4,
    openingHours: 'Sat 09:00 – 13:00',
    address: 'California Ave, Palo Alto, CA 94306',
  ),
  TouristPlace(
    id: '5',
    name: 'Hoover Tower',
    description:
        'Standing 87 meters tall, the Hoover Tower is the most recognizable landmark on the Stanford campus. Its observation platform offers panoramic views of the Bay Area and surrounding mountains.',
    position: LatLng(37.426500, -122.167000),
    imageAsset: 'assets/images/test_image.png',
    images: ['assets/images/test_image.png'],
    videoUrl: 'https://example.com/videos/hoover_tower.mp4',
    distance: '1.9 km',
    podcasts: 6,
    category: PlaceCategory.historic,
    rating: 4.8,
    openingHours: '10:00 – 17:00',
    address: 'Serra Mall, Stanford, CA 94305',
  ),
];
