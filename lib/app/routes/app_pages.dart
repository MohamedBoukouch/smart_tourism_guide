import 'package:get/get.dart';

import '../modules/FavoritePage/bindings/favorite_page_binding.dart';
import '../modules/FavoritePage/views/favorite_page_view.dart';
import '../modules/MapPage/bindings/map_page_binding.dart';
import '../modules/MapPage/views/map_page_view.dart';
import '../modules/SettingsPage/bindings/settings_page_binding.dart';
import '../modules/SettingsPage/views/settings_page_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITE_PAGE,
      page: () => const FavoritePageView(),
      binding: FavoritePageBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS_PAGE,
      page: () => const SettingsPageView(),
      binding: SettingsPageBinding(),
    ),
    GetPage(
      name: _Paths.MAP_PAGE,
      page: () => const MapPageView(),
      binding: MapPageBinding(),
    ),
  ];
}
