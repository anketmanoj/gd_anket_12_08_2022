import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/core/build_context.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateModel.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateProvider.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateTrimTool.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
          videoTemplate.audioFlag = 0;
          return 1;
        } else {
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

  Future<VideoTemplateModel?> _pickVideo(
      {required VideoTemplateModel videoTemplate,
      required BuildContext context}) async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (file != null) {
      videoTemplate.audioFlag = await audioCheck(
          videoTemplate: videoTemplate,
          file: File(file.path),
          context: context);
      Get.bottomSheet(
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
      ).then((value) {
        log("here now");
      });
      // final Directory appDocumentDir = await getApplicationDocumentsDirectory();
      // final String rawDocumentPath = appDocumentDir.path;
      // final String intermediateFileName =
      //     "${rawDocumentPath}/${Timestamp.now().millisecondsSinceEpoch}.ts";
      // final String commandForIntermediateFile =
      //     "-i ${file.path} -c copy -bsf:v h264_mp4toannexb -f mpegts ${intermediateFileName}";
      // videoTemplate.file = File(file.path);
      // videoTemplate.thumbnail =
      //     await generateCoverThumbnail(video: videoTemplate);

      // ignore: unawaited_futures
      VideoTemplateModel videoTemplateReturn =
          context.read<VideoTemplateProvider>().videoTemplate;

      return videoTemplateReturn;
    }
  }

  Future removeVideo({required VideoTemplateModel videoTemplate}) async {
    videoTemplate.file = null;
    videoTemplate.thumbnail = null;
    videoTemplate.audioFlag = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: constantColors.transperant,
        elevation: 0,
      ),
      body: Stack(
        children: [
          bodyColor(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 9,
                        child: Container(
                          child: Center(
                            child: Container(
                              height: 30.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/GDlogo.png')),
                              ),
                            ),
                          ),
                        ),
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
                        Container(
                          height: 80,
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
                                  onTap: videoTemplate[index].onClick == null
                                      ? () async {
                                          VideoTemplateModel? vidReturn =
                                              await _pickVideo(
                                                  videoTemplate:
                                                      videoTemplate[index],
                                                  context: context);

                                          if (vidReturn != null) {
                                            videoTemplate[index] = vidReturn;
                                            setState(() {});
                                          }
                                        }
                                      : () {},
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 80.w / videoTemplate.length,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image:
                                              videoTemplate[index].thumbnail !=
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
                                          right: 5,
                                          child: InkWell(
                                            onTap: () async {
                                              await removeVideo(
                                                  videoTemplate:
                                                      videoTemplate[index]);
                                              setState(() {});
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "X",
                                                style: TextStyle(
                                                  color:
                                                      constantColors.redColor,
                                                  shadows: outlinedText(
                                                    strokeColor: constantColors
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ),
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
                        SubmitButton(function: () {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
