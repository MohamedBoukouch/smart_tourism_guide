import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../SettingsPage/controllers/settings_page_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SettingsPageController>(
      () => SettingsPageController(),
      fenix: true,
    );
  }
}
