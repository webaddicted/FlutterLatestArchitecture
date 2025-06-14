import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/assets_const.dart';
import 'package:pingmexx/utils/constant/color_const.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/sp/sp_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  var _visible = false;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animation.addListener(() => setState(() {}));
    animationController.forward();
    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConst.whiteColor,
        body: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              SizedBox(
                  width: animation.value * 250,
                  height: animation.value * 250, //Adapt.px(500),
                  child: Image.asset(AssetsConst.logoImg)),
              const SizedBox(height: 180),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 70),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConst.appColor))))
            ]))));
  }

  Future<void> startTime() async {
    var isOnBoardingShow = SPManager.getOnboarding();
    printLog(msg: "isOnBoardingShow $isOnBoardingShow");
    
    delayTime(
        durationSec: 5,
        click: () async {
          // Check if user is already logged in
          bool isLoggedIn = await SPManager.isLoggedIn();
          printLog(msg: "isLoggedIn $isLoggedIn");
          
          Map<String, dynamic> map = {};
          map["openFromHome"] = "Deepak Sharma";
          
          if (isLoggedIn) {
            // User is logged in, navigate to chat list
            Get.offAllNamed(RoutersConst.home, arguments: map);
          } else {
            // User is not logged in, navigate to welcome page
            Get.offAllNamed(RoutersConst.welcome, arguments: map);
          }
        });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
