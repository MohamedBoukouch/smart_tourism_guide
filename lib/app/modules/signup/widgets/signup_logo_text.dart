import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupLogoText extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;

  const SignupLogoText({
    super.key,
    this.height = 80,
    this.width = 200,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      height: height,
      width: width,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      fit: BoxFit.contain,
    );
  }
}