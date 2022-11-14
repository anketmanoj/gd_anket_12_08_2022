// To parse this JSON data, do
//
//     final postMaterialModel = postMaterialModelFromMap(jsonString);

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class PostMaterialModel {
  PostMaterialModel({
    required this.gif,
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.usage,
    this.videoId,
    required this.layerType,
    required this.selected,
    this.imgSeq,
    this.songArtist,
    this.songTitle,
    this.songUrl,
  });

  String gif;
  String id;
  String ownerId;
  String ownerName;
  String? usage;
  String? videoId;
  String layerType;
  ValueNotifier<bool> selected = ValueNotifier<bool>(false);
  List<dynamic>? imgSeq;
  String? songUrl;
  String? songArtist;
  String? songTitle;

  factory PostMaterialModel.fromJson(String str) =>
      PostMaterialModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PostMaterialModel.fromMap(Map<String, dynamic> json) =>
      PostMaterialModel(
        gif: json["gif"],
        id: json["id"],
        ownerId: json["ownerId"],
        ownerName: json["ownerName"],
        usage: json["usage"],
        videoId: json["videoId"],
        layerType: json["layerType"],
        songUrl: json["songUrl"],
        songArtist: json["songArtist"],
        songTitle: json["songName"],
        selected: ValueNotifier<bool>(false),
        imgSeq: json["imgSeq"] ?? [],
      );

  Map<String, dynamic> toMap() => {
        "gif": gif,
        "id": id,
        "ownerId": ownerId,
        "ownerName": ownerName,
        "usage": usage,
        "videoId": videoId,
        "layerType": layerType,
      };
}
