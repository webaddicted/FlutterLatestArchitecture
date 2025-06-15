import 'package:get/get.dart';
import 'package:pingmexx/controller/auth_controller.dart';
import 'package:pingmexx/controller/chat_controller.dart';
import 'package:pingmexx/controller/login_controller.dart';
import 'package:pingmexx/controller/theme_controller.dart';
import 'package:pingmexx/controller/spam_controller.dart';
import 'package:pingmexx/data/repo/login_repo.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(LoginRepo()), fenix: true);
    Get.lazyPut(() => ThemeController(), fenix: true);
    Get.lazyPut(() => SpamController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);

  }
}
