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
import 'package:ffmpeg_kit_flutter_https_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/ffprobe_kit.dart';
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

  Future<void> arVideoCreator(
      {required BuildContext ctx,
      required File file,
      required Duration endDuration}) async {
    if (await Permission.storage.request().isGranted) {
      final FirebaseOperations firebaseOperations =
          Provider.of<FirebaseOperations>(ctx, listen: false);

      log("end Duration == ${endDuration.toString()}");

      final String ownerName = firebaseOperations.initUserName;
      final Authentication auth =
          Provider.of<Authentication>(ctx, listen: false);
      log("starting | $ownerName");

      Get.snackbar(
        'Uploading Video',
        'Your video is now being uploaded!',
        overlayColor: constantColors.navButton,
        colorText: constantColors.whiteColor,
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.elasticInOut,
        reverseAnimationCurve: Curves.easeOut,
      );

      final String fileName = "${Timestamp.now().millisecondsSinceEpoch}";
      _inputFileUrl = await firebaseOperations.uploadToAWS(
          pop: false,
          ctx: ctx,
          file: file,
          startingFileName: fileName,
          endingFileName: "videoFile.mp4");
      log("filename ${fileName} and inputfile done");

      final int audioFlag = await audioCheck(videoUrl: _inputFileUrl!);

      log("audioFlag == $audioFlag");

      notifyListeners();

      Get.snackbar(
        'Removing Background',
        'Removing the background from your video!',
        overlayColor: constantColors.navButton,
        colorText: constantColors.whiteColor,
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.elasticInOut,
        reverseAnimationCurve: Curves.easeOut,
      );

      try {
        _rvmResponse = await firebaseOperations.postData(
            fileStarting: fileName, audioFlag: audioFlag);
        notifyListeners();
        log("bg removal done");
      } catch (e) {
        log("Error anket == ${e.toString()}");
      }

      if (_rvmResponse != null) {
        // ignore: unawaited_futures
        Get.snackbar(
          'Final touches...',
          'Your AR is almost ready!',
          overlayColor: constantColors.navButton,
          colorText: constantColors.whiteColor,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.elasticInOut,
          reverseAnimationCurve: Curves.easeOut,
        );

        final String alphaUrl =
            "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/${fileName}_alpha.mp4";

        final String audioUrlFile = audioFlag == 1
            ? "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/${fileName}_audio.aac"
            : "No audio";

        final List<String> _imgSeq = [];

        log("number of pngs = ${_rvmResponse!.totalNumberPngs}");

        for (int i = 1; i <= _rvmResponse!.totalNumberPngs; i++) {
          _imgSeq.add(
              "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/${fileName}_ImgSeq$i.png");
        }

        final Directory tmpDocument = await getApplicationDocumentsDirectory();
        final String rawDocument = tmpDocument.path;
        final String gifFolder = "${rawDocument}/";

        String commandToExceute =
            "-i ${file.path} -i ${alphaUrl} -t 2 -filter_complex \"[1][0]scale2ref[mask][main];[main][mask]alphamerge,fps=20,scale=480:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" -y ${gifFolder}output.gif";
        log("starting ffmpeg");
        await FFmpegKit.execute(commandToExceute).then((value) {
          _gifFile = File("${gifFolder}output.gif");
          notifyListeners();
        });

        final String? gifUrl = await firebaseOperations.uploadToAWS(
            pop: false,
            file: File(_gifFile!.path),
            startingFileName: fileName,
            endingFileName: "output.gif",
            ctx: ctx);

        log("gif done");

        _audioFlag = 0;
        notifyListeners();

        await deleteFile(["${gifFolder}output.gif"]);

        Get.snackbar(
            'AR Successfully created!', 'Taking you to the AR Preview Settings',
            overlayColor: constantColors.navButton,
            colorText: constantColors.whiteColor,
            snackPosition: SnackPosition.TOP,
            forwardAnimationCurve: Curves.elasticInOut,
            reverseAnimationCurve: Curves.easeOut);

        // ignore: cascade_invocations, unawaited_futures
        Get.to(() => ArPreviewSetting(
              gifUrl: gifUrl!,
              ownerName: ownerName,
              audioFlag: audioFlag,
              alphaUrl: alphaUrl,
              audioUrl: audioUrlFile,
              imgSeqList: _imgSeq,
              arIdVal: fileName,
              inputUrl: _inputFileUrl!,
              userUid: auth.getUserId,
              endDuration: endDuration,
            ));

        // await firebaseOperations
        //     .addArToCollection(
        //   ownerName: ownerName,
        //   audioFlag: audioFlag,
        //   alphaUrl: alphaUrl,
        //   audioUrl: audioUrlFile,
        //   imgSeqList: _imgSeq,
        //   gifUrl: gifUrl!,
        //   idVal: fileName,
        //   mainUrl: _inputFileUrl!,
        //   useruid: auth.getUserId,
        // )
        //     .whenComplete(() async {

        //   log("sucess!");

        //   log("gif file deleted");
        // });
      }
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
  }
}
