import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_tourism_guide/app/config/images/app_images.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/PlacesApiService.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';

class MapPageController extends GetxController {
  GoogleMapController? mapController;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(37.437072, -122.149775),
    zoom: 15,
  );

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxDouble currentZoom = 15.0.obs;

  // ✅ Tourist places loaded from Firestore
  final RxList<TouristPlace> _touristPlaces = <TouristPlace>[].obs;
  List<TouristPlace> get touristPlaces => _touristPlaces;

  final RxString routeDistance = ''.obs;
  final RxString routeDuration = ''.obs;
  final RxBool hasRoute = false.obs;
  final RxBool isNavigating = false.obs;
  final RxBool followCamera = true.obs;

  LatLng? _destination;
  String _destinationName = '';
  LatLng? currentLocation;
  StreamSubscription? _locationSub;
  BitmapDescriptor? _userIcon;

  double get cardScale {
    final scale = 0.08 * (currentZoom.value - 15.0) + 1.0;
    return scale.clamp(0.2, 2.0);
  }

  @override
  void onReady() {
    super.onReady();
    _fetchPlacesFromFirestore();
    _fetchUserLocation();
  }

  @override
  void onClose() {
    _locationSub?.cancel();
    super.onClose();
  }

  // ── Fetch from Firestore ──────────────────────────────────────────────────
  Future<void> _fetchPlacesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .get();

      // ✅ explicit <TouristPlace> type parameter fixes the List<dynamic> error
      _touristPlaces.value = snapshot.docs
          .map<TouristPlace>(
            (doc) => TouristPlace.fromFirestore(doc.id, doc.data()),
          )
          .toList();

      update();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les lieux : $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onMapCreatedReady() =>
      Future.delayed(const Duration(milliseconds: 400), refreshZoom);

  Future<void> refreshZoom() async {
    if (mapController == null) return;
    currentZoom.value = await mapController!.getZoomLevel();
  }

  void zoomIn() async {
    final z = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(z + 1));
  }

  void zoomOut() async {
    final z = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(z - 1));
  }

  void onMapTapped() {
    if (isNavigating.value) followCamera.value = false;
  }

  // ── NearbyPlace navigation (from MapFilter — PlacesApiService model) ──────
  // NearbyPlace.position is a LatLng field
  Future<void> moveToNearbyPlace(NearbyPlace place) async {
    _destination = place.position;
    _destinationName = place.name;
    await _dropDestinationPin(place.position, place.name);
    if (currentLocation != null) {
      await _drawRoute(currentLocation!, place.position);
      _fitBounds([currentLocation!, place.position]);
    }
  }

  // ── TouristPlace navigation (from Firestore / map cards) ─────────────────
  // TouristPlace.location is a LatLng getter (LatLng(x, y))
  Future<void> moveToPlace(TouristPlace place) async {
    _destination = place.location;
    _destinationName = place.name;
    await _dropDestinationPin(place.location, place.name);
    if (currentLocation != null) {
      await _drawRoute(currentLocation!, place.location);
      _fitBounds([currentLocation!, place.location]);
    }
  }

  void startNavigation() {
    if (_destination == null) return;
    isNavigating.value = true;
    followCamera.value = true;
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 8,
      ),
    ).listen(_onLocationUpdate);
  }

  void stopNavigation() {
    _locationSub?.cancel();
    _locationSub = null;
    isNavigating.value = false;
    followCamera.value = false;
    _destination = null;
    _destinationName = '';
    clearRoute();
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 15,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    }
  }

  void fitRoute() {
    followCamera.value = true;
    if (currentLocation != null && _destination != null) {
      _fitBounds([currentLocation!, _destination!]);
    } else if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation!, zoom: 18, tilt: 60),
        ),
      );
    }
  }

  Future<void> _onLocationUpdate(Position pos) async {
    currentLocation = LatLng(pos.latitude, pos.longitude);
    _updateUserMarker(currentLocation!, pos.heading);
    if (_destination == null) return;

    final dist = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      _destination!.latitude,
      _destination!.longitude,
    );

    if (dist <= 25) {
      _onArrived();
      return;
    }

    await _drawRoute(currentLocation!, _destination!);

    if (followCamera.value) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 18,
            tilt: 55,
            bearing: pos.heading,
          ),
        ),
      );
    }
  }

  void _updateUserMarker(LatLng pos, double heading) {
    markers.removeWhere((m) => m.markerId.value == 'me');
    markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: pos,
        icon:
            _userIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 10,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        rotation: heading,
      ),
    );
  }

  void _onArrived() {
    _locationSub?.cancel();
    isNavigating.value = false;
    Get.snackbar(
      '🎉  Arrived!',
      'You have reached $_destinationName',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
    );
    clearRoute();
    if (currentLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 16,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng dest) async {
    final result = await PlacesApiService.getRoute(
      origin: origin,
      destination: dest,
      mode: 'walking',
    );
    if (result == null) return;
    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route_shadow'),
        points: result.polylinePoints,
        color: Colors.grey.shade300,
        width: 9,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: result.polylinePoints,
        color: const Color(0xFFFF6B35),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
    routeDistance.value = result.distance;
    routeDuration.value = result.duration;
    hasRoute.value = true;
  }

  void clearRoute() {
    polylines.clear();
    markers.removeWhere((m) => m.markerId.value == 'destination');
    hasRoute.value = false;
    routeDistance.value = '';
    routeDuration.value = '';
  }

  void _fitBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        90,
      ),
    );
  }

  Future<void> _dropDestinationPin(LatLng pos, String title) async {
    markers.removeWhere((m) => m.markerId.value == 'destination');
    final icon = await _buildOrangePin();
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: pos,
        icon: icon,
        infoWindow: InfoWindow(title: title),
        zIndex: 5,
      ),
    );
  }

  Future<BitmapDescriptor> _buildOrangePin() async {
    const double w = 44, h = 58;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, h - 3), width: 20, height: 7),
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
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF6B35));
    canvas.drawCircle(
      Offset(w / 2, h * 0.35),
      12,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w / 2, h * 0.35),
      5,
      Paint()..color = const Color(0xFFFF6B35),
    );
    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _fetchUserLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission refusée',
        'Activez la localisation dans les paramètres.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLocation = LatLng(pos.latitude, pos.longitude);

    try {
      _userIcon = await _svgToBitmap(AppImages.map_location, size: 72);
    } catch (_) {
      _userIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: currentLocation!,
        icon: _userIcon!,
        zIndex: 10,
        flat: true,
        anchor: const Offset(0.5, 0.5),
      ),
    );

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation!, zoom: 15),
      ),
    );
    update();
  }

  Future<BitmapDescriptor> _svgToBitmap(
    String assetPath, {
    double size = 72,
  }) async {
    final info = await vg.loadPicture(SvgAssetLoader(assetPath), null);
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.scale(size / info.size.width, size / info.size.height);
    canvas.drawPicture(info.picture);
    info.picture.dispose();
    final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
