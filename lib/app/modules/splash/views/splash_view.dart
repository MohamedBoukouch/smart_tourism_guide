import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background SVG
          SvgPicture.asset(
            'assets/images/main_bg.svg',
            fit: BoxFit.cover,
          ),

          // Centered logo
          Center(
            child: SvgPicture.asset(
              'assets/images/logo_big.svg',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}