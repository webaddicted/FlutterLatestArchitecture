import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:medibot/data/bean/login/login_req.dart';
import 'package:medibot/data/bean/login/login_respo.dart';
import 'package:medibot/utils/apiutils/api_base_helper.dart';
import 'package:medibot/utils/apiutils/api_response.dart';
import 'package:medibot/utils/constant/api_constant.dart';

class LoginRepo {
  fetchLogin(String emailId, String mobile, String currentLat,
      String currentLong) async {
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
    // print("object  response   :   $respo");
    return ApiResponse.returnResponse(
        response,
        response.data == null
            ? null
            : LoginRespo.fromJson(jsonDecode(response.toString())));
  }
}
