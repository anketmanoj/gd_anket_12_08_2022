//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
// ignore_for_file: unawaited_futures

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateModel.dart';
import 'package:diamon_rose_app/screens/VideoTemplateFeature/videoTemplateProvider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/CreateVideoScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/CropVideo/InitCropVideoScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:helpers/helpers.dart'
    show OpacityTransition, SwipeTransition, AnimatedInteractiveViewer;
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTemplateTrimTool extends StatefulWidget {
  const VideoTemplateTrimTool(
      {Key? key,
      required this.file,
      required this.seconds,
      required this.videoTemplate})
      : super(key: key);
  final VideoTemplateModel videoTemplate;
  final File file;
  final int seconds;

  @override
  _VideoTemplateTrimToolState createState() => _VideoTemplateTrimToolState();
}

class _VideoTemplateTrimToolState extends State<VideoTemplateTrimTool> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(
      widget.file,
      maxDuration: Duration(seconds: widget.seconds),
      trimStyle: TrimSliderStyle(),
    )..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
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

  void _openCropScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CropScreen(controller: _controller)));

  void _exportVideo() async {
    log("now");
    _exportingProgress.value = 0;
    _isExporting.value = true;
    final int? audioCheckVal = widget.videoTemplate.audioFlag;
    log("audio check val == $audioCheckVal");
    // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
    await _controller.exportVideo(
      playbackSpeed: _controller.video.value.playbackSpeed,
      audioCheckVal: audioCheckVal!,
      // preset: VideoExportPreset.medium,
      onProgress: (stats, value) => _exportingProgress.value = value,
      onCompleted: (file, endDuration) async {
        _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          await _controller.extractCover(
            onCompleted: (cover) async {
              if (!mounted) return;

              if (cover != null) {
                _exportText = "Cover exported! ${cover.path}";

                final VideoPlayerController _videoController =
                    VideoPlayerController.file(file);

                _videoController.initialize().then((value) async {
                  setState(() {});

                  _videoController.setLooping(true);
                  await showDialog(
                    context: context,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(30),
                      child: Container(
                        color: Colors.black,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    LocaleKeys.preview.tr(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _videoController.value.isPlaying
                                        ? _videoController.pause()
                                        : _videoController.play();
                                  },
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController.value.aspectRatio,
                                    child: VideoPlayer(_videoController),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancel",
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      VideoTemplateModel videoTemplateModel =
                                          VideoTemplateModel(
                                        seconds: endDuration!.inSeconds,
                                        file: file,
                                        audioFlag: 1,
                                        intermediateFile: file,
                                        thumbnail: cover.readAsBytesSync(),
                                        videoSelected: true,
                                      );
                                      log("hete");
                                      context
                                          .read<VideoTemplateProvider>()
                                          .workOnVideoTemplate(
                                              videoVal: videoTemplateModel);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      LocaleKeys.next.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  await _videoController.pause();
                  _videoController.dispose();
                });
              } else {
                _exportText = "Error on cover exportation :(";
              }
            },
          );
        } else {
          _exportText = "Error on export video :(";
        }
      },
    );
  }

  void _exportCover() async {
    setState(() => _exported = false);
    await _controller.extractCover(
      onCompleted: (cover) {
        if (!mounted) return;

        if (cover != null) {
          _exportText = "Cover exported! ${cover.path}";
          showDialog(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(30),
              child: Center(child: Image.memory(cover.readAsBytesSync())),
            ),
          );
        } else {
          _exportText = "Error on cover exportation :(";
        }

        setState(() => _exported = true);
        Future.delayed(const Duration(seconds: 2),
            () => setState(() => _exported = false));
      },
    );
  }

  ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.navButton.withOpacity(1),
      body: _controller.initialized
          ? SafeArea(
              child: Stack(children: [
              Column(children: [
                _topNavBar(),
                Expanded(
                    child: DefaultTabController(
                        length: 1,
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
                              // CoverViewer(controller: _controller)
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
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: _trimSlider()),
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
                                    "${LocaleKeys.trimmingvideo.tr()} ${(value * 100).ceil()}%",
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
              child: _ControlsOverlay(controller: _controller.video),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                  valueListenable: _isExporting,
                  builder: (context, exporting, _) {
                    return AbsorbPointer(
                      absorbing: exporting,
                      child: IconButton(
                        onPressed: () {
                          try {
                            _exportVideo();
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
              Text(
                formatter(
                  Duration(
                    seconds: pos.toInt(),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
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
            child: TrimTimeline(
                controller: _controller,
                margin: const EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
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

class _ControlsOverlay extends StatelessWidget {
  _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
  ];

  final VideoPlayerController controller;

  ValueNotifier<double> playbackSpeed = ValueNotifier<double>(1.0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PopupMenuButton<double>(
        initialValue: controller.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: (double speed) {
          controller.setPlaybackSpeed(speed);
          playbackSpeed.value = speed;
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<double>>[
            for (final double speed in _examplePlaybackRates)
              PopupMenuItem<double>(
                value: speed,
                child: Text('${speed}x'),
              )
          ];
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            // Using less vertical padding as the text is also longer
            // horizontally, so it feels like it would need more spacing
            // horizontally (matching the aspect ratio of the video).
            vertical: 12,
            horizontal: 16,
          ),
          child: ValueListenableBuilder<double>(
              valueListenable: playbackSpeed,
              builder: (context, playbackVal, _) {
                return Text(
                  '${playbackVal}x',
                  style: TextStyle(
                    color: constantColors.whiteColor,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
