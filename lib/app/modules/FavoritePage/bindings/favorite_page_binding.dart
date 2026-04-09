import 'package:get/get.dart';
import 'package:smart_tourism_guide/app/modules/FavoritePage/controllers/favorite_page_controller.dart';

class FavoritePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritePageController>(() => FavoritePageController());
  }
}
