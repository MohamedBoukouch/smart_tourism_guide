import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:tutor/app/modules/home/controllers/home_controller.dart";

import "../constants/app_constant.dart";
import "../themes/app_theme.dart";

final HomeController home_controller = Get.put(HomeController());
// final SettingController compte_controller = Get.put(SettingController());

class AppFunction {
  AppFunction._();

  static get configureDependencies {
    SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppTheme.main_color_1,
        systemNavigationBarDividerColor: AppTheme.main_color_1,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppTheme.transparent_color,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  static cancel() {
    return TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Get.back();
      },
    );
  }
}
