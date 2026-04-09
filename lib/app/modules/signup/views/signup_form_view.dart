import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import '../widgets/signup_logo_text.dart';
import '../widgets/signup_input.dart';
import '../widgets/role_selector.dart';

class SignupFormView extends GetView<SignupController> {
  const SignupFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFB300),
          ),
          onPressed: () => controller.goBack(),
        ),
        title: const SignupLogoText(height: 30, width: 120),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const RoleSelector(),
              const SizedBox(height: 30),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SignupInput(
                        label: "Nom complet",
                        hint: "Entrez votre nom complet",
                        icon: Icons.person_outline,
                        inputType: SignupInputType.name,
                      ),
                      const SizedBox(height: 20),
                      SignupInput(
                        label: "Adresse e-mail",
                        hint: "exemple@email.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        inputType: SignupInputType.email,
                      ),
                      const SizedBox(height: 20),
                      SignupInput(
                        label: "Mot de passe",
                        hint: "Minimum 6 caractères",
                        icon: Icons.lock_outline,
                        obscure: true,
                        inputType: SignupInputType.password,
                      ),
                      const SizedBox(height: 20),
                      SignupInput(
                        label: "Confirmer le mot de passe",
                        hint: "Retapez votre mot de passe",
                        icon: Icons.lock_outline,
                        obscure: true,
                        inputType: SignupInputType.confirmPassword,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
                              
                SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            print("BUTTON CLICKED");
            controller.submitSignup();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "S'inscrire",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}