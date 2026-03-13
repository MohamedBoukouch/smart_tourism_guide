import 'package:flutter/material.dart';
import 'package:smart_tourism_guide/app/widgets/logo_text_orange.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LogoTextOrange(height: 30, width: 120), 
        Stack(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage("assets/images/avatar.jpg"),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}