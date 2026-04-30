import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ar_page_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Vue principale (GetView)
// ─────────────────────────────────────────────────────────────────────────────
class ArPageView extends GetView<ArPageController> {
  const ArPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _ArBody(ctrl: controller),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatefulWidget : gère le CameraController
// ─────────────────────────────────────────────────────────────────────────────
class _ArBody extends StatefulWidget {
  final ArPageController ctrl;
  const _ArBody({required this.ctrl});

  @override
  State<_ArBody> createState() => _ArBodyState();
}

class _ArBodyState extends State<_ArBody> with WidgetsBindingObserver {
  CameraController? _cam;
  bool _disposed = false;

  ArPageController get c => widget.ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cam == null || !_cam!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cam!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        c.onCameraError('Aucune caméra disponible sur cet appareil.');
        return;
      }
      _cam = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cam!.initialize();
      if (!_disposed && mounted) {
        setState(() {});
        c.onCameraReady();
      }
    } catch (e) {
      c.onCameraError('Impossible d\'accéder à la caméra.\n$e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Erreur ────────────────────────────────────────────────────────
      if (c.hasError.value) {
        return _ErrorScreen(message: c.errorMsg.value);
      }

      // ── Chargement caméra ─────────────────────────────────────────────
      if (!c.cameraReady.value || _cam == null || !_cam!.value.isInitialized) {
        return const _LoadingScreen();
      }

      // ── Vue AR ────────────────────────────────────────────────────────
      return Stack(
        fit: StackFit.expand,
        children: [
          // 1. Flux caméra
          CameraPreview(_cam!),

          // 2. Grille AR en fond
          const _GridOverlay(),

          // 3. Animation de scan
          if (c.isScanning.value) const _ScanAnimation(),

          // 4. Panel d'info
          if (c.showInfoPanel.value) _InfoPanel(c: c),

          // 5. Header
          _Header(placeName: c.placeName),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
        SizedBox(height: 16),
        Text(
          'Initialisation AR...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined,
              color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Get.back(),
            child:
            const Text('Retour', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

// Grille orange transparente
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.06,
    child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.orange
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Animation de scan avec ligne qui descend
class _ScanAnimation extends StatefulWidget {
  const _ScanAnimation();
  @override
  State<_ScanAnimation> createState() => _ScanAnimationState();
}

class _ScanAnimationState extends State<_ScanAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _line;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _line = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          children: [
            // Coins orange
            CustomPaint(painter: _CornerPainter()),
            // Ligne animée
            AnimatedBuilder(
              animation: _line,
              builder: (_, __) => Positioned(
                top: _line.value * 220,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Colors.orange.withOpacity(0.85),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
            // Texte "Détection AR..."
            Positioned(
              bottom: -36,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                            color: Colors.orange, strokeWidth: 1.5),
                      ),
                      SizedBox(width: 8),
                      Text('Détection AR en cours...',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 24.0;
    // haut-gauche
    canvas.drawLine(Offset.zero, const Offset(l, 0), p);
    canvas.drawLine(Offset.zero, const Offset(0, l), p);
    // haut-droit
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), p);
    // bas-gauche
    canvas.drawLine(Offset(0, size.height), Offset(l, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - l), p);
    // bas-droit
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - l, size.height), p);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - l), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Panel d'informations AR (slide-up animé)
class _InfoPanel extends StatelessWidget {
  final ArPageController c;
  const _InfoPanel({required this.c});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 36,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - v)), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge catégorie
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: Colors.orange.withOpacity(0.6)),
                ),
                child: Text(
                  c.placeCategory.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              // Nom
              Text(
                c.placeName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(height: 0.5, color: Colors.white24),
              const SizedBox(height: 12),
              // Fait historique
              Text(
                c.historicalFact,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.6),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(Icons.directions_walk_rounded, c.distance,
                      'Distance'),
                  _VDiv(),
                  _Stat(Icons.star_rounded, c.rating, 'Rating'),
                  _VDiv(),
                  _Stat(Icons.access_time_rounded, c.openTime, 'Opens'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.orange, size: 18),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      Text(label,
          style:
          const TextStyle(color: Colors.white38, fontSize: 10)),
    ],
  );
}

class _VDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 0.5, height: 36, color: Colors.white24);
}

// Header : bouton retour + badge AR LIVE
class _Header extends StatelessWidget {
  final String placeName;
  const _Header({required this.placeName});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 7),
                SizedBox(width: 6),
                Text('AR LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}