import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_tourism_guide/app/widgets/CustomAppBar.dart';
import '../controllers/map_page_controller.dart';

class MapPageView extends GetView<MapPageController> {
  const MapPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapPageController>(
      init: MapPageController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(),
          body: GoogleMap(
            initialCameraPosition: controller.initialPosition,
            polylines: controller.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController ctrl) {
              controller.mapController = ctrl;
            },
          ),
        );
      },
    );
  }
}
