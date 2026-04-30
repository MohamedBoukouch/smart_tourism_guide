import 'package:get/get.dart';
import '../controllers/ar_page_controller.dart';

class ArPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArPageController>(() => ArPageController());
  }
}