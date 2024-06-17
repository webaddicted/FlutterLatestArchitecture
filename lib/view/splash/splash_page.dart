import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medibot/utils/constant/assets_const.dart';
import 'package:medibot/utils/constant/color_const.dart';
import 'package:medibot/utils/constant/routers_const.dart';

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
    _startTime();
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

  _startTime() async {
    Future.delayed(const Duration(seconds: 4), () {
      Get.offAllNamed(RoutersConst.login);
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
