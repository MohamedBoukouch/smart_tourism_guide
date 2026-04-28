import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewsletterSubscribed = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

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

    _updateProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      nameController.text = (data?['username'] as String?) ?? '';
      emailController.text = (data?['email'] as String?) ?? (user.email ?? '');
    } catch (_) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final newName = nameController.text.trim();
      final newEmail = emailController.text.trim();

      await _firestore.collection('users').doc(user.uid).set({
        'username': newName,
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (newName.isNotEmpty && newName != user.displayName) {
        await user.updateDisplayName(newName);
      }

      Get.snackbar(
        "Succès",
        "Profil mis à jour",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      if (newEmail.isNotEmpty && newEmail != user.email) {
        Get.snackbar(
          "Info",
          "L'email sera mis à jour après reconnexion.",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de mettre à jour le profil. Veuillez vous reconnecter puis réessayer.",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}
