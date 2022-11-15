import 'dart:io';

import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:diamon_rose_app/services/img_seq_animator.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum LayerType {
  AR,
  Effect,
  Music,
}

class ARList {
  String? arId;
  int? arIndex;
  double? height;
  double? width;
  double? scale;
  double? rotation;
  double? xPosition;
  double? yPosition;
  List<String>? pathsForVideoFrames;
  double? startingPositon;
  double? endingPosition;
  double? totalDuration;
  double? currentProgress;
  ValueNotifier<bool>? showAr;
  ImageSequenceAnimatorState? arState;
  AudioPlayer? audioPlayer;
  LayerType? layerType;
  String? compositeFilePath;
  GlobalKey? arKey;
  String? gifFilePath;
  bool? fromFirebase;
  String? mainFile;
  String? alphaFile;
  bool? audioFlag;
  ValueNotifier<bool>? finishedCaching;
  int? fps;
  String? ownerId;
  String? ownerName;
  ValueNotifier<bool>? selectedMaterial = ValueNotifier<bool>(true);
  ValueNotifier<Matrix4>? notifier = ValueNotifier(Matrix4.identity());
  File? arCutOutFile;
  File? musicFile;
  double? xOffset;
  double? yOffset;
  String? youtubeUrl;
  String? youtubeArtistName;
  String? youtubeTitle;
  String? youtubeAlbumCover;
  int? audioStart;
  int? audioEnd;

  ARList({
    this.arIndex,
    this.height,
    this.rotation,
    this.scale,
    this.width,
    this.xPosition,
    this.yPosition,
    this.pathsForVideoFrames,
    this.startingPositon,
    this.endingPosition,
    this.totalDuration,
    this.currentProgress,
    this.showAr,
    this.arState,
    this.audioPlayer,
    this.layerType,
    this.compositeFilePath,
    this.arKey,
    this.gifFilePath,
    this.arId,
    this.fromFirebase,
    this.mainFile,
    this.alphaFile,
    this.audioFlag,
    this.finishedCaching,
    this.fps,
    this.ownerId,
    this.ownerName,
    this.selectedMaterial,
    this.notifier,
    this.arCutOutFile,
    this.musicFile,
    this.xOffset,
    this.yOffset,
    this.youtubeArtistName,
    this.youtubeTitle,
    this.youtubeUrl,
    this.youtubeAlbumCover,
    this.audioStart,
    this.audioEnd,
  });
}
