import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/build_context.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateInitVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateModel.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateProvider.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateTrimTool.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/InitVideoEditorScreen.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTemplateFeatureScreen extends StatefulWidget {
  const VideoTemplateFeatureScreen();

  @override
  State<VideoTemplateFeatureScreen> createState() =>
      _VideoTemplateFeatureScreenState();
}

class _VideoTemplateFeatureScreenState
    extends State<VideoTemplateFeatureScreen> {
  List<VideoTemplateModel> videoTemplate = [];

  @override
  void initState() {
    randomSplit(numberOfRandNb: 4, predefinedNumber: 10).forEach((element) {
      videoTemplate.add(VideoTemplateModel(seconds: element));
    });
    super.initState();
  }

  final ImagePicker _picker = ImagePicker();

  Future<int> audioCheck(
      {required VideoTemplateModel videoTemplate,
      required File file,
      required BuildContext context}) async {
    context.read<ArVideoCreation>().setFromPexel(false);
    context.read<VideoEditorProvider>().setBackgroundVideoId(null);
    return FFprobeKit.execute(
            "-i ${file.path} -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          log("no audio");
          videoTemplate.audioFlag = 0;
          return 1;
        } else {
          log("has audio");
          videoTemplate.audioFlag = 1;
          return 1;
        }
      });
    });
  }

  Future<Uint8List> generateCoverThumbnail(
      {int timeMs = 0,
      int quality = 10,
      required VideoTemplateModel video}) async {
    final Uint8List? thumbData = await VideoThumbnail.thumbnailData(
      imageFormat: ImageFormat.PNG,
      video: video.file!.path,
      timeMs: timeMs,
      quality: quality,
    );

    return thumbData!;
  }

  Future _pickVideo(
      {required VideoTemplateModel videoTemplate,
      required BuildContext context}) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      await audioCheck(
          videoTemplate: videoTemplate,
          file: File(file.path),
          context: context);

      await Get.bottomSheet(
        Container(
          height: 90.h,
          width: 100.w,
          color: constantColors.whiteColor,
          child: VideoTemplateTrimTool(
            videoTemplate: videoTemplate,
            file: File(file.path),
            seconds: videoTemplate.seconds,
          ),
        ),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
      );

      videoTemplate.file =
          context.read<VideoTemplateProvider>().videoTemplate.file;
      videoTemplate.videoSelected =
          context.read<VideoTemplateProvider>().videoTemplate.videoSelected;

      videoTemplate.videoController =
          context.read<VideoTemplateProvider>().videoTemplate.videoController;

      videoTemplate.thumbnail =
          context.read<VideoTemplateProvider>().videoTemplate.thumbnail;
      videoTemplate.intermediateFile =
          context.read<VideoTemplateProvider>().videoTemplate.intermediateFile;
    }
  }

  Future<File> turnImageToVideo(
      {required VideoTemplateModel vtm, required File file}) async {
    final Directory appDocumentDir = await getApplicationDocumentsDirectory();
    final String rawDocumentPath = appDocumentDir.path;
    final String outputFile =
        "${rawDocumentPath}/${Timestamp.now().millisecondsSinceEpoch}.mp4";

    final String commandForFinalFile =
        " -r 0.01 -loop 1 -i ${file.path} -preset ultrafast -t ${vtm.seconds} -pix_fmt yuv420p -shortest $outputFile -y";

    log("command: $commandForFinalFile");

    log("starting");

    await FFmpegKit.execute(commandForFinalFile).then((value) async {
      // await value.getOutput().then((value) {
      //   log(value!);
      // });

      await value.getReturnCode().then((value) {
        if (value.toString() == '0') {
          log("finished ffmpeg");

          log("output file done");
        } else {
          log("Error running ffmpeg : $value");
          Get.back();
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              barrierDismissible: true);
        }
      });
    });

    final File outputFileValue = File(outputFile);

    return outputFileValue;
  }

  Future _pickImage(
      {required VideoTemplateModel videoTemplate,
      required BuildContext context}) async {
    final XFile? imgfile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imgfile != null) {
      File img2VidFile = await turnImageToVideo(
        vtm: videoTemplate,
        file: File(imgfile.path),
      );
      await audioCheck(
          videoTemplate: videoTemplate,
          file: File(img2VidFile.path),
          context: context);

      await Get.bottomSheet(
        Container(
          height: 90.h,
          width: 100.w,
          color: constantColors.whiteColor,
          child: VideoTemplateTrimTool(
            videoTemplate: videoTemplate,
            file: File(img2VidFile.path),
            seconds: videoTemplate.seconds,
          ),
        ),
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: true,
      );

      videoTemplate.file =
          context.read<VideoTemplateProvider>().videoTemplate.file;
      videoTemplate.videoSelected =
          context.read<VideoTemplateProvider>().videoTemplate.videoSelected;

      videoTemplate.videoController =
          context.read<VideoTemplateProvider>().videoTemplate.videoController;

      videoTemplate.thumbnail =
          context.read<VideoTemplateProvider>().videoTemplate.thumbnail;
      videoTemplate.intermediateFile =
          context.read<VideoTemplateProvider>().videoTemplate.intermediateFile;
    }
  }

  Future removeVideo({required VideoTemplateModel videoTemplate}) async {
    videoTemplate.file = null;
    videoTemplate.thumbnail = null;
    videoTemplate.audioFlag = null;
    videoTemplate.intermediateFile = null;
    context
        .read<VideoTemplateProvider>()
        .removeFromVideoControllersList(videoTemplate.videoController!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<VideoTemplateProvider>().resetAllParams();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        backgroundColor: constantColors.transperant,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Stack(
          children: [
            bodyColor(),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 12.h, 10, 10),
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Flexible(
                          flex: 9,
                          child: Consumer<VideoTemplateProvider>(
                              builder: (context, videoTemplateProvider, _) {
                            return videoTemplateProvider
                                        .getVideoTemplateSelected ==
                                    null
                                ? Container(
                                    child: Center(
                                      child: Container(
                                        height: 30.h,
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/GDlogo.png')),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: AspectRatio(
                                      aspectRatio: 9 / 16,
                                      child: VideoPlayer(videoTemplateProvider
                                          .getVideoTemplateSelected!
                                          .videoController!),
                                    ),
                                  );
                          }),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  "Use Template",
                                  style: TextStyle(
                                    color: constantColors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Replace the clips with your own!",
                                  style: TextStyle(
                                    color: constantColors.greyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: constantColors.greyColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Consumer<VideoTemplateProvider>(
                              builder: (context, vtp, _) {
                            return IconButton(
                                onPressed: vtp.isPlayingVideo == false
                                    ? () {
                                        log("play controllers in sequences");
                                        vtp.playVideo(
                                            videoTemplateList: videoTemplate
                                                .where((element) =>
                                                    element.file != null)
                                                .toList());
                                      }
                                    : () {
                                        log("pause controllers in sequences");
                                        vtp.pauseVideo();
                                      },
                                icon: Icon(vtp.isPlayingVideo == false
                                    ? Icons.play_arrow
                                    : Icons.pause));
                          }),
                          Container(
                            height: 12.h,
                            width: 100.w,
                            alignment: Alignment.center,
                            child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                height: 10,
                              ),
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: videoTemplate.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: InkWell(
                                    onTap: videoTemplate[index].file != null
                                        ? () {
                                            context
                                                .read<VideoTemplateProvider>()
                                                .selectVideoTemplate(
                                                    videoVal:
                                                        videoTemplate[index]);
                                          }
                                        : () async {
                                            if (index == 0) {
                                              log("index == $index");
                                              await _pickImage(
                                                  videoTemplate:
                                                      videoTemplate[index],
                                                  context: context);

                                              setState(() {});
                                            } else if (index != 0) {
                                              if (videoTemplate[index - 1]
                                                      .intermediateFile !=
                                                  null) {
                                                log("index == $index");
                                                await _pickImage(
                                                    videoTemplate:
                                                        videoTemplate[index],
                                                    context: context);

                                                setState(() {});
                                              } else {
                                                unawaited(Get.dialog(
                                                  SimpleDialog(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          "Please select an Image / Video for the previous slot!",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                              }
                                            }
                                          },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 80.w / videoTemplate.length,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: videoTemplate[index]
                                                        .thumbnail !=
                                                    null
                                                ? DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: MemoryImage(
                                                        videoTemplate[index]
                                                            .thumbnail!))
                                                : null,
                                            border: Border.all(
                                              color: constantColors.bioBg,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${videoTemplate[index].seconds}s",
                                              style: TextStyle(
                                                color: constantColors.black,
                                                shadows: outlinedText(
                                                  strokeColor:
                                                      constantColors.whiteColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              videoTemplate[index].file != null,
                                          child: Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              onPressed: () async {
                                                if (index == 0) {
                                                  log("index == $index");
                                                  await _pickVideo(
                                                      videoTemplate:
                                                          videoTemplate[index],
                                                      context: context);

                                                  setState(() {});
                                                } else if (index != 0) {
                                                  if (videoTemplate[index - 1]
                                                          .intermediateFile !=
                                                      null) {
                                                    log("index == $index");
                                                    await _pickVideo(
                                                        videoTemplate:
                                                            videoTemplate[
                                                                index],
                                                        context: context);

                                                    setState(() {});
                                                  } else {
                                                    log("Error");
                                                  }
                                                }
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color:
                                                    constantColors.whiteColor,
                                                shadows: [
                                                  Shadow(
                                                    color: constantColors.black,
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SubmitButton(
                              text: "Combine Clips",
                              function: videoTemplate
                                      .where((element) => element.file != null)
                                      .toList()
                                      .isNotEmpty
                                  ? () async {
                                      log("message");
                                      CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.loading,
                                          barrierDismissible: false);
                                      final Directory appDocumentDir =
                                          await getApplicationDocumentsDirectory();
                                      final String rawDocumentPath =
                                          appDocumentDir.path;
                                      final String outputFile =
                                          "${rawDocumentPath}/${Timestamp.now().millisecondsSinceEpoch}.mp4";

                                      List<String> inputString = [];
                                      List<String> streamsBreakdown = [];

                                      for (var element in videoTemplate) {
                                        if (element.intermediateFile != null) {
                                          int indexOfElement =
                                              videoTemplate.indexOf(element);
                                          log(indexOfElement.toString());
                                          inputString
                                              .add("-i ${element.file!.path}");

                                          streamsBreakdown.add(
                                              "[$indexOfElement:v:0][$indexOfElement:a:0]");
                                        }
                                      }

                                      final String commandForFinalFile =
                                          "${inputString.join(" ")} -filter_complex \"${streamsBreakdown.join()}concat=n=${videoTemplate.where((element) => element.file != null).toList().length}:v=1:a=1[outv][outa]\" -map ''[outv]'' -map ''[outa]'' -y -r 30/1 -crf 30 -preset faster  $outputFile";

                                      log("command: $commandForFinalFile");

                                      log("starting");

                                      await FFmpegKit.execute(
                                              commandForFinalFile)
                                          .then((value) async {
                                        // await value.getOutput().then((value) {
                                        //   log(value!);
                                        // });

                                        await value
                                            .getReturnCode()
                                            .then((value) {
                                          if (value.toString() == '0') {
                                            log("finished ffmpeg");

                                            final File outputFileValue =
                                                File(outputFile);
                                            log("output file done");

                                            context
                                                .read<VideoEditorProvider>()
                                                .setBackgroundVideoFile(
                                                    outputFileValue);
                                            log("setBackgroundVideoFile done");

                                            context
                                                .read<VideoEditorProvider>()
                                                .setBackgroundVideoController();
                                            log("setBackgroundVideoController done");
                                            Get.back();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        VideoTemplateInitVideoEditorScreen()));
                                          } else {
                                            log("Error running ffmpeg : $value");
                                            Get.back();
                                            CoolAlert.show(
                                                context: context,
                                                type: CoolAlertType.error,
                                                barrierDismissible: true);
                                          }
                                        });
                                      });
                                    }
                                  : () {
                                      unawaited(Get.dialog(
                                        SimpleDialog(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "No clips selected to combine!",
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ));
                                    }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
