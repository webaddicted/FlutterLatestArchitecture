import 'dart:convert';

import 'package:pingmexx/data/bean/user/update_profile_req.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:pingmexx/utils/sp/sp_helper.dart';

class SPManager {
  static void setTheme(bool isDark) {
    SPHelper.setPreference(StringConst.prefTheme, isDark);
  }

  static bool getTheme() {
    return SPHelper.getPreference(StringConst.prefTheme, false) ?? false;
  }
  static Future<void> setOnboarding<T>(bool isOnBoardingShow) async {
    await SPHelper.setPreference(StringConst.isOnBoardingShow, isOnBoardingShow);
  }

  static bool? getOnboarding() {
    var spValue = SPHelper.getPreference(StringConst.isOnBoardingShow, false);
    return spValue;
  }
  static void setUserInfo<T>(UpdateProfileReq user) async {
    SPHelper.setPreference(
        StringConst.prefCustomerId, user.customerId.toString());
    SPHelper.setPreference(StringConst.prefName, user.name);
    SPHelper.setPreference(StringConst.prefEmail, user.email);
    SPHelper.setPreference(StringConst.prefDob, user.dob);
    SPHelper.setPreference(StringConst.prefMobile, user.mobile);
    SPHelper.setPreference(StringConst.prefAddress, user.address);
    if (user.customerImage!.isNotEmpty) {
      SPHelper.setPreference(
          StringConst.prefImage, user.customerImage.toString());
    }
  }
  static Future<UpdateProfileReq> getUserInfo<T>() async {
    var customerId =
        await SPHelper.getPreference(StringConst.prefCustomerId, "");
    var name = await SPHelper.getPreference(StringConst.prefName, "");
    var email = await SPHelper.getPreference(StringConst.prefEmail, "");
    var dob = await SPHelper.getPreference(StringConst.prefDob, "");
    var mobile = await SPHelper.getPreference(StringConst.prefMobile, "");
    var address = await SPHelper.getPreference(StringConst.prefAddress, "");
    var password = await SPHelper.getPreference(StringConst.prefPassword, "");
    var image = await SPHelper.getPreference(StringConst.prefImage, "");

    var userInfo = UpdateProfileReq(
        customerId: customerId,
        name: name,
        email: email,
        dob: dob,
        mobile: mobile,
        address: address,
        // password: password,
        customerImage: image);
    print('object userInfo : ${jsonEncode(userInfo)}');
    return userInfo;
  }

  static Future<String?> getCustomerId<T>() async {
    var spValue =
        await SPHelper.getPreference(StringConst.prefCustomerId, "");
    return spValue;
  }

  static void setAccessToken<T>(String token) {
    SPHelper.setPreference(StringConst.prefAccessToken, token);
  }

  static Future<String?> getAccessToken<T>() async {
    var spValue =
        await SPHelper.getPreference(StringConst.prefAccessToken, "");
    return spValue;
  }

  static Future<Set<String>?> getAllKeys() async {
    var spValue = await SPHelper.getAllKeys();
    return spValue;
  }

  static Future<Future<bool>?> removeKeys(String key) async {
    var spValue = await SPHelper.removeKey(key);
    return spValue;
  }

  static Future<Future<bool>?> clearPref() async {
    var spValue = await SPHelper.clearPreference();
    return spValue;
  }
}
