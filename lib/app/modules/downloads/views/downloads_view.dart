import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/downloads_controller.dart';

class DownloadsView extends GetView<DownloadsController> {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB72B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Mes Téléchargements',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Mock List of Downloads
            _buildDownloadCard(),
            const SizedBox(height: 16),
            _buildDownloadCard(),
            const SizedBox(height: 16),
            _buildDownloadCard(),
            const SizedBox(height: 16),
            _buildDownloadCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/seed/picsum/150/150',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                const Text(
                  "L'histoire De La Galerie",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Épisode 3 : 4 minutes',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade200, width: 1.5),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
