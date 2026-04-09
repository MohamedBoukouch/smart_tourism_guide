import 'package:flutter/material.dart';

import '../models/city_model.dart';
import '../models/slider_model.dart';
import '../widgets/city_card.dart';
import '../widgets/explore_slider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ── Swap these out for real API data later ──────────────────────────────
  static final List<SlideModel> _slides = [
    SlideModel(
      image: 'assets/images/paris.jpg',
      greeting: 'Bonjour',
      title: 'Explorez Paris',
    ),
    SlideModel(
      image: 'assets/images/bordeaux.jpg',
      greeting: 'Bonjour',
      title: 'Explorez Bordeaux',
    ),
  ];

  static final List<CityModel> _cities = [
    CityModel(image: 'assets/images/paris.jpg', name: 'Paris', visitCount: 5),
    CityModel(
      image: 'assets/images/bordeaux.jpg',
      name: 'Bordeaux',
      visitCount: 8,
    ),
  ];
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── App Bar ──────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeAppBar(),
            ),
            const SizedBox(height: 20),

            // ── Hero Slider (full-width, bleeds to edges) ────────────────
            ExploreSlider(slides: _slides),
            const SizedBox(height: 20),

            // ── Search Bar ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeSearchBar(),
            ),
            const SizedBox(height: 24),

            // ── Section Title ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explorez par ville',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // ── City Grid ────────────────────────────────────────────────
            CityGrid(cities: _cities),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
