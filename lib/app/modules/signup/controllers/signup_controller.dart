import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/config/services/auth_service.dart';

import '../../../routes/app_pages.dart';
import '../../../domain/models/user.dart';
import '../../../domain/enums/user_role.dart';

class SignupController extends GetxController {

  /// --- FORM STATE ---
  final role = UserRole.visiteur.obs;

  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // Added

  final isSubmitting = false.obs;
  final obscurePassword = true.obs; // Added for password visibility toggle
  final obscureConfirmPassword = true.obs; // Added for confirm password visibility toggle

  /// --- ROLE ---
  void selectRole(UserRole value) {
    role.value = value;
  }

  /// --- PASSWORD VISIBILITY TOGGLE ---
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  /// --- NAVIGATION ---
  void goToSignupForm() {
    Get.toNamed(Routes.SIGNUP_FORM);
  }

  void goBack() {
    Get.back();
  }

  /// --- VALIDATION ---
  bool get isFormValid {
    return emailController.text.isEmail &&
        usernameController.text.isNotEmpty &&
        passwordController.text.length >= 6 &&
        passwordController.text == confirmPasswordController.text; // Added password match check
  }

  bool get doPasswordsMatch {
    return passwordController.text == confirmPasswordController.text;
  }

  String? get passwordErrorText {
    if (confirmPasswordController.text.isEmpty) return null;
    if (!doPasswordsMatch) return "Les mots de passe ne correspondent pas";
    return null;
  }

  /// --- BUILD USER (équivalent Java: new User(...)) ---
  User buildUser() {
    return User(
      email: emailController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text,
      role: role.value,
    );
  }

  /// --- SUBMIT ---
Future<void> submitSignup() async {
  if (!isFormValid) return;

  isSubmitting.value = true;

  try {
    final user = buildUser();

    await _authService.signup(user);

    // Optional: save username / role later in Firestore
    // (on le fera après)

    Get.offAllNamed(Routes.HOME);
  } on FirebaseAuthException catch (e) {
    Get.snackbar(
      "Erreur",
      e.message ?? "Erreur lors de l'inscription",
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isSubmitting.value = false;
  }
}

  /// --- CLEAR FORM (optional) ---
  void clearForm() {
    emailController.clear();
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    role.value = UserRole.visiteur;
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose(); // Added
    super.onClose();
  }
}