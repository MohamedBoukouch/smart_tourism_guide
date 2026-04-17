import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Local storage init
  await GetStorage.init();

  runApp(
    GetMaterialApp(
      title: "Smart Tourism Guide",
      initialRoute: '/home',
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
