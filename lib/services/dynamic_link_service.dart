import 'dart:developer';

import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/screens/DynamicLinkPages/DynamicLinkPostPage.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
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
        if (deepLink.queryParameters.containsKey('post_id')) {
          String id = deepLink.queryParameters['post_id']!;
          log('!!!!!!!!!!!!!!!!!!!!here');
          log(id);

          Provider.of<HomeScreenProvider>(context, listen: false)
              .setHomeScreen(false);

          Navigator.pushReplacement(
            context,
            PageTransition(
                child: DynamicLinkPostPage(videoId: id),
                type: PageTransitionType.topToBottom),
          );
        }
      }

      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
        log('@@@@@@@@@@@@@@@@@@@@@');
        log('app opened in background');
        log(dynamicLinkData.link.queryParameters.toString());
        if (dynamicLinkData.link.queryParameters.containsKey('post_id')) {
          String id = dynamicLinkData.link.queryParameters['post_id']!;
          log('!!!!!!!!!!!!!!!!!!!!there');
          log(id);

          Provider.of<HomeScreenProvider>(context, listen: false)
              .setHomeScreen(false);

          Navigator.pushReplacement(
            context,
            PageTransition(
                child: DynamicLinkPostPage(videoId: id),
                type: PageTransitionType.topToBottom),
          );
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

      // androidParameters: AndroidParameters(
      //   packageName: 'ke.co.rufw91.mared',
      //   minimumVersion: 1,
      // ),
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
}
