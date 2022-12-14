import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/screens/GiphyTest/get_giphy_gifs.dart';
import 'package:diamon_rose_app/screens/GiphyTest/gigphy_get_anket.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/VideoCreationOptionsScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ViewerScreenModel.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart' hide Trans;
import 'package:diamon_rose_app/services/img_seq_animator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capture_event/screen_capture_event.dart';
import 'package:sizer/sizer.dart';
import 'package:spring_button/spring_button.dart';
import 'package:xl/xl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;

class ImageSeqAniScreen extends StatefulWidget {
  const ImageSeqAniScreen(
      {Key? key,
      required this.folderName,
      required this.fileName,
      required this.MyAR,
      this.arViewerScreen = false,
      this.videoFPS = 30})
      : super(key: key);

  final String folderName;
  final String fileName;
  final double videoFPS;

  final MyArCollection MyAR;
  final bool arViewerScreen;

  @override
  State<ImageSeqAniScreen> createState() => _ImageSeqAniScreenState();
}

class _ImageSeqAniScreenState extends State<ImageSeqAniScreen> {
  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  List<ARList> list = [];
  Size? screen;
  AudioPlayer? _player = AudioPlayer();
  CameraController? controller;
  GiphyGif? currentGif;
  // Giphy Client
  GiphyClient? client;
  // Random ID
  String randomId = "";
  String giphyApiKey = "0X2ffUW2nnfVcPUc2C7alPhfdrj2tA6M";
  bool allowParallax = false;

  ImageSequenceAnimatorState? get imageSequenceAnimator =>
      onlineImageSequenceAnimator;
  ImageSequenceAnimatorState? onlineImageSequenceAnimator;

  void onOnlineReadyToPlay(ImageSequenceAnimatorState _imageSequenceAnimator) {
    onlineImageSequenceAnimator = _imageSequenceAnimator;

    setState(() {});
  }

  void onOnlinePlaying(ImageSequenceAnimatorState _imageSequenceAnimator) {
    setState(() {});
  }

  final ScreenCaptureEvent screenListener = ScreenCaptureEvent();

  Future<File> getImage({required String url}) async {
    /// Get Image from server
    final dio.Response res = await dio.Dio().get<List<int>>(
      url,
      options: dio.Options(
        responseType: dio.ResponseType.bytes,
      ),
    );

    /// Get App local storage
    final Directory appDir = await getApplicationDocumentsDirectory();

    /// Generate Image Name
    final String imageName = url.split('/').last;
    final String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, timeNow + imageName));
    file.writeAsBytesSync(res.data as List<int>);

    return file;
  }

  @override
  void initState() {
    log("init Ar");
    log("myAr == ${widget.MyAR.imgSeq[4]}");
    screen = Size(400, 500);
    list.add(ARList(
      height: 400,
      rotation: 0,
      scale: 1,
      width: 400,
      xPosition: 0,
      yPosition: 0,
      pathsForVideoFrames: widget.MyAR.imgSeq,
      xOffset: 50,
      yOffset: 50,
    ));
    client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      client!.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });
    _init();

    log("usage is == ${widget.MyAR.usage}");

    log("added 1st to AR List ${widget.MyAR.imgSeq.length}");
    screenListener.addScreenRecordListener((recorded) {
      ///Recorded was your record status (bool)
      showScreenrecordWarningMsg();
    });

    screenListener.addScreenShotListener((filePath) {
      ///filePath only available for Android
      showScreenshotWarningMsg();
    });
    screenListener.watch();
    super.initState();

    if (widget.arViewerScreen) {
      controller = CameraController(
        cameras![0],
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller!.startImageStream(
          (CameraImage image) {},
        );

        setState(() {
          showCamera = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _player!.dispose();
    screenListener.dispose();
    if (widget.arViewerScreen) controller!.dispose();
    // imageSequenceAnimator!.stop();
    // imageSequenceAnimator!.dispose();
    log("disposed");

    super.dispose();
  }

  Future<void> _init() async {
    if (widget.MyAR.audioFlag == true) {
      try {
        await _player!.setUrl(widget.MyAR.audioFile);
        await _player!.pause();
      } catch (e) {
        log("Audio error == ${e.toString()}");
      }
    }
  }

  Color color1 = Colors.greenAccent;
  Color color2 = Colors.indigo;

  String onlineOfflineText = "Use Online";
  String loopText = "Start Loop";
  String boomerangText = "Start Boomerang";
  String backgroundText = "Show Camera Feed";
  bool showCamera = false;
  bool wasPlaying = false;

  Widget row(String text, Color color) {
    return Padding(
      padding: EdgeInsets.all(3.125),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ViewScreenModel> forMaterialView = [
      ViewScreenModel(
        iconData: Icons.play_arrow,
        function: () {
          // setState(() {
          imageSequenceAnimator!.play();
          if (widget.MyAR.audioFlag == true) _player!.play();
          // });
        },
      ),
      ViewScreenModel(
        iconData: Icons.pause,
        function: () {
          // setState(() {
          if (imageSequenceAnimator!.isPlaying) {
            if (widget.MyAR.audioFlag == true) _player!.pause();
            imageSequenceAnimator!.pause();
          }
          // });
        },
      ),
      ViewScreenModel(
        iconData: Icons.stop,
        function: () {
          imageSequenceAnimator!.stop();
          if (widget.MyAR.audioFlag == true) _player!.stop();
        },
      ),
    ];
    final List<ViewScreenModel> forArView = [
      ViewScreenModel(
        iconData: Icons.play_arrow,
        function: () {
          // setState(() {
          imageSequenceAnimator!.play();
          if (widget.MyAR.audioFlag == true) _player!.play();
          // });
        },
      ),
      ViewScreenModel(
        iconData: Icons.pause,
        function: () {
          // setState(() {
          if (imageSequenceAnimator!.isPlaying) {
            if (widget.MyAR.audioFlag == true) _player!.pause();
            imageSequenceAnimator!.pause();
          }
          // });
        },
      ),
      ViewScreenModel(
        iconData: Icons.stop,
        function: () {
          imageSequenceAnimator!.stop();
          if (widget.MyAR.audioFlag == true) _player!.stop();
        },
      ),
      ViewScreenModel(
        iconData: Icons.restart_alt,
        function: () async {
          if (widget.MyAR.audioFlag == true) {
            await _player!.seek(Duration.zero);
            await _player!.play();
          }
          imageSequenceAnimator!.restart();
        },
      ),
      ViewScreenModel(
        iconData: Icons.fast_rewind,
        function: () {
          imageSequenceAnimator!.rewind();
        },
      ),
      ViewScreenModel(
        iconData: Icons.loop,
        function: () async {
          switch (widget.MyAR.audioFlag) {
            case true:
              imageSequenceAnimator!.skip(0);

              setState(() {
                loopText = imageSequenceAnimator!.isLooping
                    ? "Start Loop"
                    : "Stop Loop";
                boomerangText = "Start Boomerang";
                imageSequenceAnimator!
                    .setIsLooping(!imageSequenceAnimator!.isLooping);
              });

              await _player!.seek(Duration.zero);
              await _player!.setLoopMode(
                  !imageSequenceAnimator!.isLooping == true
                      ? LoopMode.off
                      : LoopMode.all);
              await _player!.play();
              imageSequenceAnimator!.play();

              // Navigator.pop(context);

              break;
            case false:
              imageSequenceAnimator!.skip(0);

              setState(() {
                loopText = imageSequenceAnimator!.isLooping
                    ? "Start Loop"
                    : "Stop Loop";
                boomerangText = "Start Boomerang";
                imageSequenceAnimator!
                    .setIsLooping(!imageSequenceAnimator!.isLooping);
              });

              imageSequenceAnimator!.play();

              // Navigator.pop(context);

              break;
          }
        },
      ),
      ViewScreenModel(
        iconData: Icons.low_priority,
        function: () async {
          setState(() {
            loopText = "Start Loop";
            boomerangText = imageSequenceAnimator!.isBoomerang
                ? "Start Boomerang"
                : "Stop Boomerang";
            imageSequenceAnimator!
                .setIsBoomerang(!imageSequenceAnimator!.isBoomerang);
          });

          // Navigator.pop(context);
          Get.snackbar(
            'Boomerang is only applicable to video',
            "In Boomerang mode, no audio will be played. Only the video will be played in boomerang mode.",
            duration: Duration(seconds: 5),
            overlayColor: constantColors.navButton,
            colorText: constantColors.black,
            snackPosition: SnackPosition.TOP,
            forwardAnimationCurve: Curves.elasticInOut,
            reverseAnimationCurve: Curves.easeOut,
            backgroundColor: constantColors.navButton.withOpacity(0.6),
          );
        },
      ),
      // ViewScreenModel(
      //   image: "assets/images/parallaxIcon.png",
      //   iconData: Icons.abc,
      //   function: () async {
      //     allowParallax = !allowParallax;

      //     allowParallax == true
      //         ? Get.snackbar("Parallax Activated",
      //             "Parallax has been activated, the AR will tilt with your phone now!")
      //         : Get.snackbar(
      //             "Parallax Deactivated", "Parallax has been deactivated");
      //   },
      // ),
    ];

    return AnketGiphyGetWrapper(
        giphy_api_key: giphyApiKey,
        builder: (stream, giphyGetWrapper) {
          stream.listen((gif) async {
            // ! USe this link format https://i.giphy.com/media/${URL_PART}/giphy.gif
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                barrierDismissible: false,
                text: "Connecting Giphy ");

            final File gifFile = await getImage(
                url: "https://i.giphy.com/media/${gif.id}/giphy.gif");

            list.add(ARList(
              height: 200.0,
              width: 200.0,
              rotation: 0.0,
              scale: 1.0,
              xPosition: 0.2,
              yPosition: 0.2,
              gifFilePath: "https://i.giphy.com/media/${gif.id}/giphy.gif",
              xOffset: list.last.xOffset! + 50,
              yOffset: list.last.xOffset! + 50,
            ));
            Get.back();

            // setState(() {
            //   currentGif = gif;
            // });
          });
          return Scaffold(
            appBar: AppBar(
              backgroundColor: constantColors.navButton,
              actions: [
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      SimpleDialog(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              "${LocaleKeys.requiresStableConnection.tr()}\n\n${LocaleKeys.ensureStableConnection.tr()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: constantColors.navButton,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.info_outline),
                ),
                // IconButton(
                //   onPressed: () {
                //     giphyGetWrapper.getGif(
                //       '',
                //       context,
                //     );
                //   },
                //   icon: Icon(Icons.edit),
                // ),
              ],
              title:
                  Text(widget.arViewerScreen ? "Ar Viewer" : "Material Viewer"),
              leading: IconButton(
                onPressed: () async {
                  await DefaultCacheManager().emptyCache();

                  // imageSequenceAnimator!.dispose();
                  // _player!.dispose();
                  // controller!.dispose();
                  // super.dispose();
                  // log("disposed");
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
            ),
            body: SafeArea(
              bottom: Platform.isAndroid ? true : false,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        showCamera
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: CameraPreview(
                                  controller!,
                                ),
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Image.asset(
                                  "assets/arViewer/bg.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                        Stack(
                          children: list.map((value) {
                            if (value.gifFilePath == null) {
                              return GestureDetector(
                                onScaleStart: (details) {
                                  if (value == null) return;
                                  _initPos = details.focalPoint;
                                  _currentPos = Offset(
                                      value.xPosition!, value.yPosition!);
                                  _currentScale = value.scale;
                                  _currentRotation = value.rotation;
                                },
                                onScaleUpdate: (details) {
                                  if (value == null) return;
                                  final delta = details.focalPoint - _initPos!;
                                  final left = (delta.dx / screen!.width) +
                                      _currentPos!.dx;
                                  final top = (delta.dy / screen!.height) +
                                      _currentPos!.dy;

                                  setState(() {
                                    value.xPosition = Offset(left, top).dx;
                                    value.yPosition = Offset(left, top).dy;
                                    value.rotation =
                                        details.rotation + _currentRotation!;
                                    value.scale =
                                        details.scale * _currentScale!;
                                  });

                                  log("current rotation == ${_currentRotation! * math.pi / 180}");
                                },
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -value.xPosition! * screen!.width,
                                      bottom:
                                          -value.yPosition! * screen!.height,
                                      child: Transform.scale(
                                        scale: value.scale,
                                        child: Transform.rotate(
                                          angle: value.rotation!,
                                          child: Container(
                                            height: value.height,
                                            width: value.width,
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: Listener(
                                                onPointerDown: (details) {
                                                  // _initPos = details.position;
                                                  // _currentPos = Offset(
                                                  //     value.xPosition!, value.yPosition!);
                                                  // _currentScale = value.scale;
                                                  // _currentRotation = value.rotation;
                                                  // print(" _initPos = ${_initPos!.dx}");
                                                },
                                                onPointerUp: (details) {
                                                  _initPos = details.position;
                                                  _currentPos = Offset(
                                                      value.xPosition!,
                                                      value.yPosition!);
                                                  _currentScale = value.scale;
                                                  _currentRotation =
                                                      value.rotation;
                                                  // log("rotation == ${value.rotation! * 3.14 / 180}");
                                                },
                                                child: InkWell(
                                                  child: Container(
                                                      height: value.height,
                                                      width: value.width,
                                                      child:
                                                          ImageSequenceAnimator(
                                                        "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/imgSeqServer/imgSeq",
                                                        "imgSeq",
                                                        1,
                                                        0,
                                                        "png",
                                                        30,
                                                        key: Key(
                                                            "online+${widget.MyAR.id}"),
                                                        isAutoPlay: true,
                                                        isOnline: true,
                                                        fps: widget.videoFPS,
                                                        waitUntilCacheIsComplete:
                                                            true,
                                                        fullPaths:
                                                            widget.MyAR.imgSeq,
                                                        // cacheProgressIndicatorBuilder:
                                                        //     (context,
                                                        //         progress) {
                                                        //   return CircularProgressIndicator(
                                                        //     value: progress !=
                                                        //             null
                                                        //         ? progress
                                                        //         : 1,
                                                        //     backgroundColor:
                                                        //         color1,
                                                        //   );
                                                        // },

                                                        onReadyToPlay:
                                                            onOnlineReadyToPlay,
                                                        onPlaying:
                                                            onOnlinePlaying,
                                                        onStartPlaying: (s) {
                                                          if (widget.MyAR
                                                                  .audioFlag ==
                                                              true) {
                                                            _player!.play();
                                                          }
                                                        },
                                                      )
                                                      // color: constantColors.bioBg,
                                                      ),
                                                ),
                                                // child: Image.network(value.name),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onScaleStart: (details) {
                                  if (value == null) return;
                                  _initPos = details.focalPoint;
                                  _currentPos = Offset(
                                      value.xPosition!, value.yPosition!);
                                  _currentScale = value.scale;
                                  _currentRotation = value.rotation;
                                },
                                onScaleUpdate: (details) {
                                  if (value == null) return;
                                  final delta = details.focalPoint - _initPos!;
                                  final left = (delta.dx / screen!.width) +
                                      _currentPos!.dx;
                                  final top = (delta.dy / screen!.height) +
                                      _currentPos!.dy;

                                  setState(() {
                                    value.xPosition = Offset(left, top).dx;
                                    value.yPosition = Offset(left, top).dy;
                                    value.rotation =
                                        details.rotation + _currentRotation!;
                                    value.scale =
                                        details.scale * _currentScale!;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: value.xPosition! * screen!.width,
                                      top: value.yPosition! * screen!.height,
                                      child: Transform.scale(
                                        scale: value.scale,
                                        child: Transform.rotate(
                                          angle: value.rotation!,
                                          child: Container(
                                            height: value.height,
                                            width: value.width,
                                            child: FittedBox(
                                              fit: BoxFit.fill,
                                              child: Listener(
                                                onPointerDown: (details) {
                                                  // if (_inAction) return;
                                                  // _inAction = true;
                                                  // _activeItem = val;
                                                  _initPos = details.position;
                                                  _currentPos = Offset(
                                                      value.xPosition!,
                                                      value.yPosition!);
                                                  _currentScale = value.scale;
                                                  _currentRotation =
                                                      value.rotation;
                                                },
                                                onPointerUp: (details) {
                                                  // _inAction = false;
                                                },
                                                child: Container(
                                                  height: value.height,
                                                  width: value.width,
                                                  child: Image.network(
                                                    value.gifFilePath!,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                // child: Image.network(value.name),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(
                              height: 10,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.arViewerScreen
                                ? forArView.length
                                : forMaterialView.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: InkWell(
                                  onTap: widget.arViewerScreen
                                      ? forArView[index].function
                                      : forMaterialView[index].function,
                                  child: widget.arViewerScreen &&
                                          forArView[index].image != null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: constantColors.bioBg,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              forArView[index].image!,
                                              fit: BoxFit.contain,
                                              height: 20,
                                              width: 30,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 100.w / 8,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: constantColors.bioBg,
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            widget.arViewerScreen
                                                ? forArView[index].iconData
                                                : forMaterialView[index]
                                                    .iconData,
                                            color: constantColors.bioBg,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: CupertinoSlider(
                                value: imageSequenceAnimator == null
                                    ? 0.0
                                    : imageSequenceAnimator!.currentProgress,
                                min: 0.0,
                                max: imageSequenceAnimator == null
                                    ? 100.0
                                    : imageSequenceAnimator!.totalProgress,
                                onChangeStart: (double value) async {
                                  wasPlaying = imageSequenceAnimator!.isPlaying;
                                  imageSequenceAnimator!.pause();
                                  if (widget.MyAR.audioFlag == true) {
                                    await _player!.pause();
                                  }
                                },
                                onChanged: (double value) async {
                                  imageSequenceAnimator!.skip(value);
                                  if (widget.MyAR.audioFlag == true) {
                                    await _player!.seek(Duration(
                                      milliseconds: int.parse(
                                          imageSequenceAnimator!.currentTime
                                              .toStringAsFixed(0)),
                                    ));
                                  }
                                },
                                onChangeEnd: (double value) async {
                                  if (wasPlaying) {
                                    if (widget.MyAR.audioFlag == true) {
                                      imageSequenceAnimator!.play();
                                      await _player!.play();
                                    } else {
                                      imageSequenceAnimator!.play();
                                    }
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  imageSequenceAnimator == null
                                      ? "0.0"
                                      : ((imageSequenceAnimator!.currentTime
                                                      .ceil() /
                                                  1000)
                                              .toStringAsFixed(0) +
                                          "/" +
                                          (imageSequenceAnimator!.totalTime
                                                      .ceil() /
                                                  1000)
                                              .toStringAsFixed(0)),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
