import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pingmexx/controller/theme_controller.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/constant/color_const.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/utils/widgethelper/dummy_data.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";
  List<String>? imageUrls = categoryImages["All"];
  var isDarkTheme = false;
  @override
  void initState() {
    super.initState();
    imageUrls = categoryImages[selectedCategory]!;
  }

  @override
  Widget build(BuildContext context) {
    removeSoftKeyboard();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          onWillPop();
        }
      },
      child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(logoImageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTxtBlackColor(msg: "Good Morning", fontSize: 14),
                            getTxtBlackColor(msg: "Deepak Sharma", fontSize: 16, fontWeight: FontWeight.bold),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          isDarkTheme = !isDarkTheme;
                          ThemeController.to.changeTheme(isDarkTheme);
                        },
                        icon: const Icon(Icons.add_box_outlined, size: 28),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search Day's, Category & more",
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                            imageUrls = categoryImages[selectedCategory]!;
                          });
                        },
                        child: categoryChip(category, selected: isSelected),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                // --- PageView with images and buttons
                Expanded(
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: imageUrls?.length,
                    scrollBehavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    itemBuilder: (context, index) {
                      String item = imageUrls![index];
                      return InkWell(
                        onTap: () {
                          Map<String, dynamic> map = {};
                          map["imgUrl"] = item;
                         // Get.toNamed(RoutersConst.fullScreen,arguments: map);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => FullScreen(bgImage: item)),
                          // );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Image.network(
                                          item,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            debugPrint('Error loading image: $error');
                                            return const Center(
                                              child: Text('Error loading image'),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Buttons row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.black),
                                      onPressed: () {
                                        Map<String, dynamic> map = {};
                                        map["imgUrl"] = item;
                                        // Get.toNamed(RoutersConst.fullScreen,arguments: map);
                                      },
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: const Icon(Icons.whatshot, color: Colors.green),
                                      onPressed: () {
                                        // _imageOverlayKey.currentState?.shareImage();
                                      },
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: const Icon(Icons.download, color: Colors.black),
                                      onPressed: () {
                                        // _imageOverlayKey.currentState?.downloadImage();
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      Map<String, dynamic> map = {};
                                      map["imgUrl"] = item;
                                      // Get.toNamed(RoutersConst.fullScreen,arguments: map);
                                    },
                                    child: const Text(
                                      'Change Photo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  Widget categoryChip(String label, {bool selected = false}) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: getTxtColor(
        msg: label,
          txtColor: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
      ),
    );
  }

}

