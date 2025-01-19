import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medibot/utils/common/app_theme.dart';
import 'package:medibot/utils/constant/routers_const.dart';
import 'package:medibot/utils/constant/routes.dart';
import 'package:medibot/utils/constant/string_const.dart';
import 'package:medibot/utils/widgethelper/initial_binding.dart';
import 'package:medibot/view/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put(AppController());
    return GetMaterialApp(
      title: StringConst.appName,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeft,
      initialBinding: InitialBinding(),
      unknownRoute:
          GetPage(name: RoutersConst.initialRoute, page: () => SplashPage()),
      // themeMode: ThemeMode.light,
      darkTheme: lightThemeData(context),
      theme: lightThemeData(context),
      initialRoute: RoutersConst.initialRoute,
      getPages: routes(),
    );
  }
}
