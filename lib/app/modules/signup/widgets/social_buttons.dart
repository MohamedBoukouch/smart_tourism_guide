import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  Widget socialIcon(String asset) {
    return Container(
      height: 50,
      width: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          height: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialIcon("assets/images/google_icon.svg"),
        const SizedBox(width: 20),
        socialIcon("assets/images/fb_icon.svg"),
        const SizedBox(width: 20),
        socialIcon("assets/images/apple_icon.svg"),
      ],
    );
  }
}