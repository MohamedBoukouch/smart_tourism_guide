import 'package:flutter/material.dart';
import 'package:smart_tourism_guide/app/widgets/logo_text_orange.dart';
import 'home_avatar_menu.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        LogoTextOrange(height: 30, width: 120),
        HomeAvatarMenu(),
      ],
    );
  }
}