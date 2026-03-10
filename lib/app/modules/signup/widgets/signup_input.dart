import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

enum SignupInputType {
  name,
  email,
  password,
  confirmPassword,
}

class SignupInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final SignupInputType inputType;

  const SignupInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    final signupController = Get.find<SignupController>();
    
    // Get the correct controller
    final TextEditingController textController;
    switch (inputType) {
      case SignupInputType.name:
        textController = signupController.usernameController;
        break;
      case SignupInputType.email:
        textController = signupController.emailController;
        break;
      case SignupInputType.password:
        textController = signupController.passwordController;
        break;
      case SignupInputType.confirmPassword:
        textController = signupController.confirmPasswordController;
        break;
    }

    // For password fields, we need to rebuild when obscure value changes
    if (inputType == SignupInputType.password || inputType == SignupInputType.confirmPassword) {
      return Obx(() => _buildInputField(
        signupController,
        textController,
        obscureText: inputType == SignupInputType.password 
            ? signupController.obscurePassword.value
            : signupController.obscureConfirmPassword.value,
      ));
    }

    // For non-password fields, no need for Obx
    return _buildInputField(signupController, textController, obscureText: obscure);
  }

  Widget _buildInputField(
    SignupController signupController,
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
              suffixIcon: _buildSuffixIcon(signupController),
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

  // Build suffix icon (eye for password fields)
  Widget? _buildSuffixIcon(SignupController signupController) {
    if (inputType == SignupInputType.password) {
      return IconButton(
        icon: Icon(
          signupController.obscurePassword.value 
              ? Icons.visibility_off 
              : Icons.visibility,
          color: Colors.grey.shade600,
          size: 22,
        ),
        onPressed: signupController.togglePasswordVisibility,
      );
    } else if (inputType == SignupInputType.confirmPassword) {
      return IconButton(
        icon: Icon(
          signupController.obscureConfirmPassword.value 
              ? Icons.visibility_off 
              : Icons.visibility,
          color: Colors.grey.shade600,
          size: 22,
        ),
        onPressed: signupController.toggleConfirmPasswordVisibility,
      );
    }
    return null;
  }
}