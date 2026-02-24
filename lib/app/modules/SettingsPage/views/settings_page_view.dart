import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/settings_page_controller.dart';

class SettingsPageView extends GetView<SettingsPageController> {
  const SettingsPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingsPageView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SettingsPageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
