import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/MyCollectionHome.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/RVMServerResponse.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ArVideoCreation extends ChangeNotifier {
  File? _gifFile;
  File? _audioCompFile;
  String? _inputFileUrl;
  RvmResponse? _rvmResponse;
  int? _audioFlag;
  int? arAudioFlagGeneral;

  File? get getGifFile => _gifFile;
  File? get getAudioCompFile => _audioCompFile;
  String? get getInputFileUrl => _inputFileUrl;
  RvmResponse? get getRvmResponse => _rvmResponse;
  int? get getAudioFlag => _audioFlag;
  int? get getArAudioFlagGeneral => arAudioFlagGeneral;

  final ConstantColors constantColors = ConstantColors();

  void setArAudioFlagGeneral(int value) {
    arAudioFlagGeneral = value;
    notifyListeners();

    log("ar audio now == ${arAudioFlagGeneral}");
  }

  Future<int> audioCheck({required String videoUrl}) async {
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          log("no audio == 0");
          setArAudioFlagGeneral(0);
          return 0;
        } else {
          log("Yes audio == 1");
          setArAudioFlagGeneral(1);
          return 1;
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> arVideoCreator({
    required BuildContext ctx,
    required File file,
    required Duration endDuration,
    required String fileName,
    required String inputFileUrl,
  }) async {
    if (await Permission.storage.request().isGranted) {
      final FirebaseOperations firebaseOperations =
          Provider.of<FirebaseOperations>(ctx, listen: false);
      final String ownerName = firebaseOperations.initUserName;
      final Authentication auth =
          Provider.of<Authentication>(ctx, listen: false);
      log("starting | $ownerName");

      final String endDurationString = formatDuration(endDuration);

      final Directory tmpDocument = await getApplicationDocumentsDirectory();
      final String rawDocument = tmpDocument.path;
      final String coverFolder = "${rawDocument}/";

      String commandToExceute =
          "-i ${file.path} -ss 00:00:00 -vframes 1 -y ${coverFolder}cover.jpg";
      log("starting ffmpeg");
      await FFmpegKit.execute(commandToExceute).then((value) {
        _gifFile = File("${coverFolder}cover.jpg");
        notifyListeners();
      });
      log("uploading cover image");
      final String? gifFileUrl = await firebaseOperations.uploadToAWS(
          pop: false,
          ctx: ctx,
          file: File(_gifFile!.path),
          startingFileName: fileName,
          endingFileName: "cover.jpg");

      log("cover image uploaded == $gifFileUrl");

      log("end Duration == ${endDuration.toString()}");
      log("End duration in String == ${endDurationString}");

      await firebaseOperations.createPendingArDoc(
          endDurationString: endDurationString,
          useruid: auth.getUserId,
          ownerName: ownerName,
          idVal: fileName,
          gifUrl: gifFileUrl!);

      log("created Pending Document");

      log("filename ${fileName} and inputfile done");

      final int audioFlag = await audioCheck(videoUrl: inputFileUrl);

      log("audioFlag == $audioFlag");

      notifyListeners();

      try {
        _rvmResponse = await firebaseOperations.postData2(
          endDuration: endDurationString,
          idVal: fileName,
          ownerName: ownerName,
          useruid: auth.getUserId,
          registrationId: firebaseOperations.fcmToken,
          fileStarting: fileName,
          audioFlag: audioFlag,
        );
        notifyListeners();
        log("bg removal done");
      } catch (e) {
        log("Error anket == ${e.toString()}");
      }

      log("Sent request to server, now waiting ");
      log("token == ${firebaseOperations.fcmToken}");
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
  }
}
