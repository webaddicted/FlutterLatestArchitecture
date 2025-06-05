import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/utils/constant/color_const.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType {
  camera,
  location,
  storage,
  notification,
  contact,
  sms,
  mediaLibrary
}

var permissionSettingMsg =
    "This app may not work correctly without the requested permissions.\nOpen the app settings screen to modify app permissions";

class PermissionHandler {
  static requestPermission(Permission permission,
      Function(bool? isPermissionGranted) isPermissionGranted) async {
    PermissionStatus permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      permissionStatus = await permission.request();
    }
    if (permissionStatus == PermissionStatus.granted) {
      isPermissionGranted(true);
    } else if (permissionStatus == PermissionStatus.denied ||
        permissionStatus == PermissionStatus.permanentlyDenied) {
      showPermissionSettingDialog(
          message: "$permissionSettingMsg\n$permission",
          isDismissible: false,
          isPermissionGranted);
    } else {
      isPermissionGranted(false);
    }
  }

  // List<Permission> statuses = [
  //   Permission.location,
  //   Permission.camera,
  //   Permission.sms,
  //   Permission.storage,
  // ];
  static requestMultiplePermission(
      List<Permission> multiPermission, Function isPermissionGranted) async {
    for (var element in multiPermission) {
      var status = await element.status;
      // printLog(msg: " requestMultiplePermission : $element $status.");
      if (status.isDenied || status.isPermanentlyDenied) {
        await multiPermission.request();
      }
    }
    String deniedPermission = "";
    for (var element in multiPermission) {
      var status = await element.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        deniedPermission = "$deniedPermission\n$element";
      }
    }
    if (deniedPermission.isNotEmpty) {
      showPermissionSettingDialog(
          message: "$permissionSettingMsg\n$deniedPermission",
          isDismissible: false, (isOpenSetting) {
        isPermissionGranted(false);
      });
    } else {
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

  static Future<bool> requestPermissionForMsg(
      String permissionType, Function isPermissionGranted,
      {bool isShowPermissionDialog = false}) async {
    late Permission permission;
    late String permissionTitle;
    late String permissionSubtitle;
    late String permissionBtnTxt;

    // Map permission type to Permission object and messages
    switch (permissionType) {
      case 'location':
        permission = Permission.location;
        permissionTitle = "Location Access Required";
        permissionSubtitle =
            "To provide the best experience, this app needs access to your location. With location access, we can offer personalized services tailored to your needs.\nBy enabling location, you can enjoy features like nearby service suggestions, accurate navigation, and enhanced functionality that makes your experience seamless.\nYour privacy is important to us. We ensure that your data is handled securely and used only for improving your experience.";
        permissionBtnTxt = "Allow Location Access";
        break;
      case 'contact':
        permission = Permission.contacts;
        permissionTitle = "Contacts Access Required";
        permissionSubtitle =
            "This app needs access to your contacts to help you connect with friends and family. Enable contacts access to easily share content and invite others to join.";
        permissionBtnTxt = "Allow Contacts Access";
        break;
      case 'camera':
        permission = Permission.camera;
        permissionTitle = "Camera Access Required";
        permissionSubtitle =
            "To capture photos and videos, this app needs access to your camera. Enable camera access to use features like profile picture updates and media sharing.";
        permissionBtnTxt = "Allow Camera Access";
        break;
      case 'storage':
        permission = Permission.storage;
        permissionTitle = "Storage Access Required";
        permissionSubtitle =
            "This app needs access to your device storage to save and manage files. Enable storage access to download content and save your preferences.";
        permissionBtnTxt = "Allow Storage Access";
        break;
      case 'setting':
        permission = Permission.notification;
        permissionTitle = "Notification Access Required";
        permissionSubtitle =
            "Stay updated with important information by enabling notifications. We'll keep you informed about new activities and relevant updates.";
        permissionBtnTxt = "Allow Notifications";
        break;
      case 'mediaLibrary':
        permission = Permission.mediaLibrary;
        permissionTitle = "Media Library Access Required";
        permissionSubtitle =
            "This app needs access to your media library to help you manage and share your photos and videos.";
        permissionBtnTxt = "Allow Media Access";
        break;
      default:
        permission = Permission.mediaLibrary;
        permissionTitle = "Permission Required";
        permissionSubtitle =
            "This app needs access to certain features to provide you with the best experience.";
        permissionBtnTxt = "Allow Access";
    }

    PermissionStatus permissionStatus = await permission.status;
    if (permissionStatus == PermissionStatus.granted) {
      isPermissionGranted(true);
      return true;
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (isShowPermissionDialog) {
        // Show custom bottom sheet for better user experience
        permissionBottomSheet(permissionTitle, permissionSubtitle,
            btnText: permissionBtnTxt, (isPermissionGrant) async {
          Navigator.pop(Get.context!);
          if (isPermissionGrant == false) {
            isPermissionGranted(false);
            return;
          }
          permissionStatus = await permission.request();
          if (permissionStatus == PermissionStatus.granted) {
            isPermissionGranted(true);
          } else {
            showPermissionSettingDialog(
              message: "$permissionSettingMsg\n$permission",
              isDismissible: false,
              isPermissionGranted,
            );
          }
        });
      } else {
        // Direct permission request
        permissionStatus = await permission.request();
        if (permissionStatus == PermissionStatus.granted) {
          isPermissionGranted(true);
          return true;
        } else {
          showPermissionSettingDialog(
            message: "$permissionSettingMsg\n$permission",
            isDismissible: false,
            isPermissionGranted,
          );
        }
      }
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      showPermissionSettingDialog(
        message: "$permissionSettingMsg\n$permission",
        isDismissible: false,
        isPermissionGranted,
      );
    } else {
      isPermissionGranted(false);
    }

    return false;
  }

  static Future<bool> requestMultiplePermissionWithBottomSheet(
    List<String> permissionTypes,
    Function(Map<Permission, bool> results, bool allGranted)
        onPermissionResult, {
    bool isShowPermissionDialog = true,
  }) async {
    // Create a map to store permission objects and their messages
    final Map<Permission, _PermissionInfo> permissionsMap = {};
    String combinedSubtitle = "";

    // Process each permission type
    for (String type in permissionTypes) {
      switch (type) {
        case 'location':
          permissionsMap[Permission.location] = _PermissionInfo(
            title: "Location",
            subtitle: "• Access to location for nearby services and navigation",
          );
          break;
        case 'contact':
          permissionsMap[Permission.contacts] = _PermissionInfo(
            title: "Contacts",
            subtitle: "• Access to contacts for connecting with friends",
          );
          break;
        case 'camera':
          permissionsMap[Permission.camera] = _PermissionInfo(
            title: "Camera",
            subtitle: "• Access to camera for capturing photos and videos",
          );
          break;
        case 'storage':
          permissionsMap[Permission.storage] = _PermissionInfo(
            title: "Storage",
            subtitle: "• Access to storage for saving files and media",
          );
          break;
        case 'notification':
          permissionsMap[Permission.notification] = _PermissionInfo(
            title: "Notifications",
            subtitle: "• Access to send you important updates and alerts",
          );
          break;
        case 'mediaLibrary':
          permissionsMap[Permission.mediaLibrary] = _PermissionInfo(
            title: "Media Library",
            subtitle:
                "• Access to media library for managing photos and videos",
          );
          break;
      }
    }

    // Combine all permission subtitles
    combinedSubtitle =
        permissionsMap.values.map((info) => info.subtitle).join("\n");

    // Check if any permission is already granted
    Map<Permission, PermissionStatus> statuses =
        await permissionsMap.keys.toList().request();

    bool allGranted =
        statuses.values.every((status) => status == PermissionStatus.granted);

    if (allGranted) {
      onPermissionResult(
          Map.fromIterables(
              permissionsMap.keys, List.filled(permissionsMap.length, true)),
          true);
      return true;
    }

    if (isShowPermissionDialog) {
      // Show bottom sheet with combined permissions info
      permissionBottomSheet(
        "App Permissions Required",
        "To provide you with the best experience, this app needs the following permissions:\n\n$combinedSubtitle\n\nYour privacy is important to us. We only use these permissions to provide core app features.",
        btnText: "Allow Permissions",
        (isPermissionGrant) async {
          Navigator.pop(Get.context!);
          // Request all permissions
          final Map<Permission, PermissionStatus> results =
              await permissionsMap.keys.toList().request();

          // Process results
          final Map<Permission, bool> permissionResults = {};
          bool needSettings = false;

          results.forEach((permission, status) {
            if (status == PermissionStatus.granted) {
              permissionResults[permission] = true;
            } else {
              permissionResults[permission] = false;
              needSettings = true;
            }
          });

          bool allPermissionsGranted =
              permissionResults.values.every((granted) => granted);

          if (needSettings) {
            showPermissionSettingDialog(
              message: "$permissionSettingMsg\nSome permissions were denied",
              isDismissible: false,
              (isOpenSetting) {
                onPermissionResult(permissionResults, allPermissionsGranted);
              },
            );
          } else {
            onPermissionResult(permissionResults, allPermissionsGranted);
          }
        },
      );
    } else {
      // Direct request without bottom sheet
      final Map<Permission, PermissionStatus> results =
          await permissionsMap.keys.toList().request();

      final Map<Permission, bool> permissionResults = {};
      results.forEach((permission, status) {
        permissionResults[permission] = status == PermissionStatus.granted;
      });

      bool allPermissionsGranted =
          permissionResults.values.every((granted) => granted);

      onPermissionResult(permissionResults, allPermissionsGranted);
    }

    return false;
  }
}

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

permissionBottomSheet(
    String title, String subTitle, Function(bool askPermission) click,
    {String btnText = "Ok"}) {
  showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      enableDrag: true,
      elevation: 0,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      builder: (BuildContext context) {
        return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Container(
                margin: const EdgeInsets.only(top: 10.0, left: 30, right: 10),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            getTxtBlackColor(
                                msg: title,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            IconButton(
                                icon:
                                    Icon(Icons.cancel, color: ColorConst.grey),
                                onPressed: () {
                                  click(false);
                                }),
                          ]),
                      getTxtBlackColor(
                          msg: subTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: btnBorderCorner(btnText,
                              bgColor: ColorConst.appColor,
                              textColor: ColorConst.whiteColor,
                              borderColor: ColorConst.whiteColor,
                              fontWeight: FontWeight.bold, () {
                            click(true);
                          })),
                      const SizedBox(height: 50),
                    ])));
      });
}

// Helper class to store permission information
class _PermissionInfo {
  final String title;
  final String subtitle;

  _PermissionInfo({
    required this.title,
    required this.subtitle,
  });
}
