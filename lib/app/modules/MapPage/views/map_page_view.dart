import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/map_page_controller.dart';

class MapPageView extends GetView<MapPageController> {
  const MapPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapPageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MapPageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
