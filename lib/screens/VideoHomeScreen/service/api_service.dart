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
    await FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .where("ispaid", isEqualTo: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        Video video = Video.fromJson(element.data());
        _videos.add(video);
      });
    });

    log("done loading all videos");
  }

  static loadFollowingVideos() async {
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
        Video video = Video.fromJson(element.data());
        _following_videos.add(video);
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
