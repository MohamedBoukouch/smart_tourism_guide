import 'package:flutter/material.dart';
import '../models/city_model.dart';

// ── CityGrid: 2-column wrap grid that matches the design ─────────────────────
class CityGrid extends StatelessWidget {
  final List<CityModel> cities;

  const CityGrid({super.key, required this.cities});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.92, // tall cards like the design
        ),
        itemCount: cities.length,
        itemBuilder: (context, index) => CityCard(city: cities[index]),
      ),
    );
  }
}

// ── Single city card ─────────────────────────────────────────────────────────
class CityCard extends StatelessWidget {
  final CityModel city;

  const CityCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(city.image, fit: BoxFit.cover),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // City name
                Text(
                  city.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                // Visit count row with dot icon
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.redAccent, size: 7),
                    const SizedBox(width: 4),
                    Text(
                      city.visitsLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    // "Débuter la visite" button
                    _StartButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8483A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Débuter la visite',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}