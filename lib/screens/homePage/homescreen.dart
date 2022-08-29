import 'dart:developer';
import 'dart:io';

import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_video_page.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/recommended_video_page.dart';
import 'package:diamon_rose_app/screens/homePage/FollowingVideosFeed.dart';
import 'package:diamon_rose_app/screens/homePage/RecommendedVideosFeed.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:toggle_switch/toggle_switch.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController homeScreenTabsController = PageController();
  ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageIndex,
      builder: (context, page, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView(
                controller: homeScreenTabsController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  pageIndex.value = page;
                },
                children: [
                  RecommendedVideoPage(),
                  FollowingVideoPage(),
                ],
              ),
              Positioned(
                top: 6.h,
                left: 10,
                right: 10,
                child: Provider.of<HomeScreenProvider>(context, listen: false)
                    .topTabBar(
                  context,
                  pageIndex.value,
                  homeScreenTabsController,
                ),
              )
            ],
          ),
        );
      },
    );
    // return Scaffold(
    //   backgroundColor: Colors.black,

    // body: Stack(
    //   children: [
    //     AnimatedBuilder(
    //       animation: Listenable.merge([
    //         recommededSelected,
    //       ]),
    //       builder: (context, _) {
    //         switch (recommededSelected.value) {
    //           case true:
    //             return RecommendedVideoPage();

    //           case false:
    //             return FollowingVideosFeed(
    //               recommendedProvider: recommendedProvider,
    //             );
    //         }

    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       },
    //     ),
    //     Positioned(
    //       top: size.height * 0.06,
    //       left: 10,
    //       right: 10,
    //       child: Center(
    //         child: ToggleSwitch(
    //           minWidth: size.width,
    //           totalSwitches: 2,
    //           activeBgColor: [
    //             constantColors.navButton,
    //             constantColors.navButton,
    //           ],
    //           labels: ["Recommended", "Following"],
    //           onToggle: (index) {
    //             switch (index) {
    //               case 0:
    //                 recommededSelected.value = true;
    //                 break;
    //               case 1:
    //                 recommededSelected.value = false;
    //                 break;
    //             }
    //           },
    //         ),
    //       ),
    //     )
    //   ],
    // ),
    // );
  }
}
