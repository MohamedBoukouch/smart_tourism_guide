import 'package:flutter/material.dart';

class CityList extends StatelessWidget {
  const CityList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CityCard(
            image: "assets/images/paris.jpg",
            city: "Paris",
            visits: "5 visites",
          ),
          CityCard(
            image: "assets/images/bordeaux.jpg",
            city: "Bordeaux",
            visits: "8 visites",
          ),
        ],
      ),
    );
  }
}

class CityCard extends StatelessWidget {
  final String image;
  final String city;
  final String visits;

  const CityCard({
    super.key,
    required this.image,
    required this.city,
    required this.visits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              city,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              visits,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(100, 30),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {},
              child: const Text("Découvrir"),
            )
          ],
        ),
      ),
    );
  }
}