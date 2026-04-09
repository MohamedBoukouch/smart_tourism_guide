import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_input.dart';
import 'remember_forgot_row.dart';
import '../controllers/login_controller.dart';

class LoginForm extends GetView<LoginController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginInput(
          label: "Adresse e-mail",
          hint: "exemple@email.com",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          inputType: LoginInputType.email,
        ),
        const SizedBox(height: 20),
        
        LoginInput(
          label: "Mot de passe",
          hint: "Entrez votre mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
          inputType: LoginInputType.password,
        ),
        const SizedBox(height: 10),
        
        const RememberForgotRow(),
      ],
    );
  }
}