import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class SignupLink extends GetView<LoginController> {
  const SignupLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Pas encore de compte? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: controller.goToSignup,
          child: const Text(
            "S'inscrire",
            style: TextStyle(
              color: Color(0xFFFFB300),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}