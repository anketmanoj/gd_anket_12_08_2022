import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/promoCodeModel.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_video_page.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/recommended_video_page.dart';
import 'package:diamon_rose_app/screens/homePage/FollowingVideosFeed.dart';
import 'package:diamon_rose_app/screens/homePage/RecommendedVideosFeed.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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

  void checkPage() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(context.read<Authentication>().getUserId)
        .collection("following")
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        log("user has followers");
        homeScreenTabsController.jumpToPage(1);
        return true;
      } else {
        log("no followers");
        pageIndex.value = 0;
        return false;
      }
    });
  }

  void _submitFormPromo({
    required PromoCodeModel promoData,
    required String useruid,
  }) async {
    await FirebaseFirestore.instance
        .collection("promoTracker")
        .doc(useruid)
        .set(promoData.toMap());
  }

  @override
  void initState() {
    checkPage();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      TextEditingController _promocode = TextEditingController();
      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

      bool checkDoneOnDevice = SharedPreferencesHelper.getBool("intro");
      log("check =========== $checkDoneOnDevice");
      if (checkDoneOnDevice == false) {
        bool exists = await context
            .read<FirebaseOperations>()
            .checkUserAlreadySubmitted(
                useruid: context.read<Authentication>().getUserId);
        SharedPreferencesHelper.setBool("intro", true);
        await Get.dialog(
          SimpleDialog(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Lottie.asset("assets/carat_move.json", height: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Welcome to Glamorous Diastation",
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Please enter the Promocode if you have it to win 5 Carats!",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _promocode,
                        validator: (val) {
                          if (val!.isNotEmpty) {
                            if (val.length > 4) {
                              return "Promocode is 4 characters long";
                            }
                            if (val.length < 4) {
                              return "Promocode is 4 characters long";
                            }
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "username",
                          prefixIcon: Icon(
                            Icons.diamond,
                            color: constantColors.navButton,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: constantColors.navButton,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: constantColors.navButton,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SubmitButton(
                              color: constantColors.greenColor,
                              function: () async {
                                if (_formKey.currentState!.validate()) {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .get()
                                      .then((value) {
                                    value.docs.forEach((element) {
                                      if (element.id
                                              .toString()
                                              .substring(0, 4)
                                              .toLowerCase() ==
                                          _promocode.text.toLowerCase()) {
                                        log("user is ${element.id}");
                                        _submitFormPromo(
                                            useruid: context
                                                .read<Authentication>()
                                                .getUserId,
                                            promoData: PromoCodeModel(
                                              date: Timestamp.now(),
                                              name: context
                                                  .read<FirebaseOperations>()
                                                  .initUserName,
                                              creatorname: element['username'],
                                              promocode:
                                                  _promocode.text.toLowerCase(),
                                            ));

                                        Get.back();
                                      }
                                    });
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SubmitButton(
                              text: "Cancel",
                              function: Get.back,
                              color: constantColors.redColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
    super.initState();
  }

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
