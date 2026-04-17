import 'package:get/get.dart';

import '../controllers/cgu_controller.dart';

class CguBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CguController>(
      () => CguController(),
    );
  }
}
