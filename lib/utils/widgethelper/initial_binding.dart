import 'package:get/get.dart';
import 'package:medibot/controller/login_controller.dart';
import 'package:medibot/data/repo/login_repo.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(LoginRepo()), fenix: true);
  }
}
