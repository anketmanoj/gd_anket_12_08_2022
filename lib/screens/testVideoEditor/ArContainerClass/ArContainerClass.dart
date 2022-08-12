import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:just_audio/just_audio.dart';

enum LayerType {
  AR,
  Effect,
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
  });
}
