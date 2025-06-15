import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingmexx/utils/apiutils/api_response.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/common/progress_button.dart';
import 'package:pingmexx/utils/constant/assets_const.dart';
import 'package:pingmexx/utils/constant/color_const.dart';
import 'package:pingmexx/utils/constant/string_const.dart';
import 'package:pingmexx/utils/widgethelper/validation_helper.dart';

// Navigation Helpers
void navigationPush(BuildContext context, StatefulWidget route) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => route));
}

void navigationRemoveAllPush(BuildContext context, StatefulWidget route) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (BuildContext context) => route),
    (route) => false,
  );
}

void navigationPop(BuildContext context) {
  Navigator.pop(context);
}

void navigationStateLessPush(BuildContext context, StatelessWidget route) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => route));
}

// Text Widgets
TextStyle _getFontStyle({
  Color? txtColor,
  double? fontSize,
  FontWeight? fontWeight,
  String? fontFamily,
  TextDecoration? txtDecoration,
}) {
  return TextStyle(
    color: txtColor,
    fontSize: fontSize ?? 14,
    decoration: txtDecoration ?? TextDecoration.none,
    fontWeight: fontWeight ?? FontWeight.normal,
    fontFamily: fontFamily,
  );
}

Text getTxt({
  required String msg,
  FontWeight? fontWeight,
  int? maxLines,
  TextAlign? textAlign,
  Color color = Colors.black,
  double fontSize = 12,
  TextOverflow? overflow,
}) {
  return Text(
    msg,
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: overflow,
    style: _getFontStyle(
      txtColor: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtAppColor({
  required String? msg,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return Text(
    msg ?? "",
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: ColorConst.appColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtWhiteColor({
  required String msg,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return Text(
    msg,
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: Colors.white,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtGreenColor({
  required String msg,
  double fontSize = 16,
  FontWeight? fontWeight,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return Text(
    msg,
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: ColorConst.greenColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtRedColor({
  required String? msg,
  double? fontSize,
  FontWeight? fontWeight,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return Text(
    msg ?? "",
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: ColorConst.redColor,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtBlackColor({
  required String? msg,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign? textAlign,
}) {
  return Text(
    msg ?? "",
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: ColorConst.blackColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtGreyColor({
  required String? msg,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign textAlign = TextAlign.start,
}) {
  return Text(
    msg ?? "",
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: ColorConst.greyColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

Text getTxtColor({
  required String? msg,
  required Color txtColor,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign textAlign = TextAlign.start,
}) {
  return Text(
    msg ?? "",
    maxLines: maxLines,
    textAlign: textAlign,
    style: _getFontStyle(
      txtColor: txtColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );
}

// Form Field Widgets
Widget edtPwdField({
  TextEditingController? control,
  bool pwdVisible = false,
  bool isRect = true,
  IconData? icons,
  required Function() pwdVisiableClick,
}) {
  return TextFormField(
    controller: control,
    cursorColor: Colors.white,
    decoration: InputDecoration(
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      border: OutlineInputBorder(
        borderRadius:
            isRect ? BorderRadius.circular(0) : BorderRadius.circular(30),
      ),
      hintText: "Password",
      prefixIcon: Icon(icons),
      suffixIcon: IconButton(
        icon: Icon(
          pwdVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: pwdVisiableClick,
      ),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        color: Colors.grey,
      ),
    ),
    obscureText: !pwdVisible,
    textInputAction: TextInputAction.done,
    maxLength: 32,
    validator: ValidationHelper.validateNormalPass,
  );
}

Widget edtDobField1(
    {TextEditingController? control,
    bool isRect = true,
    validate,
    IconData? icons,
    Color iconColor = Colors.white,
    String title = '',
    required Function() click}) {
  return TextFormField(
    onTap: click,
    cursorColor: Colors.white,
    validator: validate,
    textAlign: TextAlign.start,
    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
    decoration: InputDecoration(
      fillColor: ColorConst.appYellow,
      filled: true,
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 18.0),
      hintText: title,
      suffixIcon: Icon(
        icons,
        color: iconColor,
      ),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    textInputAction: TextInputAction.next,
    maxLength: 32,
    readOnly: true,
    controller: control,
  );
}

Widget edtDobField(
    {TextEditingController? control,
    bool isRect = true,
    validate,
    IconData? icons,
    Color iconColor = Colors.grey,
    String title = '',
    required Function() click}) {
  return TextFormField(
    onTap: click,
    cursorColor: Colors.white,
    validator: validate,
    decoration: InputDecoration(
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      border: OutlineInputBorder(
          borderRadius:
              isRect ? BorderRadius.circular(0) : BorderRadius.circular(30)),
      hintText: title,
      prefixIcon: Icon(
        icons,
        color: iconColor,
      ),
      hintStyle:
          const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    textInputAction: TextInputAction.next,
    maxLength: 32,
    readOnly: true,
    controller: control,
  );
}

Widget edtRectField(
    {TextEditingController? control,
    String hint = '',
    validate,
    IconData? icons,
    bool isRect = true,
    int txtLength = 32,
    keyboardType,
    bool isReadOnly = false,
    bool isShowOutline = true,
    textCapitalization = TextCapitalization.words}) {
  InputBorder outlineBorder;
  if (isShowOutline) {
    outlineBorder = OutlineInputBorder(
        borderRadius:
            isRect ? BorderRadius.circular(0) : BorderRadius.circular(30));
  } else {
    outlineBorder = InputBorder.none;
  }
  return TextFormField(
      cursorColor: Colors.white,
      textCapitalization: textCapitalization,
      controller: control,
      textInputAction: TextInputAction.next,
      maxLength: txtLength,
      validator: validate,
      keyboardType: keyboardType,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        border: outlineBorder,
        hintText: hint,
        prefixIcon: Icon(icons),
        labelText: hint,
        hintStyle:
            const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
      ));
}

Widget edtRectFieldBorder(
    {TextEditingController? control,
    String hint = '',
    validate,
    Icon? prefIcons,
    Icon? suffixIcon,
    bool isRect = true,
    int txtLength = 32,
    keyboardType,
    bool isReadOnly = false,
    bool isShowOutline = true,
    textCapitalization = TextCapitalization.words,
    Color borderColor = Colors.grey,
    Color focusBorderColor = Colors.grey,
    Color hintColor = Colors.grey,
    Color textColor = Colors.black,
    Color? filledColor,
    double fontSize = 13,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.never,
    double radius = 5,
    Function(String)? onChange,
    Function()? onTap}) {
  return TextFormField(
      onTap: onTap,
      cursorColor: Colors.white,
      textCapitalization: textCapitalization,
      controller: control,
      textInputAction: TextInputAction.next,
      maxLength: txtLength,
      validator: validate,
      keyboardType: keyboardType,
      onChanged: onChange,
      style: TextStyle(
          fontSize: fontSize, color: textColor, fontWeight: FontWeight.w500),
      readOnly: isReadOnly,
      decoration: inputFieldDecoration(
          radius: radius,
          hint: hint,
          hintColor: hintColor,
          prefIcons: prefIcons,
          suffixIcon: suffixIcon,
          isRect: isRect,
          fontSize: fontSize,
          focusBorderColor: focusBorderColor,
          filledColor: filledColor,
          isShowOutline: isShowOutline,
          floatingLabelBehavior: floatingLabelBehavior,
          borderColor: borderColor));
}

Widget edtDateField1(Function() dateClick,
        {String date = "",
        String title = "",
        Color titleColor = Colors.black,
        Color bgColor = Colors.white,
        Color txtSubColor = Colors.black}) =>
    Expanded(
      child: InkWell(
          onTap: dateClick,
          child: Container(
              padding:
                  const EdgeInsets.only(left: 5, right: 5, bottom: 8, top: 5),
              color: bgColor,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                getTxtColor(
                  msg: title,
                  txtColor: titleColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 5),
                getTxtColor(msg: date, txtColor: txtSubColor)
              ]))),
    );

InputDecoration inputFieldDecoration(
    {double radius = 5,
    Color borderColor = Colors.grey,
    Color focusBorderColor = Colors.grey,
    String hint = '',
    Color hintColor = Colors.grey,
    Icon? prefIcons,
    Icon? suffixIcon,
    Color? filledColor,
    bool isRect = true,
    double fontSize = 13,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.never,
    bool isShowOutline = true}) {
  InputBorder outlineBorder;
  if (isShowOutline) {
    outlineBorder = OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
        borderRadius: isRect
            ? BorderRadius.circular(radius)
            : BorderRadius.circular(radius));
  } else {
    outlineBorder = InputBorder.none;
  }
  return InputDecoration(
      counterText: '',
      border: outlineBorder,
      prefixIcon: prefIcons,
      suffixIcon: suffixIcon,
      fillColor: filledColor,
      filled: filledColor != null,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelText: hint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: focusBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(radius))),
      hintText: hint,
      hintStyle: TextStyle(
          fontWeight: FontWeight.w500, color: hintColor, fontSize: fontSize),
      labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize));
}

Widget edtDateField(Function() dateClick,
    {String date = "",
    String title = "",
    Color titleColor = Colors.black,
    Color bgColor = Colors.white,
    Color txtSubColor = Colors.black}) {
  return Expanded(
    child: InkWell(
      onTap: dateClick,
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 8, top: 5),
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getTxtColor(
              msg: title,
              txtColor: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 5),
            getTxtColor(msg: date, txtColor: txtSubColor)
          ],
        ),
      ),
    ),
  );
}

Widget edtTimeField(TextEditingController edtController, Function() timeClick) {
  return TextFormField(
    onTap: timeClick,
    cursorColor: Colors.white,
    decoration: InputDecoration(
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      border: OutlineInputBorder(
          gapPadding: 30, borderRadius: BorderRadius.circular(30)),
      hintText: "Select Time",
      hintStyle:
          const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    textInputAction: TextInputAction.next,
    maxLength: 32,
    readOnly: true,
    controller: edtController,
    validator: (dob) => ValidationHelper.empty(dob!, 'Time is Required'),
  );
}

Widget edtRateField(TextEditingController edtController) {
  return TextFormField(
    controller: edtController,
    cursorColor: Colors.white,
    decoration: InputDecoration(
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      border: OutlineInputBorder(
          gapPadding: 30, borderRadius: BorderRadius.circular(30)),
      hintText: "Enter Rate",
      hintStyle:
          const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
    ),
    textInputAction: TextInputAction.next,
    maxLength: 10,
    keyboardType: TextInputType.number,
    validator: (rate) => ValidationHelper.empty(rate!, 'Rate is Required'),
  );
}

Widget edtCommentField(TextEditingController edtController) {
  return TextFormField(
    textCapitalization: TextCapitalization.words,
    controller: edtController,
    cursorColor: Colors.white,
    decoration: InputDecoration(
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        border: OutlineInputBorder(
            gapPadding: 30, borderRadius: BorderRadius.circular(30)),
        hintText: "Enter Comments",
        hintStyle:
            const TextStyle(fontWeight: FontWeight.w300, color: Colors.grey)),
    textInputAction: TextInputAction.next,
    maxLength: 150,
  );
}

InputDecoration getTextFormFieldOutline(
    {String hint = "Enter text",
    Color? borderColor,
    double borderRadius = 3.0,
    double borderWidth = 1.0,
    Icon? prefixIcon,
    Color? fillColor,
    bool? filled}) {
  borderColor = ColorConst.appColor;
  return InputDecoration(
      counterText: "",
      fillColor: fillColor,
      filled: filled,
      prefixIcon: prefixIcon,
      prefixIconColor: Colors.grey,
      border: OutlineInputBorder(
          gapPadding: 30, borderRadius: BorderRadius.circular(borderRadius)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      hintText: hint,
      hintStyle:
          const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
      errorStyle: const TextStyle(fontWeight: FontWeight.w500),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: borderWidth, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: borderWidth, color: borderColor),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: borderWidth, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: borderWidth, color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(width: borderWidth, color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))));
}

// Button Widgets
Widget raisedRoundAppColorBtn(String txt, Function() btnClick) {
  return SizedBox(
    height: 45,
    child: ElevatedButton(
      onPressed: btnClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConst.appColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: getTxtWhiteColor(
        msg: txt,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget raisedRoundColorBtn(String txt, Color color, Function() btnClick) {
  return SizedBox(
    height: 45,
    child: ElevatedButton(
      onPressed: btnClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: getTxtWhiteColor(
        msg: txt,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

ElevatedButton btnBorderCorner(String msg, Function() onTap,
        {FontWeight fontWeight = FontWeight.normal,
        Color borderColor = Colors.black,
        double fontSize = 14,
        Color textColor = Colors.black,
        Color bgColor = Colors.transparent,
        double borderSide = 1,
        double radius = 4}) =>
    ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(width: borderSide, color: borderColor),
            backgroundColor: bgColor,
            shadowColor: bgColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(radius)))),
        onPressed: () => onTap(),
        child: getTxtColor(
            msg: msg ?? "",
            fontWeight: fontWeight,
            fontSize: fontSize,
            txtColor: textColor));

Widget btnProgress(String msg,
    {Color? bgColor,
    double borderRadius = 4,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
    Function(Function startLoading, Function stopLoading, ButtonState btnState)?
        onTap}) {
  bgColor = ColorConst.appColor;
  return Center(
      child: ProgressButton(
          height: 50,
          borderRadius: borderRadius,
          progressIndicatorSize: 50,
          animate: true,
          color: bgColor,
          width: MediaQuery.of(Get.context!).size.width,
          child: getTxtWhiteColor(
              msg: msg, fontWeight: fontWeight, fontSize: fontSize),
          onTap: (startLoading, stopLoading, btnState) {
            onTap!(startLoading, stopLoading, btnState);
          }));
}

// AppBar Widgets
AppBar getAppBar({required String title, double fontSize = 16}) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
    ),
  );
}

AppBar getAppBarWithBackBtn({
  required BuildContext ctx,
  String title = "",
  Color bgColor = Colors.white,
  double fontSize = 16,
  String titleTag = "",
  Widget? icon,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: bgColor,
    leading: icon,
    actions: actions,
    centerTitle: true,
    title: Hero(
      tag: titleTag,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorConst.blackColor,
          fontSize: fontSize,
        ),
      ),
    ),
  );
}

// Image Widgets
Widget getCacheImage({
  String? url = '',
  double height = 80,
  double width = 80,
  String placeHolder = AssetsConst.logoImg,
  bool isCircle = false,
  bool isShowBorderRadius = false,
  BoxFit fit = BoxFit.cover,
  String? assetPath,
  File? filePath,
}) {
  return Container(
    width: width,
    height: height,
    decoration: isShowBorderRadius
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: ColorConst.appColor, width: 2.0),
          )
        : null,
    child: ClipRRect(
      borderRadius:
          isCircle ? BorderRadius.circular(height) : BorderRadius.zero,
      child: _buildImageContent(
        url: url,
        height: height,
        width: width,
        placeHolder: placeHolder,
        fit: fit,
        assetPath: assetPath,
        filePath: filePath,
      ),
    ),
  );
}

Widget _buildImageContent({
  String? url,
  double height = 80,
  double width = 80,
  String placeHolder = AssetsConst.logoImg,
  BoxFit fit = BoxFit.cover,
  String? assetPath,
  File? filePath,
}) {
  if (assetPath?.isNotEmpty == true) {
    return Image.asset(assetPath!, fit: fit);
  } else if (filePath?.path.isNotEmpty == true) {
    return Image.file(filePath!, fit: fit);
  } else {
    return CachedNetworkImage(
      fit: fit,
      width: width,
      height: height,
      imageUrl: url ?? "",
      placeholder: (context, url) => getPlaceHolder(placeHolder, height, width),
      errorWidget: (context, url, error) =>
          getPlaceHolder(placeHolder, height, width),
    );
  }
}

// List and Grid Widgets
Widget getList({
  required double height,
  required int itemCount,
  Axis scrollDirection = Axis.vertical,
  ScrollPhysics? physics,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return SizedBox(
    height: height,
    child: ListView.builder(
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    ),
  );
}

Widget getGrid({
  required int itemCount,
  int crossAxisCount = 2,
  double childAspectRatio = 1.5,
  ScrollPhysics? physics,
  required Widget Function(BuildContext, int) itemBuilder,
}) {
  return GridView.builder(
    itemCount: itemCount,
    shrinkWrap: true,
    physics: physics ?? const BouncingScrollPhysics(),
    padding: const EdgeInsets.all(0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
    ),
    itemBuilder: itemBuilder,
  );
}

Widget getStaggered(
    {required double height,
    required int itemCount,
    int crossAxisCount = 2,
    double childAspectRatio = (1.5 / 1.8),
    required Function widget,
    ScrollPhysics? physics,
    ScrollController? controller}) {
  return GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      semanticChildCount: 5,
      itemCount: itemCount,
      gridDelegate: SliverStairedGridDelegate(
          crossAxisSpacing: 48,
          mainAxisSpacing: 24,
          startCrossAxisDirectionReversed: true,
          pattern: const [
            StairedGridTile(0.5, 1),
            StairedGridTile(0.5, 3 / 4),
            StairedGridTile(1.0, 10 / 4)
          ]),
      itemBuilder: (BuildContext context, int index) {
        return widget(context, index);
      });
}

void showSnackBar(BuildContext context, String message) async {
  try {
    var snackbar = SnackBar(
      content: getTxtWhiteColor(msg: message),
      backgroundColor: ColorConst.greenColor,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  } catch (e) {
    printLog(msg: 'object $e');
  }
}

void showToast(String msg, {bool isSuccess = true}) {
  var color = isSuccess ? Colors.green : Colors.red;
  Fluttertoast.showToast(
      msg: msg ?? "",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}

void getSnackBar(
    {String? title = "", String? subTitle = "", bool isSuccess = false}) {
  try {
    Get.snackbar(title ?? "", subTitle ?? "",
        backgroundColor:
            isSuccess ? ColorConst.greenColor : ColorConst.redColor,
        colorText: ColorConst.whiteColor,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3));
  } catch (exc) {
    printLog(msg: "exc $exc");
  }
}

Divider getDivider() {
  return Divider(color: ColorConst.appColor, height: 1);
}

void imagePickerDialog({Function? pickImg}) {
  Widget dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title:
          getTxtBlackColor(msg: 'Select Option', fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              Get.back();
              getImage(ImageSource.camera, pickImg!);
            },
            child: Container(
                padding: const EdgeInsets.all(15),
                child: getTxtBlackColor(msg: 'Take Photo')),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
          GestureDetector(
              onTap: () {
                Get.back();
                getImage(ImageSource.gallery, pickImg!);
              },
              child: Container(
                  padding: const EdgeInsets.all(15),
                  child: getTxtBlackColor(msg: 'Choose From Gallery'))),
        ],
      ));
  Get.dialog(dialog);
}

void getImage(imageType, Function pickImg) async {
  XFile? xImage =
      await ImagePicker().pickImage(source: imageType, maxWidth: 400);
  if (xImage == null) return;
  File image = File(xImage.path); // convert it to a Dart:io file
  File filePath = File(image.path);
  printLog(msg: "before : ${filePath.length}");
  final result = await FlutterImageCompress.compressWithFile(
      filePath.absolute.path,
      minWidth: 700,
      minHeight: 500,
      quality: 25
      // rotate: 180,
      );
  printLog(msg: filePath.lengthSync());
  printLog(msg: "After : ${result?.length}");
  final imageEncoded = base64.encode(result!);
  printLog(msg: "Test : $imageEncoded");
  pickImg(filePath, 'data:image/jpeg;base64,$imageEncoded');
}

Widget apiHandler<T>(String apiName,
    {required ApiResponse<T>? response,
    Widget? loading,
    Widget? error,
    String? errorMsg}) {
  if (response?.status == null) {
    return Container();
  }
  switch (response?.status) {
    case ApiStatus.loading:
      return loading ??
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorConst.appColor),
            ),
          );
      break;
    case ApiStatus.error:
      var errorApiName = "";
      if (kDebugMode) {
        errorApiName = apiName.toString();
      }
      return Center(
        child: getTxtColor(
          msg: "$errorApiName${response?.message}${response?.message}",
          txtColor: ColorConst.redColor,
          textAlign: TextAlign.center,
        ),
      );
    case ApiStatus.success:
      return Container();
      break;
    default:
      {
        var errorApiName = "";
        if (kDebugMode) {
          errorApiName = apiName.toString();
        }
        return Container(
            color: Colors.amber,
            child: getTxtAppColor(
                msg: StringConst.somethingWentWrong +
                    errorApiName +
                    (response?.message ?? ""),
                textAlign: TextAlign.center));
      }
  }
}

Widget getPlaceHolder(
    String placeAssetsHolderPos, double height, double width) {
  return SizedBox(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: Image.asset(placeAssetsHolderPos));
}

Widget showLoader() {
  return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorConst.appColor)));
}

Widget noDataFound() {
  return Center(
      child: Image.asset(
    AssetsConst.noDataFoundImg,
    height: 150,
    width: 250,
  ));
}

Widget showError(String? error) {
  return Visibility(
      visible: isEmpty(error) == false,
      child: getTxtColor(msg: error ?? '', txtColor: ColorConst.redColor));
}

bool isDarkMode() {
  return false;
  // var brightness = SchedulerBinding.instance.window.platformBrightness;
  // final isDarkMode = brightness == Brightness.dark;
  // return isDarkMode;
}

Widget getHeading(
    {String title = '', bool viewAllShow = true, Function? onClick}) {
  return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 15, top: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        getTxtBlackColor(msg: title, fontSize: 19, fontWeight: FontWeight.w700),
        if (viewAllShow)
          InkWell(
              onTap: () => onClick!(title),
              child: Container(
                  child: getTxtAppColor(
                      msg: 'View All',
                      fontSize: 15,
                      fontWeight: FontWeight.w800)))
      ]));
}
