import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/login/controllers/login_controller.dart';


enum LoginInputType {
  email,
  password,
}

class LoginInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final LoginInputType inputType;

  const LoginInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.isPassword = false,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();
    
    // Get the correct controller
    final TextEditingController textController;
    switch (inputType) {
      case LoginInputType.email:
        textController = loginController.emailController;
        break;
      case LoginInputType.password:
        textController = loginController.passwordController;
        break;
    }

    // Pour le mot de passe, on utilise Obx pour l'icône d'eye
    if (inputType == LoginInputType.password) {
      return Obx(() => _buildInputField(
        loginController,
        textController,
        obscureText: loginController.obscurePassword.value,
      ));
    }

    return _buildInputField(loginController, textController, obscureText: false);
  }

  Widget _buildInputField(
    LoginController controller,
    TextEditingController textController, {
    required bool obscureText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB300),
            ),
          ),
        ),
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: textController,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
            ),
            // ✅ CRUCIAL : déclencher la validation à chaque changement
            onChanged: (_) {
              if (inputType == LoginInputType.email) {
                controller.validateEmail();
              } else {
                controller.validatePassword();
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFFFFB300),
                size: 22,
              ),
              suffixIcon: _buildSuffixIcon(controller),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Color(0xFFFFB300),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(LoginController controller) {
    if (inputType == LoginInputType.password) {
      return IconButton(
        icon: Icon(
          controller.obscurePassword.value 
              ? Icons.visibility_off 
              : Icons.visibility,
          color: Colors.grey.shade600,
          size: 22,
        ),
        onPressed: controller.togglePasswordVisibility,
      );
    }
    return null;
  }
}