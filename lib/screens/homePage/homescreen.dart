import 'dart:developer';

import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/recommended_video_page.dart';
import 'package:diamon_rose_app/screens/homePage/FollowingVideosFeed.dart';
import 'package:diamon_rose_app/screens/homePage/RecommendedVideosFeed.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:toggle_switch/toggle_switch.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  ValueNotifier<bool> recommededSelected = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final RecommendedProvider recommendedProvider =
        Provider.of<RecommendedProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              recommededSelected,
            ]),
            builder: (context, _) {
              switch (recommededSelected.value) {
                case true:
                  return RecommendedVideoPage();

                case false:
                  return FollowingVideosFeed(
                    recommendedProvider: recommendedProvider,
                  );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Positioned(
            top: size.height * 0.06,
            left: 10,
            right: 10,
            child: Center(
              child: ToggleSwitch(
                minWidth: size.width,
                totalSwitches: 2,
                activeBgColor: [
                  constantColors.navButton,
                  constantColors.navButton,
                ],
                labels: ["Recommended", "Following"],
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      recommededSelected.value = true;
                      break;
                    case 1:
                      recommededSelected.value = false;
                      break;
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
