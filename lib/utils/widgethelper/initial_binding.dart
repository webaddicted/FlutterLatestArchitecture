import 'package:get/get.dart';
import 'package:pingmexx/controller/login_controller.dart';
import 'package:pingmexx/controller/theme_controller.dart';
import 'package:pingmexx/data/repo/login_repo.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(LoginRepo()), fenix: true);
    Get.lazyPut(() => ThemeController(), fenix: true);
  }
}
