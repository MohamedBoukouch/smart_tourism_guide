import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/config/images/app_images.dart';

class MapLocation extends StatelessWidget {
  const MapLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF5F5F5),
        ),
        child: Center(
          child: SvgPicture.asset(
            AppImages.map_location,
            width: 18,
            height: 18,
          ),
        ),
      ),
    );
  }
}
