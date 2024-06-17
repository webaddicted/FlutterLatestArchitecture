import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medibot/controller/login_controller.dart';
import 'package:medibot/data/bean/login/login_respo.dart';
import 'package:medibot/utils/apiutils/api_response.dart';
import 'package:medibot/utils/common/progress_button.dart';
import 'package:medibot/utils/constant/assets_const.dart';
import 'package:medibot/utils/constant/color_const.dart';
import 'package:medibot/utils/widgethelper/widget_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController mobileNoCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  final _countryCode = '🇮🇳 (+91) ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _createUi());
  }

  Widget _createUi() {
    return SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  // Align(
                  //   alignment: Alignment.bottomLeft,
                  //   child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            SystemNavigator.pop();
                          }),
                    ],
                  ),
                  SizedBox(
                      height: 155,
                      width: 300,
                      child: Image.asset(
                        AssetsConst.logoImg,
                      )),
                  getTxtAppColor(
                      msg: 'Login', fontSize: 25, fontWeight: FontWeight.bold),
                  const SizedBox(height: 10),
                  getTxtBlackColor(
                      msg: 'Enter mobile number for login.',
                      textAlign: TextAlign.center,
                      fontSize: 16),
                  const SizedBox(height: 5),
                  getTxtGreyColor(
                      msg: 'We will send you one time \npassword (OTP).',
                      textAlign: TextAlign.center,
                      fontSize: 15),
                  const SizedBox(height: 10),
                  Obx(() {
                    // print("Deep ${LoginController.to.mobileNo}");
                    var respo = LoginController.to.callLoginRespo.value;
                    LoginRespo? data =
                        LoginController.to.callLoginRespo.value.data;
                    print("object : afa $respo");
                    if (respo.status == null) {
                      return Container();
                    } else {
                      if (respo.status == ApiStatus.loading) {
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConst.appColor),
                        );
                      } else if (respo.status == ApiStatus.error)
                        return showError(respo.message);
                      else {
                        return showError(
                            (data?.statusCode == "0") ? data?.message : '');
                      }
                    }
                  }),
                  const SizedBox(height: 5),
                  Form(
                      key: formKey,
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 3.0,
                                  offset: Offset(1.0, 1.0))
                            ],
                          ),
                          child: edtRectField(
                              control: emailCont,
                              icons: Icons.email,
                              hint: 'Email Id',
                              isShowOutline: false,
                              keyboardType: TextInputType.emailAddress),
                        ),
                        const SizedBox(height: 10),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 3.0,
                                    offset: Offset(1.0, 1.0))
                              ],
                            ),
                            child: TextFormField(
                                controller: mobileNoCont,
                                textInputAction: TextInputAction.next,
                                // maxLines: 1,
                                // maxLength: 10,
                                keyboardType: TextInputType.number,
                                // validator: ValidationHelper.validateMobile,
                                maxLength: 10,
                                decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    // fillColor: Colors.transparent,
                                    hintText: 'Phone Number',
                                    contentPadding:
                                        const EdgeInsets.only(top: 15),
                                    prefixIcon: InkWell(
                                        // onTap: () => showDialog(
                                        //     context: context,
                                        //     builder(_): _CountryCodeDialog(
                                        //       countries: _countryBean,
                                        //       onCellTap: countryCodeTap,
                                        //     )),
                                        child: SizedBox(
                                            width: 100,
                                            child: Center(
                                                child: getTxtBlackColor(
                                                    msg: _countryCode,
                                                    fontSize: 17)))))))
                      ])),
                  const SizedBox(height: 40),
                  _submitCtaButton(),
                  const SizedBox(height: 30)
                ])));
  }

  Widget _submitCtaButton() {
    return ProgressButton(
        height: 40,
        borderRadius: 8,
        progressIndicatorSize: 40,
        animate: true,
        color: ColorConst.appColor,
        width: MediaQuery.of(Get.context!).size.width * 0.45,
        child: getTxtWhiteColor(msg: "Login", fontWeight: FontWeight.w500),
        onTap: (startLoading, stopLoading, btnState) async {
          if (btnState == ButtonState.idle) {
            final form = formKey.currentState;
            if (form?.validate() == true) {
              form?.save();
              startLoading();
              await LoginController.to.authLocal(emailCont.text.toString(),
                  mobileNoCont.text.toString(), "", "");
              stopLoading();
            }
          }
        });
  }
}
