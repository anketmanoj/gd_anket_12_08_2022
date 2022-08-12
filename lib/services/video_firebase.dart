import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/services/video.dart';

class VideosAPI {
  List<Video> listVideos = <Video>[];

  // ignore: sort_constructors_first
  VideosAPI() {
    load();
  }

  // ignore: avoid_void_async
  void load() async {
    listVideos = await getVideoList();
  }

  Future<List<Video>> getVideoList() async {
    final data = await FirebaseFirestore.instance.collection("posts").get();

    final videoList = <Video>[];
    var videos;

    if (data.docs.length == 0) {
      videos = await FirebaseFirestore.instance.collection("posts").get();
    } else {
      videos = data;
    }

    videos.docs.forEach((element) {
      final Video video = Video.fromJson(element.data());
      videoList.add(video);
    });

    return videoList;
  }
}
