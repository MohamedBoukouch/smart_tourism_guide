import 'package:get/get.dart';

import '../modules/FavoritePage/bindings/favorite_page_binding.dart';
import '../modules/FavoritePage/views/favorite_page_view.dart';
import '../modules/MapPage/bindings/map_page_binding.dart';
import '../modules/MapPage/views/map_page_view.dart';
import '../modules/SettingsPage/bindings/settings_page_binding.dart';
import '../modules/SettingsPage/views/settings_page_view.dart';
import '../modules/cgu/bindings/cgu_binding.dart';
import '../modules/cgu/views/cgu_view.dart';
import '../modules/chatbot/bindings/chatbot_binding.dart';
import '../modules/chatbot/views/chatbot_view.dart';
import '../modules/downloads/bindings/downloads_binding.dart';
import '../modules/downloads/views/downloads_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/forgot_password_binding.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_form_view.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

import '../modules/login/views/forgot_password_view.dart'; // ✅ AJOUTER

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
      name: _Paths.SIGNUP_FORM,
      page: () => const SignupFormView(),
      binding: SignupBinding(),
    ),
    // ✅ NOUVEAU: Route pour Forgot Password
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(), // ✅ binding séparé
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
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.DOWNLOADS,
      page: () => const DownloadsView(),
      binding: DownloadsBinding(),
    ),
    GetPage(
      name: _Paths.CGU,
      page: () => const CguView(),
      binding: CguBinding(),
    ),
    GetPage(
      name: _Paths.CHATBOT,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
  ];
}
