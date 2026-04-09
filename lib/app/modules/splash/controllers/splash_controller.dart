import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final box = GetStorage();
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();

    // Small splash delay (UX only)
    Future.delayed(const Duration(seconds: 2), () {
      _handleNavigation();
    });
  }

  void _handleNavigation() {
    final bool firstLaunch = box.read('firstLaunch') ?? true;

    // 1️⃣ First launch → Signup / Onboarding
    if (firstLaunch) {
      box.write('firstLaunch', false);
      Get.offAllNamed(Routes.SIGNUP);
      return;
    }

    // 2️⃣ Listen to Firebase auth state (BEST PRACTICE)
    _auth.authStateChanges().listen((fb.User? user) {
      if (user != null) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
}