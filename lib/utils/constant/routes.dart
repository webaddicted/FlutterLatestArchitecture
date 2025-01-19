import 'package:get/route_manager.dart';
import 'package:medibot/utils/constant/routers_const.dart';
import 'package:medibot/view/login/login_page.dart';
import 'package:medibot/view/splash/splash_page.dart';
import 'package:medibot/view/widget/pin_view.dart';

routes() => [
      GetPage(name: RoutersConst.initialRoute, page: () => const SplashPage()),
      GetPage(name: RoutersConst.login, page: () => LoginPage()),
      // GetPage(name: RoutersConst.otp, page: () => PinView(submit: submit, count: count)),
    ];
