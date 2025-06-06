
import 'dart:convert';

import 'package:get/get.dart';
import 'package:pingmexx/data/bean/login/login_respo.dart';
import 'package:pingmexx/data/repo/login_repo.dart';
import 'package:pingmexx/utils/apiutils/api_response.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  LoginController(this._loginRepo);

  LoginRepo _loginRepo;

  final callLoginRespo = (ApiResponse<LoginRespo?>()).obs;
  late String customerId;

  Future authLocal(String emailId, String mobileNo, String currentLat, String currentLong) async {
    callLoginRespo.value = ApiResponse.loading();
    ApiResponse<LoginRespo?> data = await _loginRepo.fetchLogin(emailId, mobileNo, currentLat, currentLong) ;
    callLoginRespo.value = data ;
    if (callLoginRespo.value.data?.statusCode == "1") {
      customerId = callLoginRespo.value.data!.customerId.toString();
    } else {
      getSnackbar(
          title: StringConst.error,
          subTitle: callLoginRespo.value.status.toString()+callLoginRespo.value.message.toString(),
          isSuccess: false);
    }
    return data;
  }
}
