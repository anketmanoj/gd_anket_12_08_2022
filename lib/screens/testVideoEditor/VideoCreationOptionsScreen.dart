import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/HelpScreen/tutorialVideos.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/MyCollectionHome.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/MyCollectionMiddleNav.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/InitVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/initArVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/userDraftVideos.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/debugClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class VideoCreationOptionsScreen extends StatelessWidget {
  VideoCreationOptionsScreen({Key? key}) : super(key: key);
  ConstantColors constantColors = ConstantColors();

  final ImagePicker _picker = ImagePicker();

  Future<int> audioCheck(
      {required String videoUrl, required BuildContext context}) async {
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(0);
          return 1;
        } else {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(1);
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
      final int audioFlag =
          await audioCheck(videoUrl: file.path, context: context);

      switch (audioFlag) {
        case 1:
          context
              .read<VideoEditorProvider>()
              .setBackgroundVideoFile(File(file.path));

          context.read<VideoEditorProvider>().setBackgroundVideoController();
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => InitVideoEditorScreen()));
          break;
        default:
          CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            title: LocaleKeys.videocontainsnoaudio.tr(),
            text: LocaleKeys.onlyVideoWithAudioSupported.tr(),
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
        body: Stack(
      children: [
        Container(
          height: size.height,
          width: size.width,
          child: bodyColor(),
        ),
        Positioned(
          top: 5.h,
          right: 5.w,
          child: TextButton.icon(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: TutorialVideoScreen(),
                        type: PageTransitionType.fade));
              },
              icon: Icon(Icons.info_outline_rounded),
              label: Text(LocaleKeys.tutorials.tr())),
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
                  createVideoOptionsSheet(context);
                },
                icon: Icons.video_settings_outlined,
                text: LocaleKeys.createVideo.tr(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: VideoOptions(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                MyCollectionMiddleNav()));
                  },
                  icon: Icons.collections_sharp,
                  text: LocaleKeys.myMaterials.tr(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: VideoOptions(
                  onTap: () {
                    selectVideoOptionsSheet(context);
                  },
                  icon: Icons.video_file_outlined,
                  text: LocaleKeys.arOptions.tr(),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
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
                      Text(LocaleKeys.selectVideoOption.tr(),
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
                          LocaleKeys.gallery.tr(),
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

                            final int audioFlag = await audioCheck(
                                videoUrl: inputFile.path, context: context);

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
                              text: LocaleKeys.novideoselected.tr(),
                            );
                          }
                        },
                      ),
                      MaterialButton(
                        color: constantColors.navButton,
                        child: Text(
                          LocaleKeys.camera.tr(),
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

                            final int audioFlag = await audioCheck(
                                videoUrl: inputFile.path, context: context);

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
                                  title: LocaleKeys.videocontainsnoaudio.tr(),
                                  text: LocaleKeys.onlyVideoWithAudioSupported
                                      .tr(),
                                );
                            }
                          } else {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Error",
                              text: LocaleKeys.novideoselected.tr(),
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

  Future createVideoOptionsSheet(BuildContext context) async {
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
                      Text(LocaleKeys.createVideoOption.tr(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            color: constantColors.navButton,
                            child: Text(
                              LocaleKeys.newVideo.tr(),
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              _pickVideo(context: context);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: MaterialButton(
                            color: constantColors.navButton,
                            child: Text(
                              LocaleKeys.drafts.tr(),
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  child: USerDraftVideoScreen(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
