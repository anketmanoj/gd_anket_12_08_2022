import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/feed_page_provider.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/NotificationPage/notificationScreen.dart';
import 'package:diamon_rose_app/screens/PostPage/postScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/profile_screen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/injection.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/videoFeedScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/recommended_video_page.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/select_model/select_model_screen.dart';
import 'package:diamon_rose_app/screens/homePage/homescreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/screens/notificationsBottomTab/notificationsTab.dart';
import 'package:diamon_rose_app/screens/searchPage/searchScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/VideoCreationOptionsScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgServerTest.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/videoEditorTest.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart' hide Trans;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class FeedPage extends StatefulWidget {
  FeedPage({Key? key, this.pageIndexValue = 0}) : super(key: key);
  final int pageIndexValue;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final PageController homepageController = PageController();
  ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void checkPage(int value) {
    if (value != 0) {
      log("jumping");
      homepageController.jumpToPage(
        value,
      );
      log("jumpiindex updated ng");
      pageIndex.value = value;
    }
  }

  Future<void> load() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top]);
    }

    _fcm.getAPNSToken().then((value) => print("APN Token === $value"));

    String? token = await _fcm.getToken();
    assert(token != null);

    Provider.of<FirebaseOperations>(context, listen: false).setFcmToken(token!);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .update({
      'token': token,
    });

    await Provider.of<RecommendedProvider>(context, listen: false)
        .setFollowingUsers(context: context)
        .whenComplete(() {
      log("following users set here | ${Provider.of<Authentication>(context, listen: false).getUserId}");
    });

    SharedPreferencesHelper.setString("userid",
        "${Provider.of<Authentication>(context, listen: false).getUserId}");
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SystemChrome.setEnabledSystemUIOverlays([]);
      checkPage(widget.pageIndexValue);
      await load();
      await Provider.of<FirebaseOperations>(context, listen: false)
          .initUserData(context)
          .whenComplete(() async {
        await Provider.of<FirebaseOperations>(context, listen: false)
            .initSocialMediaLinks(
          context: context,
          uid: Provider.of<Authentication>(context, listen: false).getUserId,
        );
        setState(() {});
        print(
            'initUserData completed, user data is now ready to be used || ${Provider.of<FirebaseOperations>(context, listen: false).fcmToken}');
      });

      await DefaultCacheManager().emptyCache();
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      DynamicLinkService.retrieveDynamicLink(context);
    });

    super.initState();
  }

  showConnectionMsg() async {
    final bool showMessage =
        SharedPreferencesHelper.getBool("dontShowInternetWarning");

    if (showMessage == false) {
      final ValueNotifier<bool> dontShowMessage = ValueNotifier<bool>(false);
      await Get.dialog(
        SimpleDialog(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Glamorous Diastation is meant to be used with a stable internet connection.\n\nPlease ensure your internet connection is stable for the best possible experience!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: constantColors.navButton,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: dontShowMessage,
                builder: (context, messageOpt, _) {
                  return ListTile(
                    title: Text("Dont show message again"),
                    trailing: Checkbox(
                      value: dontShowMessage.value,
                      onChanged: (v) {
                        dontShowMessage.value = !dontShowMessage.value;
                      },
                    ),
                  );
                }),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      constantColors.navButton),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  SharedPreferencesHelper.setBool(
                      "dontShowInternetWarning", dontShowMessage.value);
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    Text(
                      LocaleKeys.understood.tr(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeScreenProvider homeScreenProvider =
        Provider.of<HomeScreenProvider>(context, listen: false);

    return ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, page, _) {
          return SafeArea(
            top: false,
            bottom: Platform.isIOS ? false : true,
            child: WillPopScope(
              onWillPop: () async {
                if (pageIndex == 0) {
                  return false;
                } else {
                  homepageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  return false;
                }
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                body: PageView(
                  controller: homepageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    pageIndex.value = page;
                    // log("value == $page");

                    if (pageIndex.value == 0) {
                      homeScreenProvider.setHomeScreen(true);
                    } else {
                      homeScreenProvider.setHomeScreen(false);
                    }

                    if (pageIndex.value == 2) {
                      showConnectionMsg();
                    }
                  },
                  children: [
                    // * testing out new way to load videos
                    // VideoFeedScreen(),
                    // VideoPage(),
                    HomeScreen(),
                    SearchScreen(),
                    // PostScreen(),
                    // TestVideoEditor(),
                    // SelectModelScreen(),
                    VideoCreationOptionsScreen(),
                    // ImgServerTest(
                    //   title: "Test",
                    // ),
                    NotificationsTab(),
                    ProfileScreen(),
                  ],
                ),
                bottomNavigationBar: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                      bottom: 0,
                      child:
                          Provider.of<FeedPageHelpers>(context, listen: false)
                              .bottomNavBar(
                        context,
                        pageIndex.value,
                        homepageController,
                      ),
                    ),
                    Positioned(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              homepageController.jumpToPage(2);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 0.5, 0.9],
                                  colors: [
                                    Color(0xFF760380),
                                    Color(0xFFE6ADFF),
                                    Colors.white,
                                  ],
                                ),
                              ),
                              child: Icon(
                                EvaIcons.plusCircleOutline,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
