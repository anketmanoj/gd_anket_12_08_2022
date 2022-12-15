import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateModel.dart';
import 'package:flutter/material.dart';

class VideoTemplateProvider extends ChangeNotifier {
  late VideoTemplateModel _videoTemplate;
  VideoTemplateModel get videoTemplate => _videoTemplate;

  void workOnVideoTemplate({required VideoTemplateModel videoVal}) {
    _videoTemplate = videoVal;
    notifyListeners();
  }
}
