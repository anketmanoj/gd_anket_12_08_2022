// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import '../screens/testVideoEditor/TrimVideo/video_editor.dart';

class VideoEditorProvider extends ChangeNotifier {
  VideoEditorProvider();

  late double _positionFromSlider;
  late bool _showArContainer = false;
  File? _backgroundVideoFile;

  // getters

  double get positionFromSlider => _positionFromSlider;
  bool get showArContainer => _showArContainer;
  File get getBackgroundVideoFile => _backgroundVideoFile!;

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
    log("video file path = ${_backgroundVideoFile!.path}");
    notifyListeners();
  }
}
