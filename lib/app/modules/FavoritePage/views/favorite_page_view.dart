import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/MapPage/widgets/PlaceCardMarker.dart';

import '../controllers/favorite_page_controller.dart';

class FavoritePageView extends GetView<FavoritePageController> {
  const FavoritePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FavoritePageView'), centerTitle: true),
      body: PlaceCardMarker(
        imagePath: 'assets/images/test_image.png',
        name: 'Favorite Place',
        distance: '2.5 km',
        podcasts: 5,
      ),
    );
  }
}
