import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_tourism_guide/app/config/images/app_images.dart';

class PositionLocation extends StatelessWidget {
  final VoidCallback onAuthorize;
  final VoidCallback onDeny;

  const PositionLocation({
    super.key,
    required this.onAuthorize,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: const Color(0xFFF2F2F7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text(
              'Autoriser <Girouette> à\nUtiliser votre position?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Pour utiliser notre application, autorisez-nous à accéder votre position pour une expérience personnalisée et des lieux à proximité.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 16),

          // Map preview with pill and dot
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    AppImages.position_asking,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Blue dot
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
              ),
              // Pill
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.navigation,
                        size: 13,
                        color: Color(0xFF007AFF),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Position exacte : oui',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ✅ Buttons use callbacks passed from controller
          _button('Autoriser une fois', onAuthorize),
          _divider(),
          _button("Autoriser lorsque l'app est active", onAuthorize),
          _divider(),
          _button('Ne pas autoriser', onDeny),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _button(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF007AFF)),
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 0.5, color: Colors.grey[300]);
}
