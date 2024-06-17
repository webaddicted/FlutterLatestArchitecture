import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:medibot/utils/apiutils/api_response.dart';
import 'package:medibot/utils/sp/sp_manager.dart';

//  {START PAGE NAVIGATION}
void navigationPush(BuildContext context, StatefulWidget route) {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return route;
    },
  ));
}

void navigationRemoveAllPush(BuildContext context, StatefulWidget route) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => route,
    ),
    (route) => false,
  );
}

void navigationPop(BuildContext context, StatefulWidget route) {
  Navigator.pop(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

void navigationStateLessPush(BuildContext context, StatelessWidget route) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

void navigationStateLessPop(BuildContext context, StatelessWidget route) {
  Navigator.pop(context, MaterialPageRoute(builder: (context) {
    return route;
  }));
}

//  {END PAGE NAVIGATION}

Future<String> deviceId() async {
  String deviceId = '';
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    deviceId = info.id;
  } else if (Platform.isIOS){
    IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
    deviceId = iosInfo.utsname.machine;
  }else{
    WebBrowserInfo webBrowserInfo =  await DeviceInfoPlugin().webBrowserInfo;
    webBrowserInfo.browserName;
  }
  return deviceId;
// return 'WER34dfer34erdf';
}

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

logout() {
  SPManager.clearPref();
  // navigationRemoveAllPush(ctx, LoginPage());
}

final logger = Logger();
printLog(
    {String tag = "",
      required dynamic msg,
      ApiStatus status = ApiStatus.success}) {
  if (kDebugMode) {
    print("$tag : $msg");
    if (status == ApiStatus.error) {
      logger.e("$tag : $msg");
    } else {
      logger.d("$tag : $msg");
    }
  }
}
showToast(String msg, {bool isSuccess = true}){
  var color = isSuccess?Colors.green:Colors.red;
  Fluttertoast.showToast(
      msg: msg??"",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
