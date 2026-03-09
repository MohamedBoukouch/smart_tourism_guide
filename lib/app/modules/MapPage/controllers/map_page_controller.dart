import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_tourism_guide/app/config/images/app_images.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/models/TouristPlace.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/widgets/position_location.dart';

class MapPageController extends GetxController {
  GoogleMapController? mapController;

  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(37.379510, -122.104010),
    zoom: 15,
  );

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Circle> circles = <Circle>{}.obs;
  final RxDouble currentZoom = 15.0.obs;

  LatLng? _myLocation;

  List<TouristPlace> get touristPlaces => staticTouristPlaces;

  double get cardScale {
    final scale = 0.08 * (currentZoom.value - 15.0) + 1.0;
    return scale.clamp(0.2, 2.0);
  }

  @override
  void onReady() {
    super.onReady();
    _askUserLocationPermission();
  }

  void onMapCreatedReady() {
    Future.delayed(const Duration(milliseconds: 400), refreshZoom);
  }

  Future<void> refreshZoom() async {
    if (mapController == null) return;
    final zoom = await mapController!.getZoomLevel();
    currentZoom.value = zoom;
  }

  void zoomIn() async {
    final zoom = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(zoom + 1));
  }

  void zoomOut() async {
    final zoom = await mapController?.getZoomLevel() ?? 15.0;
    mapController?.animateCamera(CameraUpdate.zoomTo(zoom - 1));
  }

  void _askUserLocationPermission() {
    Get.dialog(
      PositionLocation(
        onAuthorize: () {
          Get.back();
          _fetchUserLocation();
        },
        onDeny: () => Get.back(),
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
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _myLocation = LatLng(pos.latitude, pos.longitude);
    final userIcon = await _svgToBitmap(AppImages.map_location, size: 72);
    markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: _myLocation!,
        icon: userIcon,
        zIndex: 10,
      ),
    );
    update();
  }

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
}
