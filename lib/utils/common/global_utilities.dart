import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/logger.dart';
import 'package:pingmexx/utils/apiutils/api_response.dart';
import 'package:pingmexx/utils/constant/color_const.dart';
import 'package:pingmexx/utils/sp/sp_manager.dart';
import 'package:get/get.dart';
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
// HexColor("#D26661").withOpacity(0.1);
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    if (hexColor.isEmpty) hexColor = "323483";
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
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
delay({dynamic durationSec, Function? click}) {
  int sec = (durationSec! * 1000).toInt();
  printLog(msg: "sec  :: $sec");
  Future.delayed(Duration(milliseconds: sec), () {
    click!();
  });
}
delayTime({dynamic durationSec, Function? click}) {
  int sec = (durationSec! * 1000).toInt();
  Future.delayed(Duration(milliseconds: sec), () {
    click!();
  });
}
isEmpty(String? title)=> (title==null || title.isEmpty || title=="null");

Future<bool> checkInternetConnection() async {
  bool result =  await InternetConnectionChecker.instance.hasConnection;
  return result;
}

removeSoftKeyboard(){
  FocusManager.instance.primaryFocus?.unfocus();
}
back(){
  Navigator.of(Get.context!).pop();
}
Widget getTxtBlackColorHtml({
  required String? msg,
  double fontSize = 13,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return HtmlWidget(
    msg ?? "",
    textStyle: TextStyle(
      color: ColorConst.blackColor, // Custom text color
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}









