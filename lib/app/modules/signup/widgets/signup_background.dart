import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupBackground extends StatelessWidget {
  final Widget child;

  const SignupBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            "assets/images/main_bg.svg",
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}