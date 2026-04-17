import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cgu_controller.dart';

class CguView extends GetView<CguController> {
  const CguView({super.key});

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
          children: const [
            Text(
              "CONDITIONS GENERALES D'UTILISATION ET DE VENTE",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '''Article 1 - Objet des conditions générales
Girouette est une société par actions simplifiée au capital de 10.000 euros, immatriculée au Registre du Commerce et des Sociétés de Lyon sous le numéro 892 816 901, dont le siège social est situé 8 chemin Louis Chirpaz, Bâtiment Rameau, 69130 Ecully (« Girouette » ou la « Société »).

La Société a développé, exploite et commercialise une application mobile (l'« Application ») dans les domaines touristiques et culturels. Dans ce cadre, la Société propose aux utilisateurs de l'Application (les « Utilisateurs ») des visites touristiques audioguidées sous forme de balades historiques et insolites, exclusivement en extérieur (la « Balade » ou les « Balades »).

Toute personne qui accède à l'Application s'engage à respecter, sans réserve, les présentes conditions générales qui valent conditions générales d'utilisation et conditions générales de vente (les « Conditions Générales »).

Elles sont soumises à l'acceptation de l'Utilisateur avant toute utilisation de l'Application.''',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
