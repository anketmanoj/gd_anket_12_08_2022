import 'dart:developer';

import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/homePage/FollowingVideosFeed.dart';
import 'package:diamon_rose_app/screens/homePage/RecommendedVideosFeed.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<List<String>> _recommendedList = ValueNotifier<List<String>>([
    'Musician',
    'Performer',
    'Dance',
    'Cosplayers',
    'Movie',
    'Actor',
  ]);
  @override
  void initState() {
    super.initState();
    _getListOfStringFromSharedPrefs();
    log("homescreen");
  }

  @override
  void dispose() {
    super.dispose();
  }

  // print all values in key selected_recommendations in shared preference
  Future<void> _getListOfStringFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_recommendations';
    final value = prefs.getStringList(key) ??
        [
          'Musician',
          'Performer',
          'Dance',
          'Cosplayers',
          'Movie',
          'Actor',
          'Fashion',
          'Landscape',
          'Sports',
          'Animals',
          'Space',
          'Art',
          'Mystery',
          'Airplane',
          'Games',
          'Food',
          'Romance',
          'Sexy',
          'Science fiction',
          'Car',
          'Jobs',
          'Anime',
          'Ship',
          'Railroads',
          'Building',
          'Health',
          'Science',
          'Natural',
          'Machine',
          'Trip',
          'Travel',
          'Fantasy',
          'Funny',
          'Beauty',
        ];

    _recommendedList.value = value;
  }

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
              _recommendedList,
              recommededSelected,
            ]),
            builder: (context, _) {
              switch (recommededSelected.value) {
                case true:
                  return RecommendedVideosFeed();

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
