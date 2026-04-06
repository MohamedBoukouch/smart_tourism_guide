import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/config/services/auth_service.dart';
import 'package:smart_tourism_guide/app/routes/app_pages.dart';


class HomeAvatarMenu extends StatelessWidget {
  const HomeAvatarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await authService.logout();
          Get.offAllNamed(Routes.LOGIN);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text('Se déconnecter'),
            ],
          ),
        ),
      ],
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}