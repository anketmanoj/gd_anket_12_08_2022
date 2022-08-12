import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/OtherUserProfile/otherUserProfile.dart';
import 'package:diamon_rose_app/screens/ProfilePage/PostRecommendation.dart';
import 'package:diamon_rose_app/screens/homePage/multiManager/flick_multi_manager.dart';
import 'package:diamon_rose_app/screens/homePage/video_post_item.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> _recommendedList;
  @override
  void initState() {
    super.initState();
    _getListOfStringFromSharedPrefs();
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

    print("Ankeeetttt == $value");
    setState(() {
      _recommendedList = value;
    });
  }

  bool following = false;
  bool recommeded = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);

    final RecommendedProvider recommendedProvider =
        Provider.of<RecommendedProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: recommeded
                ? FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("timestamp", descending: true)
                    .where("ispaid", isEqualTo: false)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("timestamp", descending: true)
                    .where("useruid",
                        whereIn: recommendedProvider.followingUsers
                            .map((e) => "$e")
                            .toList()
                            .sublist(
                                0,
                                recommendedProvider.followingUsers.length > 10
                                    ? 10
                                    : recommendedProvider
                                        .followingUsers.length))
                    .snapshots(),
            builder: (context, videoList) {
              if (videoList.data!.docs.length != 0) {
                return Container(
                    child: PageView.builder(
                  itemCount: videoList.data!.docs.length,
                  // preloadPagesCount: 2,
                  scrollDirection: Axis.vertical,
                  pageSnapping: true,
                  itemBuilder: (BuildContext context, int position) {
                    final video = Video.fromJson(videoList.data!.docs[position]
                        .data()! as Map<String, dynamic>);

                    return Stack(
                      children: [
                        Container(
                          height: size.height,
                          width: size.width,
                          color: Colors.black,
                          child: VideoPostItem(
                            video: video,
                          ),
                        ),
                      ],
                    );
                  },
                  // controller: PreloadPageController(initialPage: 1),
                  onPageChanged: (int position) {},
                ));
              } else {
                recommeded
                    ? WidgetsBinding.instance
                        ?.addPostFrameCallback((_) => showTopSnackBar(
                              context,
                              CustomSnackBar.error(
                                message:
                                    "No posts with your recommendation selection",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: PostRecommendationScreen(),
                                      type: PageTransitionType.rightToLeft),
                                );
                              },
                            ))
                    : null;

                return recommeded
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("posts")
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder: (context, videoList) {
                          if (videoList.data!.docs.length != 0) {
                            return Container(
                                child: PageView.builder(
                              itemCount: videoList.data!.docs.length,
                              // preloadPagesCount: 2,
                              scrollDirection: Axis.vertical,
                              pageSnapping: true,
                              itemBuilder:
                                  (BuildContext context, int position) {
                                final video = Video.fromJson(
                                    videoList.data!.docs[position].data()!
                                        as Map<String, dynamic>);

                                return Stack(
                                  children: [
                                    Container(
                                      height: size.height,
                                      width: size.width,
                                      color: Colors.black,
                                      child: VideoPostItem(
                                        video: video,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              // controller: PreloadPageController(initialPage: 1),
                              onPageChanged: (int position) {},
                            ));
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(30),
                              child: Center(
                                child: Text(
                                  "No Posts in Recommended Tab",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            "No Posts for following users",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
              }
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
                      log("Recommended");
                      break;
                    case 1:
                      log("Following");
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
