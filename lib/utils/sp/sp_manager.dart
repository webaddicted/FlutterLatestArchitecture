import 'dart:convert';

import 'package:pingmexx/data/bean/user/update_profile_req.dart';
import 'package:pingmexx/data/bean/user/user_model.dart';
import 'package:pingmexx/utils/constant/sp_constant.dart';
import 'package:pingmexx/utils/sp/sp_helper.dart';

class SPManager {
  static void setTheme(bool isDark) {
    SPHelper.setPreference(SPConstant.prefTheme, isDark);
  }

  static bool getTheme() {
    return SPHelper.getPreference(SPConstant.prefTheme, false) ?? false;
  }

  static Future<void> setOnboarding<T>(bool isOnBoardingShow) async {
    await SPHelper.setPreference(SPConstant.isOnBoardingShow, isOnBoardingShow);
  }

  static bool? getOnboarding() {
    var spValue = SPHelper.getPreference(SPConstant.isOnBoardingShow, false);
    return spValue;
  }

  static void setUserInfo<T>(UpdateProfileReq user) async {
    SPHelper.setPreference(
        SPConstant.prefCustomerId, user.customerId.toString());
    SPHelper.setPreference(SPConstant.prefName, user.name);
    SPHelper.setPreference(SPConstant.prefEmail, user.email);
    SPHelper.setPreference(SPConstant.prefDob, user.dob);
    SPHelper.setPreference(SPConstant.prefMobile, user.mobile);
    SPHelper.setPreference(SPConstant.prefAddress, user.address);
    if (user.customerImage!.isNotEmpty) {
      SPHelper.setPreference(
          SPConstant.prefImage, user.customerImage.toString());
    }
  }

  static Future<UpdateProfileReq> getUserInfo<T>() async {
    var customerId =
        SPHelper.getPreference(SPConstant.prefCustomerId, "");
    var name = SPHelper.getPreference(SPConstant.prefName, "");
    var email = SPHelper.getPreference(SPConstant.prefEmail, "");
    var dob = SPHelper.getPreference(SPConstant.prefDob, "");
    var mobile = SPHelper.getPreference(SPConstant.prefMobile, "");
    var address = SPHelper.getPreference(SPConstant.prefAddress, "");
    var password = SPHelper.getPreference(SPConstant.prefPassword, "");
    var image = SPHelper.getPreference(SPConstant.prefImage, "");

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
        SPHelper.getPreference(SPConstant.prefCustomerId, "");
    return spValue;
  }

  static void setAccessToken<T>(String token) {
    SPHelper.setPreference(SPConstant.prefAccessToken, token);
  }

  static Future<String?> getAccessToken<T>() async {
    var spValue =
        SPHelper.getPreference(SPConstant.prefAccessToken, "");
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

  // ============ USER MODEL DATA MANAGEMENT ============

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return SPHelper.getPreference(SPConstant.prefIsLoggedIn, false) ?? false;
  }

  // Save login state
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await SPHelper.setPreference(SPConstant.prefIsLoggedIn, isLoggedIn);
    
    if (isLoggedIn) {
      await SPHelper.setPreference(SPConstant.prefLastLoginTime, DateTime.now().toIso8601String());
    }
  }

  // Save user data (complete UserModel)
  static Future<void> saveUserData(UserModel user) async {
    // Save individual fields
    await SPHelper.setPreference(SPConstant.prefUserEmail, user.email ?? '');
    await SPHelper.setPreference(SPConstant.prefUserName, user.name ?? '');
    await SPHelper.setPreference(SPConstant.prefUserUid, user.uid ?? '');
    await SPHelper.setPreference(SPConstant.prefUserProfileImage, user.profileImage ?? '');
    await SPHelper.setPreference(SPConstant.prefUserGender, user.gender ?? '');
    await SPHelper.setPreference(SPConstant.prefUserBio, user.bio ?? '');
    
    // Save complete user data as JSON
    String userJson = jsonEncode(user.toJson());
    await SPHelper.setPreference(SPConstant.prefUserData, userJson);
    
    // Set logged in state
    await setLoggedIn(true);
  }

  // Get complete user data
  static Future<UserModel?> getUserData() async {
    String? userJson = SPHelper.getPreference(SPConstant.prefUserData, "");
    
    if (userJson != null && userJson.isNotEmpty) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  // Get individual user fields
  static Future<String> getUserEmail() async {
    return SPHelper.getPreference(SPConstant.prefUserEmail, "") ?? '';
  }

  static Future<String> getUserName() async {
    return SPHelper.getPreference(SPConstant.prefUserName, "") ?? '';
  }

  static Future<String> getUserUid() async {
    return SPHelper.getPreference(SPConstant.prefUserUid, "") ?? '';
  }

  static Future<String> getUserProfileImage() async {
    return SPHelper.getPreference(SPConstant.prefUserProfileImage, "") ?? '';
  }

  static Future<String> getUserGender() async {
    return SPHelper.getPreference(SPConstant.prefUserGender, "") ?? '';
  }

  static Future<String> getUserBio() async {
    return SPHelper.getPreference(SPConstant.prefUserBio, "") ?? '';
  }

  // Get last login time
  static Future<DateTime?> getLastLoginTime() async {
    String? lastLoginStr = SPHelper.getPreference(SPConstant.prefLastLoginTime, "");
    
    if (lastLoginStr != null && lastLoginStr.isNotEmpty) {
      try {
        return DateTime.parse(lastLoginStr);
      } catch (e) {
        print('Error parsing last login time: $e');
        return null;
      }
    }
    return null;
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    await SPHelper.removeKey(SPConstant.prefIsLoggedIn);
    await SPHelper.removeKey(SPConstant.prefUserData);
    await SPHelper.removeKey(SPConstant.prefUserEmail);
    await SPHelper.removeKey(SPConstant.prefUserName);
    await SPHelper.removeKey(SPConstant.prefUserUid);
    await SPHelper.removeKey(SPConstant.prefUserProfileImage);
    await SPHelper.removeKey(SPConstant.prefUserGender);
    await SPHelper.removeKey(SPConstant.prefUserBio);
    await SPHelper.removeKey(SPConstant.prefLastLoginTime);
    
    print('All user data cleared from SharedPreferences');
  }

  // Update specific user field
  static Future<void> updateUserField(String key, String value) async {
    switch (key) {
      case 'name':
        await SPHelper.setPreference(SPConstant.prefUserName, value);
        break;
      case 'profileImage':
        await SPHelper.setPreference(SPConstant.prefUserProfileImage, value);
        break;
      case 'bio':
        await SPHelper.setPreference(SPConstant.prefUserBio, value);
        break;
      case 'gender':
        await SPHelper.setPreference(SPConstant.prefUserGender, value);
        break;
    }
    
    // Update complete user data
    UserModel? currentUser = await getUserData();
    if (currentUser != null) {
      switch (key) {
        case 'name':
          currentUser.name = value;
          break;
        case 'profileImage':
          currentUser.profileImage = value;
          break;
        case 'bio':
          currentUser.bio = value;
          break;
        case 'gender':
          currentUser.gender = value;
          break;
      }
      await saveUserData(currentUser);
    }
  }

  // Check if user data exists
  static Future<bool> hasUserData() async {
    String? userJson = SPHelper.getPreference(SPConstant.prefUserData, "");
    return userJson != null && userJson.isNotEmpty;
  }

  // Get user preferences for app settings
  static Future<Map<String, dynamic>> getUserPreferences() async {
    return {
      'isLoggedIn': await isLoggedIn(),
      'userEmail': await getUserEmail(),
      'userName': await getUserName(),
      'userUid': await getUserUid(),
      'lastLoginTime': await getLastLoginTime(),
      'hasUserData': await hasUserData(),
    };
  }
}
