import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged; // hook for future search logic

  const HomeSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Search field ─────────────────────────────────────────────────
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Recherche',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ── Filter button ─────────────────────────────────────────────────
        GestureDetector(
          onTap: () {
            // wire up filter sheet here
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.black54,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}