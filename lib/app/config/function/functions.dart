import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";

import "../constants/app_constant.dart";
import "../themes/app_theme.dart";

// final SettingController compte_controller = Get.put(SettingController());

class AppFunction {
  AppFunction._();

  static void get configureDependencies {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
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

  static TextButton cancel() {
    return TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Get.back();
      },
    );
  }
}
