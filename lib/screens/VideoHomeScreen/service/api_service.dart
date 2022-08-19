import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/constants.dart';
import 'package:diamon_rose_app/services/video.dart';

class ApiService {
  static final List<Video> _videos = [];

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
}
