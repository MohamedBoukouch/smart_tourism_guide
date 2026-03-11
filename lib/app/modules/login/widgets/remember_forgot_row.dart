import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class RememberForgotRow extends GetView<LoginController> {
  const RememberForgotRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me checkbox
        Obx(() => Row(
          children: [
            Checkbox(
              value: controller.rememberMe.value,
              onChanged: (value) => controller.toggleRememberMe(),
              activeColor: const Color(0xFFFFB300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Text(
              "Se souvenir de moi",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        )),
        
        // Forgot password link
        TextButton(
          onPressed: controller.goToForgotPassword,
          child: const Text(
            "Mot de passe oublié?",
            style: TextStyle(
              color: Color(0xFFFFB300),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}