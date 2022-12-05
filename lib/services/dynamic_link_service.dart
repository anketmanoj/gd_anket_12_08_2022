import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/screens/DynamicLinkPages/DynamicLinkPostPage.dart';
import 'package:diamon_rose_app/screens/OtherUserProfile/otherUserProfile.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/screens/mainPage/signup_screen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class DynamicLinkService {
  static Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        ///
        log('@@@@@@@@@@@@@@@@@@@@@');
        log('app opened in foreground');
        log(deepLink.queryParameters.toString());

        // ! For Posts
        if (deepLink.queryParameters.containsKey('post_id')) {
          String id = deepLink.queryParameters['post_id']!;
          log('!!!!!!!!!!!!!!!!!!!!here');
          log(id);

          Provider.of<HomeScreenProvider>(context, listen: false)
              .setHomeScreen(false);

          Video videoVal = await context
              .read<FirebaseOperations>()
              .getVideoPosts(videoId: id);
          Navigator.push(
              context,
              PageTransition(
                  child: PostDetailsScreen(
                    video: videoVal,
                  ),
                  type: PageTransitionType.fade));
        }

        // ! For User
        if (deepLink.queryParameters.containsKey('user_id')) {
          String id = deepLink.queryParameters['user_id']!;
          log('!!!!!!!!!!!!!!!!!!!!here User');
          log(id);

          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .get()
              .then((value) {
            final UserModel userModel = UserModel.fromMap(value.data()!);
            Navigator.pushReplacement(
              context,
              PageTransition(
                  child: OtherUserProfile(
                    userModel: userModel,
                    fromLink: true,
                  ),
                  type: PageTransitionType.topToBottom),
            );
          });
        }
      }

      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
        log('@@@@@@@@@@@@@@@@@@@@@');
        log('app opened in background');
        log(dynamicLinkData.link.queryParameters.toString());

        // ! For Posts
        if (dynamicLinkData.link.queryParameters.containsKey('post_id')) {
          String id = dynamicLinkData.link.queryParameters['post_id']!;
          log('!!!!!!!!!!!!!!!!!!!!there');
          log(id);

          Provider.of<HomeScreenProvider>(context, listen: false)
              .setHomeScreen(false);

          Video videoVal = await context
              .read<FirebaseOperations>()
              .getVideoPosts(videoId: id);
          Navigator.push(
              context,
              PageTransition(
                  child: PostDetailsScreen(
                    video: videoVal,
                  ),
                  type: PageTransitionType.fade));
        }

        // ! For User
        if (dynamicLinkData.link.queryParameters.containsKey('user_id')) {
          String id = dynamicLinkData.link.queryParameters['user_id']!;
          log('!!!!!!!!!!!!!!!!!!!!there user');
          log(id);

          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .get()
              .then((value) {
            final UserModel userModel = UserModel.fromMap(value.data()!);
            Navigator.pushReplacement(
              context,
              PageTransition(
                  child: OtherUserProfile(
                    userModel: userModel,
                    fromLink: true,
                  ),
                  type: PageTransitionType.topToBottom),
            );
          });
        }
        // ! For Sign Up
        if (dynamicLinkData.link.queryParameters.containsKey('sign_up')) {
          String id = dynamicLinkData.link.queryParameters['sign_up']!;
          log('Send User To sign Up screen');

          if (await FirebaseAuth.instance.currentUser != null) {
            log("user already logged in");
          } else {
            unawaited(Navigator.pushReplacement(
                context,
                PageTransition(
                    child: MainPage(), type: PageTransitionType.fade)));
          }
        }
      }).onError((error) {
        // Handle errors
      });
    } catch (e) {
      log(e.toString());
    }
  }

  ///createDynamicLink()
  static Future<Uri> createDynamicLink(String id, {bool short = false}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://diamantrosegd.page.link',
      link: Uri.parse('https://gd.diamantrose.com/?post_id=$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.diamant.jp.gd_anket',
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.diamant.jp.diamond-app',
        minimumVersion: '1',
        appStoreId: '1600649951',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await FirebaseDynamicLinks.instance.buildLink(parameters);
    }

    log("url ==$url");

    return url;
  }

  static Future<Uri> createUserProfileDynamicLink(String id,
      {bool short = true}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://diamantrosegd.page.link',
      link: Uri.parse('https://gd.diamantrose.com/?user_id=$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.diamant.jp.gd_anket',
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.diamant.jp.diamond-app',
        minimumVersion: '1',
        appStoreId: '1600649951',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await FirebaseDynamicLinks.instance.buildLink(parameters);
    }

    log("url ==$url");

    return url;
  }

  static Future<Uri> createSignUpScreenDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://diamantrosegd.page.link',
      link: Uri.parse('https://gd.diamantrose.com/?sign_up=true'),
      androidParameters: AndroidParameters(
        packageName: 'com.diamant.jp.gd_anket',
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.diamant.jp.diamond-app',
        minimumVersion: '1',
        appStoreId: '1600649951',
      ),
    );

    Uri url;

    final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    url = shortLink.shortUrl;

    log("url ==$url");

    return url;
  }
}
