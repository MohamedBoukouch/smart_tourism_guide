import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _next();
  }

  Future<void> _next() async {

    await Future.delayed(const Duration(seconds: 2));

    bool firstLaunch = box.read('firstLaunch') ?? true;
    User? user = _auth.currentUser;

    // 1️⃣ First time opening the app
    // if (firstLaunch) {
    //   box.write('firstLaunch', false);
    //   Get.offAllNamed(Routes.SIGNUP);
    //   return;
    // }

    // // 2️⃣ User already logged in
    // if (user != null) {
    //   Get.offAllNamed(Routes.HOME);
    //   return;
    // }

    // // 3️⃣ User not logged in
    // Get.offAllNamed(Routes.LOGIN);

    Get.offAllNamed(Routes.SIGNUP);
  }
}