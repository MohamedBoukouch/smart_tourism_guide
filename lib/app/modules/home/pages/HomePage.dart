import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/explore_slider.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/city_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 12),
            HomeAppBar(),
            SizedBox(height: 20),
            ExploreSlider(),
            SizedBox(height: 20),
            HomeSearchBar(),
            SizedBox(height: 24),
            Text(
              "Explorez par ville",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            CityList(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}