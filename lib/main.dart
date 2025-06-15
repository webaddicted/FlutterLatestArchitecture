import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:pingmexx/controller/theme_controller.dart';
import 'package:pingmexx/utils/apiutils/http_overrides.dart';
import 'package:pingmexx/utils/common/app_theme.dart';
import 'package:pingmexx/utils/common/firebase_utility.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/constant/routes.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:pingmexx/utils/sp/sp_helper.dart';
import 'package:pingmexx/utils/widgethelper/initial_binding.dart';
import 'package:pingmexx/view/splash/splash_page.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await Get.putAsync(() => NotificationService().init());
  
  _initLibrary();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}
Future<void> _initLibrary() async {
  await SPHelper.init();
  await dotenv.load();
  var apiKey = dotenv.env['apiKey']??"";
  // if(defaultTargetPlatform==TargetPlatform.android) {
    await initFirebase();
  // }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
        init: ThemeController(),
        builder: (controller) => GetMaterialApp(
            builder: (BuildContext context, Widget? child) {
              final MediaQueryData data = MediaQuery.of(context);
              return MediaQuery(
                data: data.copyWith(
                  textScaler: TextScaler.linear(data.textScaleFactor > 1.2 ? 1.2 : data.textScaleFactor*1.05),
                ),
                child: child!,
              );
            },
            title: StringConst.appName,
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.rightToLeft,
            initialBinding: InitialBinding(),
            theme: lightThemeData(context),
            darkTheme: darkThemeData(context),
            unknownRoute: GetPage(name: RoutersConst.initialRoute, page: () => const SplashPage()),
            themeMode: controller.isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: RoutersConst.initialRoute,
            getPages: routes()));
  }
}
final _noScreenshot = NoScreenshot.instance;

void enableScreenshot() async {
  bool result = await _noScreenshot.screenshotOn();
  debugPrint('Enable Screenshot: $result');
}
void disableScreenshot() async {
  bool result = await _noScreenshot.screenshotOff();
  debugPrint('Screenshot Off: $result');
}
