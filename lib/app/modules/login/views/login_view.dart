import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/login/widgets/LoginAppBar.dart';
import 'package:smart_tourism_guide/app/modules/login/widgets/login_button.dart';
import 'package:smart_tourism_guide/app/modules/login/widgets/login_form.dart';
import 'package:smart_tourism_guide/app/modules/login/widgets/login_header.dart';
import 'package:smart_tourism_guide/app/modules/login/widgets/signup_link.dart';
import 'package:smart_tourism_guide/app/modules/signup/widgets/signup_logo_text.dart';
import '../controllers/login_controller.dart';


class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const LoginAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Logo
              const SignupLogoText(height: 30, width: 120),
              
              const SizedBox(height: 30),
              
              // Header avec titre
              const LoginHeader(),
              
              const SizedBox(height: 30),
              
              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  child: const LoginForm(),
                ),
              ),
              
              // Bouton de connexion
              const LoginButton(),
              
              const SizedBox(height: 20),
              
              // Lien d'inscription
              const SignupLink(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}