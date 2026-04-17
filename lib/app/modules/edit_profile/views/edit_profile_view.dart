import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.indigo,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.orange),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group_outlined, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mon Compte',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(
              hint: 'Votre nom et prénom',
              icon: Icons.person_outline,
              controller: controller.nameController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              hint: 'Email Adresse',
              icon: Icons.mail_outline,
              controller: controller.emailController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              hint: 'Nouveau mot de passe',
              icon: Icons.lock_outline,
              isPassword: true,
              controller: controller.passwordController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              hint: 'Confirmation mot de passe',
              icon: Icons.lock_outline,
              isPassword: true,
              controller: controller.confirmPasswordController,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Obx(
                    () => Checkbox(
                      value: controller.isNewsletterSubscribed.value,
                      onChanged: controller.toggleNewsletter,
                      activeColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Je souhaite recevoir la newsletter de Girouette et être informé des nouveautés',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB72B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}
