import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupLogo extends StatelessWidget {
  const SignupLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/logo_big.svg",
      height: 180,
    );
  }
}