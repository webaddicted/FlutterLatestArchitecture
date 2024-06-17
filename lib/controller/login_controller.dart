
import 'package:get/get.dart';
import 'package:medibot/data/bean/login/login_respo.dart';
import 'package:medibot/data/repo/login_repo.dart';
import 'package:medibot/utils/apiutils/api_response.dart';
import 'package:medibot/utils/constant/routers_const.dart';
import 'package:medibot/utils/constant/string_const.dart';
import 'package:medibot/utils/widgethelper/widget_helper.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  LoginController(this._loginRepo);

  LoginRepo _loginRepo;

  final callLoginRespo = (ApiResponse<LoginRespo?>()).obs;
  late String customerId;

  authLocal(String emailId, String mobileNo, String currentLat, String currentLong) async {
    callLoginRespo.value = ApiResponse.loading();
    final data = await _loginRepo.fetchLogin(emailId, mobileNo, currentLat, currentLong);
    callLoginRespo.value = data;
    if (callLoginRespo.value.data!.statusCode == "1") {
      customerId = callLoginRespo.value.data!.customerId.toString();
      // Get.toNamed(RoutersConst.otp, arguments: [emailId, mobileNo]);
    } else {
      getSnackbar(
          title: StringConst.error,
          subTitle: callLoginRespo.value.data?.message,
          isSuccess: false);
    }
    // print("LoginRespo : ${callLoginRespo}");
    return data;
  }
}
