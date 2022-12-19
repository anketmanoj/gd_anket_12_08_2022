// To parse this JSON data, do
//
//     final videoTemplateModel = videoTemplateModelFromMap(jsonString);

import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateLayerEnum.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:video_player/video_player.dart';

class VideoTemplateModel {
  VideoTemplateModel({
    this.file,
    this.videoTemplateLayer,
    this.thumbnail,
    this.videoSelected,
    required this.seconds,
    this.audioFlag,
    this.intermediateFile,
    this.videoController,
  });

  File? file;
  VideoTemplateLayer? videoTemplateLayer;
  Uint8List? thumbnail;
  bool? videoSelected;
  int seconds;
  int? audioFlag;
  File? intermediateFile;
  VideoPlayerController? videoController;

  factory VideoTemplateModel.fromJson(String str) =>
      VideoTemplateModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VideoTemplateModel.fromMap(Map<String, dynamic> json) =>
      VideoTemplateModel(
        file: json["file"],
        videoTemplateLayer: json["videoTemplateLayer"],
        thumbnail: json["thumbnail"],
        videoSelected: json["videoSelected"],
        seconds: json["seconds"],
        audioFlag: json["audioFlag"],
        intermediateFile: json["intermediateFile"],
      );

  Map<String, dynamic> toMap() => {
        "file": file,
        "videoTemplateLayer": videoTemplateLayer,
        "thumbnail": thumbnail,
        "videoSelected": videoSelected,
        "seconds": seconds,
        "audioFlag": audioFlag,
        "intermediateFile": intermediateFile,
      };
}
