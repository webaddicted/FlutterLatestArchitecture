import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medibot/utils/common/global_utilities.dart';
import 'package:medibot/utils/common/progress_button.dart';
import 'package:medibot/utils/constant/color_const.dart';
import 'package:medibot/utils/widgethelper/validation_helper.dart';
import 'package:medibot/utils/widgethelper/widget_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class DialogHelper {
  static var permissionSettingMsg =
      "This app may not work correctly without the requested permissions.\nOpen the app settings screen to modify app permissions";

  static showCustomDialogHtml(Function isGranted,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: getTxtBlackColorHtml(
                msg: title, fontSize: 18, fontWeight: FontWeight.bold),
            content: getTxtBlackColorHtml(msg: message, fontSize: 17),
            actions: <Widget>[
              TextButton(
                  child: getTxtBlackColorHtml(msg: okBtn, fontSize: 17),
                  onPressed: () {
                    isGranted(true);
                  }),
              TextButton(
                  child: getTxtBlackColorHtml(msg: cancelBtn, fontSize: 17),
                  onPressed: () {
                    Get.back();
                    isGranted(false);
                  }),
            ],
          );
        });
  }

  static showCustomDialog(Function isGranted,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
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

  static showPermissionSettingDialog(Function isOpenSetting,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
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

  static listBottomSheet(
      String title, List<String> list, String selectedValue, Function click) {
    showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        builder: (BuildContext context) {
          return Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              child: Container(
                  margin: const EdgeInsets.only(top: 10.0, left: 30, right: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        getTxtBlackColor(
                            msg: title,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                        const SizedBox(height: 10),
                        Flexible(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: list.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  String item = list[index];
                                  return InkWell(
                                      onTap: () => click(item, index),
                                      child: Row(children: [
                                        Radio(
                                            value: item,
                                            groupValue: selectedValue,
                                            onChanged: (String? value) {
                                              click(item, index);
                                            }),
                                        getTxtBlackColor(msg: item)
                                      ]));
                                }))
                      ])));
        });
  }

  static selectMedicineBottomSheetCustom(String title, List<String> list,
      Function(String selectedValue, int selectedIndex, int count) onTap,
      {String hint = "Times in a day",
      String? value,
      TextInputType keyboardType = TextInputType.number}) {
    TextEditingController frequencyCustomCont = TextEditingController();
    GlobalKey<FormState>? bottomSheetFormKey = GlobalKey<FormState>();

    // Determine if the value exists in the list
    int selectedIndex = list.indexOf(value ?? '');
    String? selectedValue = (selectedIndex != -1) ? value : "Custom";
// printLog(msg: "selectedValue $selectedValue selectedIndex $selectedIndex");
    if (selectedIndex == -1 && value != null && value.isNotEmpty) {
      frequencyCustomCont.text = value; // Set custom value in the input field
    }

    Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0))),
        child: Container(
          margin: const EdgeInsets.only(top: 10.0, left: 20, right: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                getTxtBlackColor(
                    msg: title, fontSize: 19, fontWeight: FontWeight.w500),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length + 1, // Adding one for "Custom"
                  itemBuilder: (BuildContext context, int index) {
                    String item =
                        (index < list.length) ? list[index] : "Custom";

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          selectedValue = item;

                          if (item == "Custom") {
                            frequencyCustomCont.text =
                                value ?? ''; // Restore custom value
                          } else {
                            frequencyCustomCont.clear();
                            onTap(selectedValue!, selectedIndex,
                                selectedIndex + 1);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Radio(
                              value: item,
                              groupValue: selectedValue,
                              onChanged: (String? val) {
                                setState(() {
                                  selectedIndex = index;
                                  selectedValue = val;

                                  if (val == "Custom") {
                                    frequencyCustomCont.text = '';
                                  } else {
                                    frequencyCustomCont.clear();
                                    onTap(selectedValue!, selectedIndex,
                                        selectedIndex + 1);
                                  }
                                });
                              }),
                          getTxtBlackColor(msg: item),
                        ],
                      ),
                    );
                  },
                ),
                if (selectedValue == "Custom")
                  Form(
                    key: bottomSheetFormKey,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 30),
                      child: edtRectFieldBorder(
                          hint: hint,
                          filledColor: ColorConst.greyColor,
                          focusBorderColor: ColorConst.appColor,
                          control: frequencyCustomCont,
                          keyboardType: keyboardType,
                          validate: (value) =>
                              ValidationHelper.empty(value, "$hint Required")),
                    ),
                  ),
                const SizedBox(height: 10),
                btnProgress("Ok", bgColor: ColorConst.appColor,
                    onTap: (startLoading, stopLoading, btnState) async {
                  if (btnState == ButtonState.idle) {
                    final form = bottomSheetFormKey?.currentState;
                    if (selectedValue != "Custom") {
                      onTap(selectedValue!, selectedIndex, selectedIndex + 1);
                    } else if (form?.validate() == true) {
                      form?.save();
                      onTap(
                          frequencyCustomCont.text.toString(),
                          selectedIndex,
                          int.tryParse(frequencyCustomCont.text.toString()) ??
                              selectedIndex);
                    }
                  }
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }));
  }
}
