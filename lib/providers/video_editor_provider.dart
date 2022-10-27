// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/screens/PostPage/postMaterialModel.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart';

import '../screens/testVideoEditor/TrimVideo/video_editor.dart';

class VideoEditorProvider extends ChangeNotifier {
  VideoEditorProvider();

  late double _positionFromSlider;
  late bool _showArContainer = false;
  late File _backgroundVideoFile;
  late File _finalVideoFile;
  late VideoEditorController _backgroundVideoController;
  late VideoEditorController _afterEditorVideoController;
  late VideoPlayerController _videoController;
  late File _bgMaterialThumnailFile;
  late File _coverGif;
  late File _coverImage;
  late File _afterFinalTouchesFrame;
  PostMaterialModel? _backgroundVideoId;

  // getters

  double get positionFromSlider => _positionFromSlider;
  bool get showArContainer => _showArContainer;
  File get getBackgroundVideoFile => _backgroundVideoFile;
  File get getFinalVideoFile => _finalVideoFile;
  VideoEditorController get getBackgroundVideoController =>
      _backgroundVideoController;
  VideoEditorController get getAfterEditorVideoController =>
      _afterEditorVideoController;
  VideoPlayerController get getVideoPlayerController => _videoController;
  File get getBgMaterialThumnailFile => _bgMaterialThumnailFile;
  File get getCoverGif => _coverGif;
  File get getCoverImage => _coverImage;
  File get getAfterFinalTouchesFrame => _afterFinalTouchesFrame;
  PostMaterialModel? get getBackgroundVideoId => _backgroundVideoId;

  void setBackgroundVideoId(PostMaterialModel? videoID) {
    _backgroundVideoId = videoID;
    notifyListeners();
  }

  void setPositionFromSlider(double value) {
    _positionFromSlider = value;
    notifyListeners();

    print(" setPositionFromSlider: $value");
  }

  void setShowArContainer(bool value) {
    _showArContainer = value;
    notifyListeners();

    print(" setShowArContainer: $value");
  }

  void setBackgroundVideoFile(File video) {
    _backgroundVideoFile = video;
    log("video file path = ${_backgroundVideoFile.path}");
    notifyListeners();
  }

  void setFinalVideoFile(File video) {
    _finalVideoFile = video;
    log("final file path = ${_finalVideoFile.path}");
    notifyListeners();
  }

  void setVideoPlayerController() {
    _videoController = _backgroundVideoController.video;
    log("video controller set path ");
    notifyListeners();
  }

  void setCoverGif(File gifFile) {
    _coverGif = gifFile;
    notifyListeners();
  }

  void setCoverImage(File imgFile) {
    _coverImage = imgFile;
    notifyListeners();
  }

  void setBackgroundVideoController() {
    _backgroundVideoController = VideoEditorController.file(
      _backgroundVideoFile,
      maxDuration: Duration(seconds: 60),
      trimStyle: TrimSliderStyle(),
    )..initialize();
    log("video controller set");
    notifyListeners();
  }

  Future<void> setBgMaterialThumnailFile() async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/bgThumbnail.jpg";

    await FFmpegKit.execute(
            "-y -i ${_backgroundVideoFile.path} -vf scale=-2:480 -vframes 1 ${outputPath}")
        .then((value) {
      // final coverGif = File(join(rawDocumentPath, "coverGIf.jpg"));
      // coverGif.writeAsBytesSync(
      //     Uint8List.fromList(File(outputPath).readAsBytesSync()));
      // log("done writing file == ${coverGif.path}");
      _bgMaterialThumnailFile = File(outputPath);
      notifyListeners();
    });
    log("done bg gif");
  }

  Future<void> setCoverImageFrame({required File afterFinalTouches}) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/coverImage.jpg";

    await FFmpegKit.execute(
            "-y -i ${afterFinalTouches.path} -vf scale=-2:480 -vframes 1 ${outputPath}")
        .then((value) {
      _afterFinalTouchesFrame = File(outputPath);
      notifyListeners();
    });
    log("done coverImage complete");
  }

  Future<void> setAfterEditorVideoController(File videoFile) async {
    _afterEditorVideoController = VideoEditorController.file(
      videoFile,
      maxDuration: const Duration(seconds: 60),
      trimStyle: TrimSliderStyle(),
    );
    await _afterEditorVideoController.initialize();

    await _afterEditorVideoController.video.setLooping(false);
    log("video controller set (After video editor)");
    notifyListeners();
  }
}
