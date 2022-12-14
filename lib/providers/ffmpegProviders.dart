import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart' show rootBundle;

class FFmpegProvider extends ChangeNotifier {
  bool loading = false;
  File? gifThumbnail;
  VideoPlayerController? controller;
  late File outputFile;
  late File thumbnailFile;
  late File bgThumbnailFile;

  File get getThumbnailFile => thumbnailFile;
  File get getBgThumbnailFile => bgThumbnailFile;
  File get getOutputFile => outputFile;

  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split('.')[0].padLeft(8, '0');
  }

  Future<File> thumbnailCreator({required String vidFilePath}) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/thumbnail.gif";

    final value = await FFprobeKit.execute(
        "-i ${vidFilePath} -show_entries format=duration -v quiet -of json");

    log("value == ${value}");

    final String? mapOutput = await value.getOutput();

    log("Map output == ${mapOutput}");

    final Map<String, dynamic> json = jsonDecode(mapOutput!);

    String durationString = json['format']['duration'];

    log("durationString final : $durationString");

    if (double.parse(durationString) > 5) {
      log("duration greater normal than 5s");
      await FFmpegKit.execute(
          "-y -i ${vidFilePath} -to 00:00:05 -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}");
      log("thumbnail file new more == ${File(outputPath).path}");
      return File(outputPath);
    } else {
      log("duration less than 5s");
      final double duration = double.parse(durationString) * 0.5;
      log("duration i normal $duration");
      await FFmpegKit.execute(
          "-y -i ${vidFilePath} -to ${formatTime(duration.toInt())} -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}");
      log("thumbnail file new less == ${File(outputPath).path}");
      return File(outputPath);
    }
  }

  Future<File> thumbnailCreatorStatic({required String vidFilePath}) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/thumbnail.png";

    final value = await FFprobeKit.execute(
        "-i ${vidFilePath} -show_entries format=duration -v quiet -of json");

    log("value == ${value}");

    final String? mapOutput = await value.getOutput();

    log("Map output == ${mapOutput}");

    final Map<String, dynamic> json = jsonDecode(mapOutput!);

    String durationString = json['format']['duration'];

    log("durationString final : $durationString");

    await FFmpegKit.execute(
        "-y -i ${vidFilePath} -vf scale=-2:480 -preset ultrafast -vframes 1 ${outputPath}");
    log("thumbnail file new less == ${File(outputPath).path}");
    return File(outputPath);

    // if (double.parse(durationString) > 5) {
    //   log("duration greater normal than 5s");
    //   await FFmpegKit.execute(
    //       "-y -i ${vidFilePath} -to 00:00:05 -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}");
    //   log("thumbnail file new more == ${File(outputPath).path}");
    //   return File(outputPath);
    // } else {
    //   log("duration less than 5s");
    //   final double duration = double.parse(durationString) * 0.5;
    //   log("duration i normal $duration");
    //   await FFmpegKit.execute(
    //       "-y -i ${vidFilePath} -to ${formatTime(duration.toInt())} -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}");
    //   log("thumbnail file new less == ${File(outputPath).path}");
    //   return File(outputPath);
    // }
  }

  Future<File> bgMaterialThumbnailCreator({required String vidFilePath}) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/bgThumbnail.gif";

    await FFmpegKit.execute(
            "-y -i ${vidFilePath} -to 00:00:02 -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}")
        .then((value) {
      bgThumbnailFile = File(outputPath);
      notifyListeners();
    });
    log("done bg gif");

    return bgThumbnailFile;
  }

  Future<File> imageToFile({required String path_imageName}) async {
    var bytes = await rootBundle.load('$path_imageName');
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/bg.png');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }

  Future<File> arViewOnlyVideoCreator({
    required String videoFileUrl,
    required String alphaFileUrl,
    required Duration duration,
    required int audioFlagVal,
  }) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputPath = "${rawDocumentPath}/arViewOnly.mp4";

    // https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1658641193078videoFile.mp4

    log("loading bg.png");

    final String f = 'assets/arViewer/bg.png';

    await imageToFile(path_imageName: "assets/arViewer/bg.png")
        .then((bgFile) async {
      log("bg file created");
      log("Running command");

      final String commandToRunNoAudio =
          "-v error -y -loop 1 -i ${bgFile.path} -i ${videoFileUrl} -i ${alphaFileUrl} -t ${duration.toString()} -filter_complex \"[2][1]scale2ref[mask][main];[main][mask]alphamerge[vid1];[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];[vid1]scale=1080.0:1920.0:force_original_aspect_ratio=decrease[1ol_vid];[bg_vid][1ol_vid]overlay=x=(W-w)-0.0:y=(H-h)-0.0[1out]\" -map ''[1out]'' -crf 30 -preset ultrafast $outputPath";

      final String commandToRun =
          "-v error -y -loop 1 -i ${bgFile.path} -i ${videoFileUrl} -i ${alphaFileUrl} -t ${duration.toString()} -filter_complex \"[2][1]scale2ref[mask][main];[main][mask]alphamerge[vid1];[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];[vid1]scale=1080.0:1920.0:force_original_aspect_ratio=decrease[1ol_vid];[bg_vid][1ol_vid]overlay=x=(W-w)-0.0:y=(H-h)-0.0[1out];[1:a]volume=1.0[a1]\" -map ''[1out]'' -map ''[a1]'' -crf 30 -preset ultrafast $outputPath";

      log("command == $commandToRun");

      await FFmpegKit.execute(
              audioFlagVal == 1 ? commandToRun : commandToRunNoAudio)
          .then((value) {
        outputFile = File(outputPath);
        notifyListeners();
      });
    });

    log("done");

    return outputFile;
  }
}
