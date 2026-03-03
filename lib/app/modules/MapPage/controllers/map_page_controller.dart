import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPageController extends GetxController {
  // Google Map controller
  GoogleMapController? mapController;

  // Initial camera position
  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(30.427755, -9.598107),
    zoom: 12,
  );

  // Polylines
  final Set<Polyline> polylines = {};

  @override
  void onInit() {
    super.onInit();
    addPolyline();
  }

  void addPolyline() {
    polylines.add(
      const Polyline(
        polylineId: PolylineId("route1"),
        color: Colors.red,
        width: 5,
        points: [LatLng(30.427755, -9.598107), LatLng(34.020882, -6.841650)],
      ),
    );
    update(); // update GetBuilder
  }
}
