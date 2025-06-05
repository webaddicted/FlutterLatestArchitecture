import 'package:get/route_manager.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/view/home_page/home_page.dart';
import 'package:pingmexx/view/login/login_page.dart';
import 'package:pingmexx/view/splash/onboarding_page.dart';
import 'package:pingmexx/view/splash/splash_page.dart';

List<GetPage> routes() => [
      GetPage(name: RoutersConst.initialRoute, page: () => const SplashPage()),
      GetPage(name: RoutersConst.onboardPage, page: () => OnboardingPage()),
      GetPage(name: RoutersConst.login, page: () => LoginPage()),
      // GetPage(name: RoutersConst.home, page: () => HomePage()),
      // GetPage(name: RoutersConst.otp, page: () => PinView(submit: submit, count: count)),
    ];
