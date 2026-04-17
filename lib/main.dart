import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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
      builder: (context, child) {
        return Scaffold(
          // Inner pages will render inside this navigator
          body: child ?? const SizedBox.shrink(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: FloatingActionButton(
              heroTag: "global_chatbot_btn",
              backgroundColor: const Color(0xFFFFB72B),
              elevation: 6,
              onPressed: () {
                // Avoid opening a new chatbot if we are already inside the chatbot view
                if (Get.currentRoute != '/chatbot') {
                  Get.toNamed('/chatbot');
                }
              },
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    ),
  );
}
