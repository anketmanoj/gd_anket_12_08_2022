import 'package:diamon_rose_app/enum/layer_type.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LayerEntity {
  LayerEntity({
    this.key,
    this.itemId = 0,
    this.itemType = LayerType.none,
    this.position = -1,
    this.width = 0,
    this.height = 0,
    this.radian = 0,
    this.startTime,
    this.endTime,
    this.xcoordinates = 0,
    this.ycoordinates = 0,
    this.duration = 0,
    this.scale = 1,
    this.range = const RangeValues(0, 60),
    this.name = '',
    this.volume = 1,
    this.itemThumbnailUrl = '',
    this.itemUrl = '',
    this.controller,
  });

  String? key;
  int itemId;
  LayerType itemType;
  int position;
  double width;
  double height;
  double radian;
  double? startTime;
  double? endTime;
  double xcoordinates;
  double ycoordinates;
  double duration;
  double scale;
  RangeValues range;
  String name;
  double volume;
  String itemThumbnailUrl;
  String itemUrl;
  VideoPlayerController? controller;

  LayerEntity copyWith({
    int? itemId,
    String? url,
    String? key,
    String? itemThumbnailUrl,
    String? name,
    double? height,
    double? width,
    double? startTime,
    double? endTime,
    double? scale,
    double? rotation,
    double? xcoordinates,
    double? ycoordinates,
    int? position,
    double? duration,
    double? volume,
    LayerType? itemType,
    RangeValues? range,
    VideoPlayerController? controller,
  }) {
    return LayerEntity(
      key: key ?? this.key,
      itemId: itemId ?? this.itemId,
      itemUrl: url ?? this.itemUrl,
      itemThumbnailUrl: itemThumbnailUrl ?? this.itemThumbnailUrl,
      name: name ?? this.name,
      height: height ?? this.height,
      scale: scale ?? this.scale,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      radian: rotation ?? this.radian,
      width: width ?? this.width,
      xcoordinates: xcoordinates ?? this.xcoordinates,
      ycoordinates: ycoordinates ?? this.ycoordinates,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      itemType: itemType ?? this.itemType,
      range: range ?? this.range,
      controller: controller,
    );
  }
}
