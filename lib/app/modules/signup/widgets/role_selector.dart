import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/enums/user_role.dart';
import '../controllers/signup_controller.dart';

class RoleSelector extends StatelessWidget { // Changed from GetView
  const RoleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>(); // Add this line
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vous êtes ?",
          style: TextStyle(
            color: Color(0xFFFFB300),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRoleCard(controller, "Guide", UserRole.guide, Icons.tour),
            const SizedBox(width: 15),
            _buildRoleCard(controller, "Visiteur", UserRole.visiteur, Icons.explore),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(SignupController controller, String title, UserRole role, IconData icon) {
    return Expanded(
      child: Obx(() {
        final selected = controller.role.value == role;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 80,
          decoration: BoxDecoration(
            color: selected 
                ? const Color(0xFFFFB300) 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected 
                  ? const Color(0xFFFFB300) 
                  : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.selectRole(role),
              borderRadius: BorderRadius.circular(16),
              splashColor: const Color(0xFFFFB300).withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: selected ? Colors.white : Colors.grey.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade700,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}