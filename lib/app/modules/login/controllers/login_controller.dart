import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/config/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // --- FORM STATE ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  final isSubmitting = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  // Validation Rx
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;

  @override
  void onInit() {
    super.onInit();

    // ✅ Ajouter les listeners (pour la validation en temps réel)
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  @override
  void onReady() {
    super.onReady();

    // ✅ FORCER une validation après le retour à l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateEmail();
      _validatePassword();
    });
  }

  // ✅ Rendre ces méthodes publiques pour qu'elles soient accessibles depuis LoginInput
  void _validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = email.isEmail;
  }

  void _validatePassword() {
    final password = passwordController.text;
    isPasswordValid.value = password.length >= 6;
  }

  // ✅ Méthodes publiques pour la validation (appelées par LoginInput)
  void validateEmail() => _validateEmail();
  void validatePassword() => _validatePassword();

  /// --- VALIDATION ---
  bool get isFormValid {
    return isEmailValid.value && isPasswordValid.value;
  }

  /// --- PASSWORD VISIBILITY TOGGLE ---
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// --- REMEMBER ME TOGGLE ---
  void toggleRememberMe() {
    rememberMe.toggle();
  }

  /// --- NAVIGATION ---
  void goToSignup() {
    Get.toNamed(Routes.SIGNUP);
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void goBack() {
    Get.back();
  }

  /// --- LOGIN ---
  Future<void> submitLogin() async {
    if (!isFormValid) return;

    isSubmitting.value = true;

    try {
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Erreur",
        e.message ?? "Erreur de connexion",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// --- CLEAR FORM ---
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    rememberMe.value = false;
    isEmailValid.value = false;
    isPasswordValid.value = false;
  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    super.onClose();
  }
}