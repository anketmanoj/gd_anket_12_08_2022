import 'dart:async';

import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/constants/constant.dart';
import 'package:diamon_rose_app/enum/video_source.dart';
import 'package:diamon_rose_app/share/localizations/l10n/localy.dart';
import 'package:diamon_rose_app/widgets/utils.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SelectModelPresenter extends GetxController {
  BuildContext? context = Get.context;

  Future<void> openVideoGallery() async {
    ImageCache().clear();
    final ImagePicker _picker = ImagePicker();
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

    unawaited(handleSelectedVideo(file));
  }

  Future<void> handleSelectedVideo(XFile? video) async {
    if (video == null) {
    } else if ((await video.length()) > MAX_UPLOAD_VIDEO_SIZE_IN_BYTE) {
      unawaited(_showViolateMaxVideoSizeDialog());
    } else {
      unawaited(previewVideo(video));
    }
  }

  Future<void> _showViolateMaxVideoSizeDialog() async {
    return showDialog<void>(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("limitSizeTitle"),
          content: Text(
              'limitSizeContent ${MAX_UPLOAD_VIDEO_SIZE_IN_BYTE / 1000000}MB'),
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

  Future<void> previewVideo(XFile video) async {
    final parameter = <String, String>{
      'source': VideoSource.local.asString()!,
      'filePath': video.path,
    };
    await goTo(screen: ROUTER_REPLAY_VIDEO, parameter: parameter);
  }
}
