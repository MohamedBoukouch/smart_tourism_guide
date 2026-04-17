import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_page_controller.dart';

class SettingsPageView extends GetView<SettingsPageController> {
  const SettingsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.orange),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Section
            const CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=5',
              ), // Placeholder image
            ),
            const SizedBox(height: 12),
            const Text(
              'John Smith',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'johansmith@gmail.com',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.EDIT_PROFILE);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB72B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.orange.shade50,
                    title: 'Mes Téléchargements',
                    onTap: () {
                      Get.toNamed(Routes.DOWNLOADS);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.star_border_rounded,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.orange.shade50,
                    title: 'Noter cette application',
                    onTap: () {
                      Get.snackbar(
                        "Noter l'application",
                        "Cette fonctionnalité sera bientôt disponible : Redirection vers les stores.",
                        backgroundColor: Colors.white,
                        colorText: const Color(0xFF1E293B),
                        icon: const Icon(Icons.star, color: Colors.orange),
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(20),
                        boxShadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.orange.shade50,
                    title: 'Contactcez- nous',
                    onTap: () {
                      Get.defaultDialog(
                        title: "Contactez-nous",
                        titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        content: Column(
                          children: [
                            const Text(
                              "Avez-vous besoin d'aide ? Envoyez-nous un email à :",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "support@girouette.com",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        confirm: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB72B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Fermer",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    iconColor: Colors.deepOrange,
                    iconBgColor: Colors.orange.shade50,
                    title: 'CGU - CGV / POLITIQUE DE CONFIDENTIALITÉ',
                    onTap: () {
                      Get.toNamed(Routes.CGU);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed(Routes.LOGIN);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB72B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .delete();
                            await user.delete();
                            Get.offAllNamed(Routes.LOGIN);
                          }
                        } catch (e) {
                          Get.snackbar(
                            "Erreur",
                            "Veuillez vous reconnecter avant de supprimer votre compte.",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEECE9),
                        foregroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Supprimer mon compte',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.delete_outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
