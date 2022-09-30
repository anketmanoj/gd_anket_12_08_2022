import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/constants.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApiService extends ChangeNotifier {
  static final List<Video> _videos = [];
  static final List<Video> _following_videos = [];

  static load() async {
    _videos.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video(
            id: element['id'] as String,
            useruid: element['useruid'] as String,
            videourl: element['videourl'] as String,
            caption: element['caption'] as String,
            isPaid: element['ispaid'] as bool,
            price: element['price'] as double,
            discountAmount: double.parse(element['discountamount'].toString()),
            startDiscountDate: element['startdiscountdate'] as Timestamp,
            endDiscountDate: element['enddiscountdate'] as Timestamp,
            isSubscription: element['issubscription'] as bool,
            contentAvailability: element['contentavailability'] as String,
            isFree: element['isfree'] as bool,
            username: element['username'] as String,
            userimage: element['userimage'] as String,
            videotitle: element['videotitle'].toString(),
            videoType: element['videoType'] as String,
            timestamp: element['timestamp'] as Timestamp,
            thumbnailurl: element['thumbnailurl'].toString(),
            ownerFcmToken: element['ownerFcmToken'] as String?,
            genre: element['genre'] as List<dynamic>,
            boughtBy: element['boughtBy'] as List<dynamic>,
            totalBilled: element['totalBilled'] as int?,
            verifiedUser: element['verifiedUser'] as bool?,
            views: element['views'],
          );
          log("HEEEERRRRREEEEEEE");
          _videos.add(video);
        }
      });
    });

    log("done loading all videos");
  }

  static loadFreeOnly() async {
    _videos.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("ispaid", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video(
            id: element['id'] as String,
            useruid: element['useruid'] as String,
            videourl: element['videourl'] as String,
            caption: element['caption'] as String,
            isPaid: element['ispaid'] as bool,
            price: element['price'] as double,
            discountAmount: double.parse(element['discountamount'].toString()),
            startDiscountDate: element['startdiscountdate'] as Timestamp,
            endDiscountDate: element['enddiscountdate'] as Timestamp,
            isSubscription: element['issubscription'] as bool,
            contentAvailability: element['contentavailability'] as String,
            isFree: element['isfree'] as bool,
            username: element['username'] as String,
            userimage: element['userimage'] as String,
            videotitle: element['videotitle'].toString(),
            videoType: element['videoType'] as String,
            timestamp: element['timestamp'] as Timestamp,
            thumbnailurl: element['thumbnailurl'].toString(),
            ownerFcmToken: element['ownerFcmToken'] as String?,
            genre: element['genre'] as List<dynamic>,
            boughtBy: element['boughtBy'] as List<dynamic>,
            totalBilled: element['totalBilled'] as int?,
            verifiedUser: element['verifiedUser'] as bool?,
            views: element['views'],
          );
          log("HEEEERRRRREEEEEEE");
          _videos.add(video);
        }
      });
    });

    log("done loading all videos");
  }

  static loadPaidOnly() async {
    _videos.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("ispaid", isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video(
            id: element['id'] as String,
            useruid: element['useruid'] as String,
            videourl: element['videourl'] as String,
            caption: element['caption'] as String,
            isPaid: element['ispaid'] as bool,
            price: element['price'] as double,
            discountAmount: double.parse(element['discountamount'].toString()),
            startDiscountDate: element['startdiscountdate'] as Timestamp,
            endDiscountDate: element['enddiscountdate'] as Timestamp,
            isSubscription: element['issubscription'] as bool,
            contentAvailability: element['contentavailability'] as String,
            isFree: element['isfree'] as bool,
            username: element['username'] as String,
            userimage: element['userimage'] as String,
            videotitle: element['videotitle'].toString(),
            videoType: element['videoType'] as String,
            timestamp: element['timestamp'] as Timestamp,
            thumbnailurl: element['thumbnailurl'].toString(),
            ownerFcmToken: element['ownerFcmToken'] as String?,
            genre: element['genre'] as List<dynamic>,
            boughtBy: element['boughtBy'] as List<dynamic>,
            totalBilled: element['totalBilled'] as int?,
            verifiedUser: element['verifiedUser'] as bool?,
            views: element['views'],
          );
          log("HEEEERRRRREEEEEEE");
          _videos.add(video);
        }
      });
    });

    log("done loading all videos");
  }

  static loadFollowingVideos() async {
    _following_videos.clear();
    List<String> followingUsers =
        SharedPreferencesHelper.getListString("followersList");

    log("following users list = ${followingUsers.length}");
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("useruid",
            whereIn: followingUsers.map((e) => "$e").toList().sublist(
                0, followingUsers.length > 10 ? 10 : followingUsers.length))
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video.fromJson(element.data());
          _following_videos.add(video);
        }
      });
    });

    log("done loading all following videos");
  }

  static loadFollowingFreeVideos() async {
    _following_videos.clear();
    List<String> followingUsers =
        SharedPreferencesHelper.getListString("followersList");

    log("following users list = ${followingUsers.length}");
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("useruid",
            whereIn: followingUsers.map((e) => "$e").toList().sublist(
                0, followingUsers.length > 10 ? 10 : followingUsers.length))
        .where("ispaid", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video.fromJson(element.data());
          _following_videos.add(video);
        }
      });
    });

    log("done loading all following videos");
  }

  static loadFollowingPaidVideos() async {
    _following_videos.clear();
    List<String> followingUsers =
        SharedPreferencesHelper.getListString("followersList");

    log("following users list = ${followingUsers.length}");
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("useruid",
            whereIn: followingUsers.map((e) => "$e").toList().sublist(
                0, followingUsers.length > 10 ? 10 : followingUsers.length))
        .where("ispaid", isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data().containsKey("views") &&
            element.data().containsKey("totalBilled") &&
            element.data().containsKey("verifiedUser")) {
          Video video = Video.fromJson(element.data());
          _following_videos.add(video);
        }
      });
    });

    log("done loading all following videos");
  }

  /// Simulate api call
  static Future<List<Video>> getVideos({int id = 0}) async {
    // No more videos
    if ((id >= _videos.length)) {
      return [];
    }

    await Future.delayed(const Duration(seconds: kLatency));

    if ((id + kNextLimit >= _videos.length)) {
      return _videos.sublist(id, _videos.length);
    }

    return _videos.sublist(id, _videos.length);
  }

  /// Simulate api call
  static Future<List<Video>> getFollowingVideos({int id = 0}) async {
    // No more videos
    if ((id >= _following_videos.length)) {
      return [];
    }

    await Future.delayed(const Duration(seconds: kLatency));

    if ((id + kNextLimit >= _videos.length)) {
      return _following_videos.sublist(id, _following_videos.length);
    }

    return _following_videos.sublist(id, _following_videos.length);
  }
}
