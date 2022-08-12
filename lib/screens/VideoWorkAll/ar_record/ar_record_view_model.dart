import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/constants/constant.dart';
import 'package:diamon_rose_app/enum/video_source.dart';

import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ArRecordViewModel extends GetxController
    with WidgetsBindingObserver, SingleGetTickerProviderMixin {
  List cameras = [];
  RxInt currentCameraId = 0.obs;
  CameraController? cameraController;
  RxBool isInit = false.obs;
  RxBool isRecordingVideo = false.obs;
  RxInt counter = 0.obs;
  BuildContext? context = Get.context;
  late AnimationController animationController;
  File? videoFile;
  RxString path = "".obs;
  ImagePicker imagePicker = ImagePicker();

  int _countdownTimer = 0;
  RxInt countdownCounter = 0.obs;

  int get countdownTimer => _countdownTimer;

  set countdownTimer(int value) {
    _countdownTimer = value;
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  void updateCameraId() {
    currentCameraId.value = currentCameraId.value == 0 ? 1 : 0;
    isInit.value = false;
    initCamera();
  }

  Future<void> initCamera() async {
    await imagePicker
        .pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 60))
        .then((value) async {
      if (value == null) {
        goBack();
      } else {
        await previewVideo(value);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraController != null) {
        // onNewCameraSelected(controller!.description);
      }
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = this.cameraController;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      isRecordingVideo.value = false;

      return cameraController.stopVideoRecording();
    } on CameraException {
      return null;
    }
  }

  Future<void> handleSelectedVideo(XFile? video) async {
    if (video == null) {
    } else if ((await video.length()) > MAX_UPLOAD_VIDEO_SIZE_IN_BYTE) {
      unawaited(_showViolateMaxVideoSizeDialog());
    } else {
      unawaited(previewVideo(video));
    }
  }

  Future<void> previewVideo(XFile video) async {
    videoFile = File(video.path);
    path.value = video.path;

    isInit.value = false;
    final parameter = <String, String>{
      'source': VideoSource.local.asString()!,
      'filePath': video.path,
    };
    await goTo(screen: ROUTER_REPLAY_VIDEO, parameter: parameter);
    unawaited(initCamera());
  }

  Future<void> _showViolateMaxVideoSizeDialog() async {
    return showDialog<void>(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("limitSizeTitle"),
          content: Text('limitSizeContent'
              ' ${MAX_UPLOAD_VIDEO_SIZE_IN_BYTE / 1000000}MB'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void back() {
    cameraController!.dispose();

    Get.back();
  }
}
