import 'package:get/get.dart';

class ArPageController extends GetxController {
  // ── Données du lieu (reçues via Get.arguments) ─────────────────────────
  late final String placeName;
  late final String placeCategory;
  late final String historicalFact;
  late final String distance;
  late final String rating;
  late final String openTime;

  // ── États réactifs ──────────────────────────────────────────────────────
  final RxBool cameraReady   = false.obs;
  final RxBool isScanning    = false.obs;
  final RxBool showInfoPanel = false.obs;
  final RxBool hasError      = false.obs;
  final RxString errorMsg    = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    placeName      = args['name']      ?? 'Lieu inconnu';
    placeCategory  = args['category']  ?? 'TOURISTIC';
    historicalFact = args['fact']      ??
        'Ce lieu fait partie du patrimoine culturel de la région. '
            'Pointez votre caméra pour en découvrir l\'histoire.';
    distance  = args['distance'] ?? '-- km';
    rating    = args['rating']   ?? '0.0/5';
    openTime  = args['openTime'] ?? '--:--';
  }

  /// Appelé par la vue quand la caméra est prête.
  void onCameraReady() {
    cameraReady.value = true;
    isScanning.value  = true;
    Future.delayed(const Duration(seconds: 3), () {
      isScanning.value    = false;
      showInfoPanel.value = true;
    });
  }

  /// Appelé par la vue en cas d'erreur caméra.
  void onCameraError(String message) {
    hasError.value = true;
    errorMsg.value = message;
  }
}