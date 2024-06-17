import 'package:medibot/utils/common/global_utilities.dart';
import 'package:medibot/utils/widgethelper/widget_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PermissionHandler{

  static requestPermission(Permission permission, Function isPermissionGranted)async {
   PermissionStatus permissionStatus = await permission.status;
   if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await Permission.location.request();
    }
   if(permissionStatus == PermissionStatus.granted){
     isPermissionGranted(true);
   }else if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied) {
     showPermissionSettingDialog(message: "$permissionSettingMsg\n$permission",isDismissible: false,isPermissionGranted);
   }else{
     isPermissionGranted(false);
   }
  }

  // List<Permission> statuses = [
  //   Permission.location,
  //   Permission.camera,
  //   Permission.sms,
  //   Permission.storage,
  // ];
  static requestMultiplePermission(List<Permission> multiPermission, Function isPermissionGranted)async {
    for (var element in multiPermission) {
      var status = await element.status;
      printLog(msg: " requestMultiplePermission : $element $status.");
      if (status.isDenied || status.isPermanentlyDenied) {
        await multiPermission.request();
      }
    }
    String deniedPermission= "";
    for (var element in multiPermission) {
      var status = await element.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        deniedPermission = "$deniedPermission\n$element";
      }
    }
    if(deniedPermission.isNotEmpty){
      showPermissionSettingDialog(message: "$permissionSettingMsg\n$deniedPermission",isDismissible: false,(isOpenSetting){
        isPermissionGranted(false);
      });
    }else{
      isPermissionGranted(true);
    }

    // PermissionStatus permissionStatus = await permission.status;
    // if (permissionStatus != PermissionStatus.granted) {
    //   permissionStatus = await Permission.location.request();
    // }
    // if(permissionStatus == PermissionStatus.granted){
    //   isPermissionGranted(true);
    // }else if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied) {
    //   showCustomDialog(isPermissionGranted);
    // }else{
    //   isPermissionGranted(false);
    // }
  }


  static Future<bool> requestPermissionForMsg(String message)async {
    late PermissionStatus permission;
    late PermissionStatus permissionStatus;
    if(message =="location") {
      permission = await Permission.location.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.location.request();
      }
    }else if(message =="contacts") {
      permission = await Permission.contacts.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.contacts.request();
      }
    }else if(message =="camera") {
      permission = await Permission.camera.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.camera.request();
      }
    }else if(message =="storage") {
      permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.storage.request();
      }
    }else if(message =="notification") {
      permission = await Permission.notification.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.notification.request();
      }
    }else if(message =="mediaLibrary") {
      permission = await Permission.mediaLibrary.status;
      if (permission != PermissionStatus.granted ) {
        permissionStatus = await Permission.mediaLibrary.request();
      }
    }else  {
      permission = await Permission.mediaLibrary.status;
      if (permission != PermissionStatus.granted) {
        permissionStatus = await Permission.mediaLibrary.request();
      }
    }
    if(permission == PermissionStatus.granted || permissionStatus == PermissionStatus.granted){
      return true;
    }else if (permissionStatus == PermissionStatus.denied) {
      return false;
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      showPermissionSettingDialog((isGrant){},message: "Please enable $message permissions. This permission is required for the app to run smoothly.",isDismissible: false,);
      return false;
    }else{
      return false;
    }
  }


}

var permissionSettingMsg =
    "This app may not work correctly without the requested permissions.\nOpen the app settings screen to modify app permissions";

showPermissionSettingDialog(Function isOpenSetting,
    {String title = "Permission Required",
      String message = "",
      String okBtn = "Go to Settings",
      String cancelBtn = "Dismiss",
      bool isDismissible = false}) async {
  showDialog<bool>(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: getTxtBlackColor(
              msg: title, fontSize: 18, fontWeight: FontWeight.bold),
          content: getTxtBlackColor(msg: message, fontSize: 17),
          actions: <Widget>[
            TextButton(
                child: getTxtBlackColor(msg: okBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  openAppSettings();
                  isOpenSetting(false);
                }),
            TextButton(
                child: getTxtBlackColor(msg: cancelBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  isOpenSetting(false);
                }),
          ],
        );
      });
}
showCustomDialog(Function isGranted,
    {required String title,
      required String message,
      String okBtn = "ok",
      String cancelBtn = "Cancel",
      bool isDismissible = false}) async {
  showDialog<bool>(
      context: Get.context!,
      barrierDismissible: isDismissible,
      builder: (_) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: getTxtBlackColor(
              msg: title, fontSize: 18, fontWeight: FontWeight.bold),
          content: getTxtBlackColor(msg: message, fontSize: 17),
          actions: <Widget>[
            TextButton(
                child: getTxtBlackColor(msg: okBtn, fontSize: 17),
                onPressed: () {
                  isGranted(true);
                }),
            TextButton(
                child: getTxtBlackColor(msg: cancelBtn, fontSize: 17),
                onPressed: () {
                  Get.back();
                  isGranted(false);
                }),
          ],
        );
      });
}
