import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medibot/utils/sp/sp_manager.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  bool isDark = false;

  @override
  void onInit() async {
    super.onInit();
    isDark = SPManager.getTheme();
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void changeTheme(bool isDarks) async {
    isDark = isDarks;
    await SPManager.setTheme(isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    update();
  }
}
