import 'package:flutter/material.dart';
import 'package:smart_tourism_guide/app/modules/home/models/slider_model.dart';

class ExploreSlider extends StatefulWidget {
  final List<SlideModel> slides;

  const ExploreSlider({super.key, required this.slides});

  @override
  State<ExploreSlider> createState() => _ExploreSliderState();
}

class _ExploreSliderState extends State<ExploreSlider> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Slide pages ─────────────────────────────────────────────────
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return _SlideCard(slide: slide);
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Dots + arrow row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Dot indicators (left-aligned like the design)
              Row(
                children: List.generate(widget.slides.length, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 5),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFF5A623)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Arrow buttons (right side, matching the design)
              _ArrowButton(
                icon: Icons.chevron_left,
                onTap: _currentIndex > 0
                    ? () => _goTo(_currentIndex - 1)
                    : null,
              ),
              const SizedBox(width: 8),
              _ArrowButton(
                icon: Icons.chevron_right,
                onTap: _currentIndex < widget.slides.length - 1
                    ? () => _goTo(_currentIndex + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Single slide card ────────────────────────────────────────────────────────
class _SlideCard extends StatelessWidget {
  final SlideModel slide;

  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: DecorationImage(
          image: AssetImage(slide.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.65),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              slide.greeting,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              slide.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onPressed: () {},
              child: const Text('Découvrir la visite'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Arrow button ─────────────────────────────────────────────────────────────
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }
}