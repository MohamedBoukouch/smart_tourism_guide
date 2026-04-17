import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewsletterSubscribed = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewsletter(bool? value) {
    if (value != null) {
      isNewsletterSubscribed.value = value;
    }
  }

  void saveProfile() {
    // Basic validation & save logic here
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Erreur",
        "Les mots de passe ne correspondent pas",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    Get.snackbar(
      "Succès",
      "Profil mis à jour",
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }
}
