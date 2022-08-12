// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';

import '../screens/testVideoEditor/TrimVideo/video_editor.dart';

class VideoEditorProvider extends ChangeNotifier {
  VideoEditorProvider();

  late double _positionFromSlider;
  late bool _showArContainer = false;

  // getters

  double get positionFromSlider => _positionFromSlider;
  bool get showArContainer => _showArContainer;

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
}
