import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:pingmexx/data/bean/login/login_req.dart';
import 'package:pingmexx/data/bean/login/login_respo.dart';
import 'package:pingmexx/utils/apiutils/api_base_helper.dart';
import 'package:pingmexx/utils/apiutils/api_response.dart';
import 'package:pingmexx/utils/constant/api_constant.dart';

class LoginRepo {
  Future<ApiResponse<LoginRespo>> fetchLogin(String emailId, String mobile,
      String currentLat, String currentLong) async {
    try {
      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        deviceId = info.id;
      } else {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.utsname.machine;
      }
      var req = LoginReq(
          email: emailId,
          mobile: mobile,
          deviceId: deviceId,
          fcmToken: "",
          referCode: '',
          latitude: currentLat,
          longitude: currentLong);
      final response = await apiHelper.post(
          url: ApiConstant.customerLogin, params: req.toJson());
      return ApiResponse.handleResponse<LoginRespo>(
        response: response,
        fromJson: (json) => LoginRespo.fromJson(json),
      );
    } catch (e) {
      var error = e.toString();
      if (ApiConstant.isDebug) {
        error = "${ApiConstant.customerLogin}$error";
      }
      return ApiResponse<LoginRespo>(
          status: ApiStatus.error, statusCode: -1, message: error);
    }
  }
}
