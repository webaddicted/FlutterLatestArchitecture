import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pingmexx/utils/common/app_theme.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/constant/routes.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:pingmexx/utils/sp/sp_helper.dart';
import 'package:pingmexx/utils/widgethelper/initial_binding.dart';
import 'package:pingmexx/view/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initLibrary();
  runApp(const MyApp());

}
_initLibrary() async {
  await SPHelper.init();
  await dotenv.load();
  var apiKey = dotenv.env['apiKey']??"";
  if(defaultTargetPlatform==TargetPlatform.android) {
    // await initFirebase();
  }
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
