import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:diamon_rose_app/constants/styles/colors.dart';

import 'package:flutter/material.dart';

class VideoProgressBarWidget extends StatelessWidget {
  const VideoProgressBarWidget({
    Key? key,
    required this.currentTime,
    required this.videoDuration,
    this.barHeight,
    this.progressBarColor,
    this.baseBarColor,
    this.thumbRadius,
    this.barCapShape,
    this.timeLabelLocation,
    this.onSeek,
  }) : super(key: key);

  final int currentTime;
  final int videoDuration;
  final double? barHeight;
  final Color? progressBarColor;
  final Color? baseBarColor;
  final double? thumbRadius;
  final BarCapShape? barCapShape;
  final TimeLabelLocation? timeLabelLocation;
  final Function(Duration duration)? onSeek;

  @override
  Widget build(BuildContext context) {
    return ProgressBar(
      progress: Duration(seconds: currentTime),
      barHeight: barHeight ?? 6,
      progressBarColor: progressBarColor ?? AppColors.purple,
      baseBarColor: baseBarColor ?? Colors.white,
      total: Duration(seconds: videoDuration),
      thumbRadius: thumbRadius ?? 0,
      barCapShape: barCapShape ?? BarCapShape.round,
      timeLabelLocation: timeLabelLocation ?? TimeLabelLocation.none,
      onSeek: onSeek,
    );
  }
}
