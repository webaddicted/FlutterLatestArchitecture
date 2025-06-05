import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:medibot/utils/constant/assets_const.dart';
import 'package:medibot/utils/constant/color_const.dart';
import 'package:medibot/utils/constant/routers_const.dart';
import 'package:medibot/utils/widgethelper/widget_helper.dart';
import 'package:medibot/view/widget/slide_dots.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: sliderLayout());

  bool inFinalPage() {
    if (_currentPage == sliderArrayList.length - 1) {
      return true;
    }
    return false;
  }

  Widget sliderLayout() => Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: sliderArrayList.length,
            itemBuilder: (ctx, i) => pageWidget(i),
          ),
        ),
        Container(
            padding: const EdgeInsets.only(left: 10, right: 20, bottom: 15),
            alignment: Alignment.bottomCenter,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!inFinalPage())
                    InkWell(
                      onTap: () {
                        Map<String, dynamic> map = {};
                        map["openFromHome"] = false;
                        Get.offAllNamed(RoutersConst.login,
                            arguments: map);
                      },
                      child: getTxtBlackColor(
                        msg: 'SKIP',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                  Container(
                      child: inFinalPage()
                          ? getStartBtn()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                for (int i = 0; i < sliderArrayList.length; i++)
                                  if (i == _currentPage)
                                    SlideDots(true)
                                  else
                                    SlideDots(false)
                              ],
                            )),
                  if (!inFinalPage())
                    FloatingActionButton(
                        backgroundColor: ColorConst.whiteColor,
                        child: Icon(
                          Icons.arrow_forward,
                          color: ColorConst.appColor,
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                        })
                ]))
      ]);

  Widget pageWidget(int index) {
    Slider slider = sliderArrayList[index];
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: Get.width,
            height: Get.height * 0.556,
            child: SvgPicture.asset(
              slider.sliderImageUrl,
              width: Get.width,
            ),
            //   decoration: BoxDecoration(
            //       image: DecorationImage(
            //           fit: BoxFit.fill,
            //           image:AssetImage(sliderArrayList[index].sliderImageUrl))),
            // ),
          ),
          const SizedBox(height: 20),
          getTxtColor(
            msg: slider.sliderHeading,
            fontWeight: FontWeight.w700,
            txtColor: ColorConst.appColor,
            fontSize: 21,
          ),
          const SizedBox(height: 10),
          Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: getTxtGreyColor(
                      msg: slider.sliderSubHeading,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center)))
        ]);
  }

  Widget getStartBtn() {
    return Expanded(
        child: SizedBox(
            height: 45.0,
            width: 140.0,
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
                onPressed: () async {
                  Map<String, dynamic> map = {};
                  map["openFromHome"] = false;
                  Get.offAllNamed(RoutersConst.login, arguments: map);
                },
                color: ColorConst.appColor,
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                        child: getTxtWhiteColor(
                            msg: "GET STARTED",
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0))))));
  }
}

class Slider {
  final String sliderImageUrl;
  final String sliderHeading;
  final String sliderSubHeading;
  final String skipBtn;

  Slider(
      {required this.sliderImageUrl,
      required this.sliderHeading,
      required this.sliderSubHeading,
      this.skipBtn = ''});
}

final sliderArrayList = [
  Slider(
      sliderImageUrl: AssetsConst.logoImg,
      sliderHeading: 'Explore Stunning Wallpapers',
      sliderSubHeading:
          'Browse a vast collection of beautiful wallpapers that suit your style. Find the perfect design for any mood or occasion and enjoy unlimited access for free.',
      skipBtn: 'SKIP'),
  Slider(
      sliderImageUrl: AssetsConst.logoImg,
      sliderHeading: 'Customize with Ease',
      sliderSubHeading:
          'Effortlessly set wallpapers on your lock screen, home screen, or both. Download and share your favorite designs instantly, making personalization seamless.',
      skipBtn: 'SKIP'),
  Slider(
      sliderImageUrl: AssetsConst.logoImg,
      sliderHeading: 'Save Your Favorites',
      sliderSubHeading:
          'Keep track of the wallpapers you love by adding them to your favorites. Preview how they look on your screen before setting them up for the perfect fit.',
      skipBtn: ""),
];
