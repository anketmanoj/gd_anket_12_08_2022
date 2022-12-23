import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/MyCollectionHome.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/RVMServerResponse.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/permissionsService.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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
  bool _fromPexel = false;

  File? get getGifFile => _gifFile;
  File? get getAudioCompFile => _audioCompFile;
  String? get getInputFileUrl => _inputFileUrl;
  RvmResponse? get getRvmResponse => _rvmResponse;
  int? get getAudioFlag => _audioFlag;
  int? get getArAudioFlagGeneral => arAudioFlagGeneral;
  bool get getFromPexel => _fromPexel;

  final ConstantColors constantColors = ConstantColors();

  void setFromPexel(bool value) {
    _fromPexel = value;
    notifyListeners();
  }

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
    await ctx.read<PermissionsProvider>().askForPermissions();

    final bool allAccept = ctx.read<PermissionsProvider>().getPermissionsGive;

    if (allAccept) {
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
    } else {
      await Get.dialog(
        SimpleDialog(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Device permissions required",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Permissions are required to store the videos on your device so you can share the videos on various other social media platforms!",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SubmitButton(
                    text: "Open Settings",
                    function: () async {
                      await openAppSettings();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> arVideoCreatorAdmin({
    required BuildContext ctx,
    required File file,
    required Duration endDuration,
    required String fileName,
    required String inputFileUrl,
    required String ownerName,
    required String useruid,
    required String userToken,
  }) async {
    await ctx.read<PermissionsProvider>().askForPermissions();

    final bool allAccept = ctx.read<PermissionsProvider>().getPermissionsGive;

    if (allAccept) {
      log("starting | $ownerName");
      final FirebaseOperations firebaseOperationsAdmin =
          Provider.of<FirebaseOperations>(ctx, listen: false);

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
      final String? gifFileUrl = await firebaseOperationsAdmin.uploadToAWS(
          pop: false,
          ctx: ctx,
          file: File(_gifFile!.path),
          startingFileName: fileName,
          endingFileName: "cover.jpg");

      log("cover image uploaded == $gifFileUrl");

      log("end Duration == ${endDuration.toString()}");
      log("End duration in String == ${endDurationString}");

      await firebaseOperationsAdmin.createPendingArDoc(
          endDurationString: endDurationString,
          useruid: useruid,
          ownerName: ownerName,
          idVal: fileName,
          gifUrl: gifFileUrl!);

      log("created Pending Document");

      log("filename ${fileName} and inputfile done");

      final int audioFlag = await audioCheck(videoUrl: inputFileUrl);

      log("audioFlag == $audioFlag");

      notifyListeners();

      try {
        _rvmResponse = await firebaseOperationsAdmin.postData2(
          endDuration: endDurationString,
          idVal: fileName,
          ownerName: ownerName,
          useruid: useruid,
          registrationId: userToken,
          fileStarting: fileName,
          audioFlag: audioFlag,
        );
        notifyListeners();
        log("bg removal done");
      } catch (e) {
        log("Error anket == ${e.toString()}");
      }

      log("Sent request to server, now waiting ");
      log("token == ${userToken}");
    } else {
      await Get.dialog(
        SimpleDialog(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Device permissions required",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Permissions are required to store the videos on your device so you can share the videos on various other social media platforms!",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SubmitButton(
                    text: "Open Settings",
                    function: () async {
                      await openAppSettings();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
