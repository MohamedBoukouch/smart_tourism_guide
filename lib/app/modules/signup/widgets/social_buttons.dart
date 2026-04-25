import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_tourism_guide/app/modules/signup/controllers/signup_controller.dart';
import 'package:get/get.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  Widget socialIcon({
    required String asset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(asset, height: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialIcon(
          asset: "assets/images/gg_icon.svg",
          onTap: controller.signInWithGoogle,
        ),
        const SizedBox(width: 20),
        socialIcon(
          asset: "assets/images/fb_icon.svg",
          onTap: controller.signInWithFacebook,
        ),
                const SizedBox(width: 20),
        socialIcon(
          asset: "assets/images/apple_icon.svg",
          onTap: controller.signInWithFacebook,
        ),
      ],
    );
  }
}