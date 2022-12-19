import 'dart:developer';

import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateModel.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTemplateProvider extends ChangeNotifier {
  late VideoTemplateModel _videoTemplate;
  VideoTemplateModel get videoTemplate => _videoTemplate;

  VideoTemplateModel? _videoTemplateSelected = null;
  VideoTemplateModel? get getVideoTemplateSelected => _videoTemplateSelected;

  List<VideoPlayerController> _videoControllers = [];
  List<VideoPlayerController> get getVideoControllersList => _videoControllers;

  VideoPlayerController? _currentPlayer;
  VideoPlayerController? _prevPlayer;
  VideoPlayerController? _nextPlayer;

  bool _isPlayingVideo = false;
  bool get isPlayingVideo => _isPlayingVideo;

  void playAllControllers(
      {required List<VideoTemplateModel> videoTemplateList}) async {
    _isPlayingVideo = true;
    notifyListeners();
    log("set is playing video : True");
    for (VideoTemplateModel video in videoTemplateList) {
      if (_isPlayingVideo == true) {
        selectVideoTemplate(videoVal: video);
        log("+is playing video value : $_isPlayingVideo");
        await Future.delayed(Duration(seconds: video.seconds));
      }
    }
  }

  void resetAllParams() {
    _videoTemplateSelected = null;
    _isPlayingVideo = false;
    _currentPlayer = null;
    _prevPlayer = null;
    notifyListeners();
  }

  void pauseVideo() {
    _currentPlayer!.pause();
    _isPlayingVideo = false;
    notifyListeners();
    log("set is playing video : False");
  }

  void playVideo({required List<VideoTemplateModel> videoTemplateList}) {
    if (videoTemplateList.isNotEmpty) {
      playAllControllers(videoTemplateList: videoTemplateList);
      _isPlayingVideo = true;
      notifyListeners();
    }
  }

  void workOnVideoTemplate({required VideoTemplateModel videoVal}) {
    _videoTemplate = videoVal;
    notifyListeners();
  }

  void selectVideoTemplate({required VideoTemplateModel videoVal}) async {
    if (_currentPlayer != null) {
      _prevPlayer = _currentPlayer;
      _prevPlayer!.dispose();
    }
    _videoTemplateSelected = videoVal;

    final VideoPlayerController _videoController =
        VideoPlayerController.file(_videoTemplateSelected!.file!)..initialize();

    _currentPlayer = _videoController;

    _videoTemplateSelected!.videoController = _currentPlayer;
    await _videoTemplateSelected!.videoController!.play();
    notifyListeners();
  }

  void addToVideoControllersList(VideoPlayerController controller) {
    _videoControllers.add(controller);
    log("added controller");
    notifyListeners();
  }

  void removeFromVideoControllersList(VideoPlayerController controller) {
    _videoControllers.remove(controller);
    log("removed controller");
    notifyListeners();
  }

  void resetVideoControllersList() {
    _videoControllers = [];
    log("removed controller");
    notifyListeners();
  }
}
