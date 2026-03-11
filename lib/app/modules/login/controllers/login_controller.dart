import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../domain/models/user.dart';

class LoginController extends GetxController {
  /// --- FORM STATE ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isSubmitting = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  // Ajouter ces Rx pour la validation
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Ajouter des listeners pour mettre à jour la validation en temps réel
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    isEmailValid.value = emailController.text.isEmail;
  }

  void _validatePassword() {
    isPasswordValid.value = passwordController.text.length >= 6;
  }

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

    // TODO: send login request to API / Firebase / Repository
    // await authRepository.login(
    //   emailController.text.trim(),
    //   passwordController.text,
    // );
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isSubmitting.value = false;
    
    // TODO: Navigate to home on success
    // Get.offAllNamed(Routes.HOME);
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
    // Retirer les listeners
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}