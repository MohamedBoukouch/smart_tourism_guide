import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/signup/widgets/signup_logo_text.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_input.dart';

class ForgotPasswordView extends GetView<LoginController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB300)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SignupLogoText(height: 40, width: 150),
              const SizedBox(height: 40),
              
              const Text(
                "Mot de passe oublié?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB300),
                ),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                "Entrez votre email pour recevoir un lien de réinitialisation",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 40),
              
              LoginInput(
                label: "Adresse e-mail",
                hint: "exemple@email.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                inputType: LoginInputType.email,
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Logique pour envoyer l'email de réinitialisation
                    Get.snackbar(
                      'Succès',
                      'Email de réinitialisation envoyé',
                      backgroundColor: const Color(0xFFFFB300),
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "ENVOYER",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}