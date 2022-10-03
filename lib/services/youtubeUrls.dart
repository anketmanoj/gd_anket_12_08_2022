// To parse this JSON data, do
//
//     final YoutubeTutorials = YoutubeTutorialsFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class YoutubeTutorials {
  YoutubeTutorials({
    required this.youtubeUrl,
    required this.title,
  });

  String youtubeUrl;
  String title;

  factory YoutubeTutorials.fromJson(String str) =>
      YoutubeTutorials.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory YoutubeTutorials.fromMap(Map<String, dynamic> json) =>
      YoutubeTutorials(
        youtubeUrl: json["youtubeUrl"],
        title: json["title"],
      );

  Map<String, dynamic> toMap() => {
        "youtubeUrl": youtubeUrl,
        "title": title,
      };
}
