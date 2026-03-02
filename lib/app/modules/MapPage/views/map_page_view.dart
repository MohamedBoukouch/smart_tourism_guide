import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/controllers/map_page_controller.dart';

class MapPageView extends GetView<MapPageController> {
  const MapPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapPageController>(
      init: MapPageController(),
      builder: (controller) {
        // Define polyline once
        final List<Polyline> myPolyline = [
          const Polyline(
            polylineId: PolylineId("1"),
            color: Colors.red,
            width: 5,
            points: [
              LatLng(30.427755, -9.598107),
              LatLng(34.020882, -6.841650),
            ],
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: const Text("Map Page")),
          body: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.427755, -9.598107),
              zoom: 12,
            ),
            polylines: myPolyline.toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        );
      },
    );
  }
}
