// To parse this JSON data, do
//
//     final youtubeFileModel = youtubeFileModelFromMap(jsonString);

import 'dart:io';

import 'package:meta/meta.dart';
import 'dart:convert';

class YoutubeFileModel {
  YoutubeFileModel({
    required this.audioFile,
    required this.videoFile,
  });

  File audioFile;
  File videoFile;

  factory YoutubeFileModel.fromJson(String str) =>
      YoutubeFileModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory YoutubeFileModel.fromMap(Map<String, dynamic> json) =>
      YoutubeFileModel(
        audioFile: json["audioFile"],
        videoFile: json["videoFile"],
      );

  Map<String, dynamic> toMap() => {
        "audioFile": audioFile,
        "videoFile": videoFile,
      };
}
