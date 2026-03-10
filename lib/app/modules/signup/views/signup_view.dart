import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';
import '../widgets/signup_background.dart';
import '../widgets/signup_logo.dart';
import '../widgets/signup_button.dart';
import '../widgets/social_buttons.dart';
import '../widgets/signup_footer.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: const [
                Spacer(),

                SignupLogo(),

                SizedBox(height: 30),

                Text(
                  "Bienvenue",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 15),

                Text(
                  "Êtes-vous prêt à explorer le monde depuis votre téléphone ? "
                  "Connectez-vous et commencez votre visite guidée en vidéo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 35),

                SignupButton(),

                SizedBox(height: 40),

                SocialButtons(),

                SizedBox(height: 25),

                SignupFooter(),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}