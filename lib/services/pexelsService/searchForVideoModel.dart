// To parse this JSON data, do
//
//     final searchForVideoModel = searchForVideoModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class SearchForVideoModel {
  SearchForVideoModel({
    required this.page,
    required this.perPage,
    required this.totalResults,
    required this.url,
    required this.videos,
  });

  int page;
  int perPage;
  int totalResults;
  String url;
  List<Video> videos;

  factory SearchForVideoModel.fromJson(String str) =>
      SearchForVideoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SearchForVideoModel.fromMap(Map<String, dynamic> json) =>
      SearchForVideoModel(
        page: json["page"],
        perPage: json["per_page"],
        totalResults: json["total_results"],
        url: json["url"],
        videos: List<Video>.from(json["videos"].map((x) => Video.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "page": page,
        "per_page": perPage,
        "total_results": totalResults,
        "url": url,
        "videos": List<dynamic>.from(videos.map((x) => x.toMap())),
      };
}

class Video {
  Video({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.image,
    required this.duration,
    required this.user,
    required this.videoFiles,
    required this.videoPictures,
  });

  int id;
  int width;
  int height;
  String url;
  String image;
  int duration;
  User user;
  List<VideoFile> videoFiles;
  List<VideoPicture> videoPictures;

  factory Video.fromJson(String str) => Video.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Video.fromMap(Map<String, dynamic> json) => Video(
        id: json["id"],
        width: json["width"],
        height: json["height"],
        url: json["url"],
        image: json["image"],
        duration: json["duration"],
        user: User.fromMap(json["user"]),
        videoFiles: List<VideoFile>.from(
            json["video_files"].map((x) => VideoFile.fromMap(x))),
        videoPictures: List<VideoPicture>.from(
            json["video_pictures"].map((x) => VideoPicture.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "width": width,
        "height": height,
        "url": url,
        "image": image,
        "duration": duration,
        "user": user.toMap(),
        "video_files": List<dynamic>.from(videoFiles.map((x) => x.toMap())),
        "video_pictures":
            List<dynamic>.from(videoPictures.map((x) => x.toMap())),
      };
}

class User {
  User({
    required this.id,
    required this.name,
    required this.url,
  });

  int id;
  String name;
  String url;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "url": url,
      };
}

class VideoFile {
  VideoFile({
    required this.id,
    required this.quality,
    required this.fileType,
    required this.width,
    required this.height,
    required this.link,
  });

  int id;
  String quality;
  String fileType;
  int width;
  int height;
  String link;

  factory VideoFile.fromJson(String str) => VideoFile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VideoFile.fromMap(Map<String, dynamic> json) => VideoFile(
        id: json["id"],
        quality: json["quality"],
        fileType: json["file_type"],
        width: json["width"] == null ? null : json["width"],
        height: json["height"] == null ? null : json["height"],
        link: json["link"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "quality": quality,
        "file_type": fileType,
        "width": width == null ? null : width,
        "height": height == null ? null : height,
        "link": link,
      };
}

class VideoPicture {
  VideoPicture({
    required this.id,
    required this.picture,
    required this.nr,
  });

  int id;
  String picture;
  int nr;

  factory VideoPicture.fromJson(String str) =>
      VideoPicture.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VideoPicture.fromMap(Map<String, dynamic> json) => VideoPicture(
        id: json["id"],
        picture: json["picture"],
        nr: json["nr"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "picture": picture,
        "nr": nr,
      };
}
