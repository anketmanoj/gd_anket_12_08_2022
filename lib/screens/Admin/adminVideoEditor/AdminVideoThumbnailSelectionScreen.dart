//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
// ignore_for_file: unawaited_futures

import 'dart:developer';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/AdminPreviewVideo.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/CropVideo/InitCropVideoScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/domain/bloc/controller.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart' hide Trans;
import 'package:helpers/helpers/transition.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AdminVideothumbnailSelector extends StatefulWidget {
  const AdminVideothumbnailSelector({
    Key? key,
    required this.arList,
  }) : super(key: key);

  final List<ARList> arList;

  @override
  State<AdminVideothumbnailSelector> createState() =>
      _AdminVideothumbnailSelectorState();
}

class _AdminVideothumbnailSelectorState
    extends State<AdminVideothumbnailSelector> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;
  late File bgMaterialThumnailFile;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller =
        context.read<VideoEditorProvider>().getAfterEditorVideoController;
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CropScreen(controller: _controller)));

  Future<void> _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      // preset: VideoExportPreset.medium,
      onProgress: (stats, value) => _exportingProgress.value = value,
      onCompleted: (videoFileNew, endDuration) async {
        _isExporting.value = false;
        if (!mounted) return;
        if (videoFileNew != null) {
          // context.read<VideoEditorProvider>().setFinalVideoFile(videoFileNew);

          Navigator.push(
              context,
              PageTransition(
                  child: AdminPreviewVideoScreen(
                    bgMaterialThumnailFile: context
                        .read<VideoEditorProvider>()
                        .getBgMaterialThumnailFile,
                    bgFile: context
                        .read<VideoEditorProvider>()
                        .getBackgroundVideoFile,
                    videoFile: File(videoFileNew.path),
                    arList: widget.arList,
                  ),
                  type: PageTransitionType.fade));
        }
      },
    );
  }

  Future<void> _exportCover() async {
    _isExporting.value = true;
    await _controller.extractCoverImage(
      onCompleted: (cover) async {
        if (!mounted) return;
        context.read<VideoEditorProvider>().setCoverImage(cover);
        log(context.read<VideoEditorProvider>().getCoverImage.path);
        // await _controller.exportVideo(
        //   // preset: VideoExportPreset.medium,
        //   onProgress: (stats, value) => _exportingProgress.value = value,
        //   onCompleted: (videoFileNew, endDuration) async {
        //     _isExporting.value = false;
        //     if (!mounted) return;
        //     if (videoFileNew != null) {
        //       _controller.video.dispose();
        //       context
        //           .read<VideoEditorProvider>()
        //           .setFinalVideoFile(videoFileNew);

        //       Navigator.pushReplacement(
        //           context,
        //           PageTransition(
        //               child: AdminPreviewVideoScreen(
        //                 bgMaterialThumnailFile: context
        //                     .read<VideoEditorProvider>()
        //                     .getBgMaterialThumnailFile,
        //                 bgFile: context
        //                     .read<VideoEditorProvider>()
        //                     .getBackgroundVideoFile,
        //                 thumbnailFile:
        //                     context.read<VideoEditorProvider>().getCoverGif,
        //                 videoFile: File(videoFileNew.path),
        //                 arList: widget.arList,
        //               ),
        //               type: PageTransitionType.fade));
        //     }
        //   },
        // );

        // ignore: unawaited_futures

        // showDialog(
        //   context: context,
        //   builder: (_) => Padding(
        //     padding: const EdgeInsets.all(30),
        //     child: Center(child: Image.memory(cover.readAsBytesSync())),
        //   ),
        // );

        // setState(() => _exported = true);
        // Future.delayed(const Duration(seconds: 2),
        //     () => setState(() => _exported = false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: LocaleKeys.finaltouches.tr(),
        context: context,
        leadingWidget: IconButton(
          onPressed: () async {
            log("clicked");

            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      backgroundColor: constantColors.navButton,
      body: _controller.initialized
          ? SafeArea(
              child: Stack(children: [
              Column(children: [
                _topNavBar(),
                Expanded(
                    child: DefaultTabController(
                        length: 2,
                        child: Column(children: [
                          Expanded(
                              child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Stack(alignment: Alignment.center, children: [
                                CropGridViewer(
                                  controller: _controller,
                                  showGrid: false,
                                ),
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) => OpacityTransition(
                                    visible: !_controller.isPlaying,
                                    child: GestureDetector(
                                      onTap: _controller.video.play,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              CoverViewer(controller: _controller)
                            ],
                          )),
                          Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(children: [
                                TabBar(
                                  indicatorColor: Colors.white,
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.content_cut)),
                                          Text(LocaleKeys.trim.tr())
                                        ]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.video_label)),
                                          Text('Cover')
                                        ]),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: _trimSlider()),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ],
                                  ),
                                )
                              ])),
                          _customSnackBar(),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, __) => OpacityTransition(
                              visible: export,
                              child: AlertDialog(
                                backgroundColor: Colors.white,
                                title: ValueListenableBuilder(
                                  valueListenable: _exportingProgress,
                                  builder: (_, double value, __) => Text(
                                    "Exporting video ${(value * 100).ceil()}%",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ])))
              ])
            ]))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(
                  Icons.rotate_left,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(
                  Icons.rotate_right,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                  valueListenable: _isExporting,
                  builder: (context, exporting, _) {
                    return AbsorbPointer(
                      absorbing: exporting,
                      child: IconButton(
                        onPressed: () async {
                          _controller.video.pause();
                          try {
                            await _exportCover().then((value) {
                              log("done creating cover, now export video");
                            });

                            Future.delayed(Duration(seconds: 2), () async {
                              await _exportVideo();
                            });
                          } catch (e) {
                            _isExporting.value = false;
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.info,
                                title: "Issue Detected",
                                text: "Error: ${e.toString()}");
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_forward_outlined,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  const SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            controller: _controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
                controller: _controller,
                margin: const EdgeInsets.only(top: 10))),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: height / 4),
        child: CoverSelection(
          controller: _controller,
          height: height,
          quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
