import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_tourism_guide/app/config/images/app_images.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/widgets/position_location.dart';

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

class MapPageController extends GetxController {
  GoogleMapController? mapController;

  CameraPosition initialPosition = const CameraPosition(
    target: LatLng(30.427755, -9.598107),
    zoom: 15,
  );

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final Rx<TouristPlace?> selectedPlace = Rx<TouristPlace?>(null);

  LatLng? _myLocation;

  final List<TouristPlace> touristPlaces = const [
    TouristPlace(
      id: '1',
      name: 'Souk El Had',
      distance: '0.9km',
      podcasts: 5,
      position: LatLng(30.4200, -9.6050),
      imageAsset: AppImages.logo,
    ),
    TouristPlace(
      id: '2',
      name: 'Vallée du Paradis',
      distance: '1.2km',
      podcasts: 8,
      position: LatLng(30.4300, -9.5900),
      imageAsset: AppImages.logo,
    ),
    TouristPlace(
      id: '3',
      name: "Plage d'Agadir",
      distance: '2.1km',
      podcasts: 6,
      position: LatLng(30.4150, -9.6100),
      imageAsset: AppImages.logo,
    ),
    TouristPlace(
      id: '4',
      name: 'Kasbah Oufella',
      distance: '3.0km',
      podcasts: 4,
      position: LatLng(30.4350, -9.6200),
      imageAsset: AppImages.logo,
    ),
    TouristPlace(
      id: '5',
      name: "Marina d'Agadir",
      distance: '1.8km',
      podcasts: 3,
      position: LatLng(30.4100, -9.5980),
      imageAsset: AppImages.logo,
    ),
  ];

  @override
  void onReady() {
    super.onReady();
    _askUserLocationPermission();
  }

  void _askUserLocationPermission() {
    Get.dialog(
      PositionLocation(
        onAuthorize: () {
          Get.back();
          _fetchUserLocation();
        },
        onDeny: () {
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _fetchUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission refusée',
        'Activez la localisation dans les paramètres.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _myLocation = LatLng(pos.latitude, pos.longitude);

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(_myLocation!, 15));

    await _buildMarkers(_myLocation!);
    _buildCityBorder(_myLocation!);
    update();
  }

  // ── Zoom controls ──────────────────────────────────────────────────────────
  void zoomIn() async {
    final zoom = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(zoom + 1));
  }

  void zoomOut() async {
    final zoom = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(zoom - 1));
  }

  void dismissCard() => selectedPlace.value = null;

  // ── Markers ────────────────────────────────────────────────────────────────
  Future<void> _buildMarkers(LatLng myLocation) async {
    markers.clear();

    // ✅ SVG icon for user location — fixed pixel size stays same on zoom/dezoom
    final userIcon = await _svgToBitmap(AppImages.map_location, size: 72);
    markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: myLocation,
        icon: userIcon,
        zIndex: 10,
      ),
    );

    // Tourist places yellow teardrop
    final teardrop = await _teardropMarker(const Color(0xFFFFC107));
    for (final place in touristPlaces) {
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: place.position,
          icon: teardrop,
          onTap: () => selectedPlace.value = place,
        ),
      );
    }
  }

  // ── City border ────────────────────────────────────────────────────────────
  void _buildCityBorder(LatLng center) {
    circles.clear();
    circles.add(
      Circle(
        circleId: const CircleId('city_border'),
        center: center,
        radius: 7000,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.04),
      ),
    );
  }

  // ── SVG → BitmapDescriptor (fixed pixel size = same size on any zoom) ──────
  Future<BitmapDescriptor> _svgToBitmap(
    String assetPath, {
    double size = 72,
  }) async {
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(size / pictureInfo.size.width, size / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    pictureInfo.picture.dispose();
    final img = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // ── Yellow teardrop marker ─────────────────────────────────────────────────
  Future<BitmapDescriptor> _teardropMarker(Color color) async {
    const double w = 44, h = 58;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(w / 2, h - 3), width: 20, height: 7),
      Paint()..color = Colors.black26,
    );

    final path = Path()
      ..moveTo(w / 2, h)
      ..quadraticBezierTo(2, h * 0.58, 2, h * 0.37)
      ..arcToPoint(
        Offset(w - 2, h * 0.37),
        radius: const Radius.circular(22),
        clockwise: false,
      )
      ..quadraticBezierTo(w - 2, h * 0.58, w / 2, h)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(w / 2, h * 0.35),
      11,
      Paint()..color = Colors.white,
    );

    final img = await recorder.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
