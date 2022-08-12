import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/MyCollectionHome.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/InitVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/initArVideoEditorScreen.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/debugClass.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class VideoCreationOptionsScreen extends StatelessWidget {
  VideoCreationOptionsScreen({Key? key}) : super(key: key);
  ConstantColors constantColors = ConstantColors();

  final ImagePicker _picker = ImagePicker();

  Future<int> audioCheck({required String videoUrl}) async {
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          ArVideoCreation().setArAudioFlagGeneral(0);
          return 0;
        } else {
          ArVideoCreation().setArAudioFlagGeneral(1);
          return 1;
        }
      });
    });
  }

  _pickVideo({required BuildContext context}) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      final int audioFlag = await audioCheck(videoUrl: file.path);

      switch (audioFlag) {
        case 1:
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      InitVideoEditorScreen(file: File(file.path))));
          break;
        default:
          CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            title: "Video contains no audio",
            text:
                "at the moment, GD can only work on video's that have background audio. Please select a video that has audio to it.",
          );
      }
      // ignore: unawaited_futures

    }
  }

  Future<File?> _pickArVideo(
      {required BuildContext context, required ImageSource source}) async {
    final XFile? file = await _picker.pickVideo(
      source: source,
    );
    if (file != null) {
      return File(file.path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("debug").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("Error, please contact developer"),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final DebugClass debugVal = DebugClass.fromMap(
                snapshot.data!.docs[0].data() as Map<String, dynamic>);
            return Stack(
              children: [
                Container(
                  height: size.height,
                  width: size.width,
                  child: bodyColor(),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VideoOptions(
                        onTap: () {
                          debugVal.debug == false
                              ? _pickVideo(context: context)
                              : Provider.of<Authentication>(context,
                                              listen: false)
                                          .getUserId ==
                                      "ASe20Gw0hUeu0vnh69ofIvHC5Ls1"
                                  ? _pickVideo(context: context)
                                  : CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.info,
                                      text:
                                          "We're currently running tests, please try again later!",
                                      title: "Apologizes!",
                                    );
                        },
                        icon: Icons.video_settings_outlined,
                        text: "Create Video",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: VideoOptions(
                          onTap: () {
                            debugVal.debug == false
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            MyCollectionHome()))
                                : Provider.of<Authentication>(context,
                                                listen: false)
                                            .getUserId ==
                                        "ASe20Gw0hUeu0vnh69ofIvHC5Ls1"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                MyCollectionHome()))
                                    : CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.info,
                                        text:
                                            "We're currently running tests, please try again later!",
                                        title: "Apologizes!",
                                      );
                          },
                          icon: Icons.collections_sharp,
                          text: "My Materials",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: VideoOptions(
                          onTap: () {
                            debugVal.debug == false
                                ? selectVideoOptionsSheet(context)
                                : Provider.of<Authentication>(context,
                                                listen: false)
                                            .getUserId ==
                                        "ASe20Gw0hUeu0vnh69ofIvHC5Ls1"
                                    ? selectVideoOptionsSheet(context)
                                    : CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.info,
                                        text:
                                            "We're currently running tests, please try again later!",
                                        title: "Apologizes!",
                                      );
                          },
                          icon: Icons.video_file_outlined,
                          text: "AR Options",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  Future selectVideoOptionsSheet(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            bottom: true,
            child: Container(
              // ignore: sort_child_properties_last
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.navButton,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Video Option",
                          style: TextStyle(
                            color: constantColors.navButton,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () async {
                          final File? inputFile = await _pickArVideo(
                              context: context, source: ImageSource.gallery);

                          if (inputFile != null) {
                            // ignore: unawaited_futures

                            final int audioFlag =
                                await audioCheck(videoUrl: inputFile.path);

                            switch (audioFlag) {
                              case 1:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            ArVideoEditorScreen(
                                                file: inputFile)));
                                break;
                              case 0:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            ArVideoEditorScreen(
                                                file: inputFile)));
                                break;
                              default:
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.info,
                                  title: "Video processing error",
                                  text:
                                      "Please check video source and ensure there isnt any problems with the video",
                                );
                            }
                          } else {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Error",
                              text: "No video selected",
                            );
                          }
                        },
                      ),
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () async {
                          final File? inputFile = await _pickArVideo(
                              context: context, source: ImageSource.camera);

                          if (inputFile != null) {
                            // ignore: unawaited_futures

                            final int audioFlag =
                                await audioCheck(videoUrl: inputFile.path);

                            switch (audioFlag) {
                              case 1:
                                // ignore: unawaited_futures
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            ArVideoEditorScreen(
                                                file: inputFile)));
                                break;
                              default:
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.info,
                                  title: "Video contains no audio",
                                  text:
                                      "at the moment, GD can only work on video's that have background audio. Please select a video that has audio to it.",
                                );
                            }
                          } else {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Error",
                              text: "No video selected",
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
  }
}
