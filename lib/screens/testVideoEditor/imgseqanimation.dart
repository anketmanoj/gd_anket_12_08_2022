import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/VideoCreationOptionsScreen.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spring_button/spring_button.dart';

class ImageSeqAniScreen extends StatefulWidget {
  const ImageSeqAniScreen(
      {Key? key,
      required this.folderName,
      required this.fileName,
      required this.MyAR})
      : super(key: key);

  final String folderName;
  final String fileName;

  final MyArCollection MyAR;

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

  @override
  void initState() {
    log("init Ar");
    screen = Size(400, 500);
    list.add(ARList(
      height: 200,
      rotation: 0,
      scale: 1,
      width: 200,
      xPosition: 0,
      yPosition: 0,
      pathsForVideoFrames: widget.MyAR.imgSeq,
    ));
    _init();

    log("added 1st to AR List ${widget.MyAR.imgSeq.length}");
    super.initState();

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

      setState(() {});
    });
  }

  @override
  void dispose() {
    imageSequenceAnimator!.dispose();
    _player!.dispose();
    controller!.dispose();

    super.dispose();
    log("disposed");
  }

  Future<void> _init() async {
    if (widget.MyAR.audioFlag == true) {
      try {
        await _player!.setUrl(widget.MyAR.audioFile);
        _player!.pause();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constantColors.navButton,
        title: Text("Ar Viewer"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  final point = ValueNotifier<double>(0);
                  if (widget.MyAR.audioFlag == true)
                    final point = ValueNotifier<double>(_player!.volume);
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    color: constantColors.navButton,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                "AR Control Options",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: constantColors.whiteColor),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        "Play/Pause",
                                        Colors.deepOrangeAccent,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (imageSequenceAnimator!
                                              .isPlaying) {
                                            if (widget.MyAR.audioFlag == true)
                                              _player!.pause();
                                            imageSequenceAnimator!.pause();
                                          } else {
                                            imageSequenceAnimator!.play();
                                            if (widget.MyAR.audioFlag == true)
                                              _player!.play();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        "Stop",
                                        Colors.green,
                                      ),
                                      onTap: () {
                                        imageSequenceAnimator!.stop();
                                        if (widget.MyAR.audioFlag == true)
                                          _player!.stop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        "Restart",
                                        Colors.teal,
                                      ),
                                      onTap: () async {
                                        if (widget.MyAR.audioFlag == true) {
                                          await _player!.seek(Duration.zero);
                                          await _player!.play();
                                        }
                                        imageSequenceAnimator!.restart();
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        "Rewind",
                                        Colors.indigoAccent,
                                      ),
                                      onTap: () {
                                        imageSequenceAnimator!.rewind();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        loopText,
                                        Colors.cyan,
                                      ),
                                      useCache: false,
                                      onTap: () async {
                                        switch (widget.MyAR.audioFlag) {
                                          case true:
                                            imageSequenceAnimator!.skip(0);

                                            setState(() {
                                              loopText = imageSequenceAnimator!
                                                      .isLooping
                                                  ? "Start Loop"
                                                  : "Stop Loop";
                                              boomerangText = "Start Boomerang";
                                              imageSequenceAnimator!
                                                  .setIsLooping(
                                                      !imageSequenceAnimator!
                                                          .isLooping);
                                            });

                                            await _player!.seek(Duration.zero);
                                            await _player!.setLoopMode(
                                                !imageSequenceAnimator!
                                                            .isLooping ==
                                                        true
                                                    ? LoopMode.off
                                                    : LoopMode.all);
                                            await _player!.play();
                                            imageSequenceAnimator!.play();

                                            Navigator.pop(context);

                                            break;
                                          case false:
                                            imageSequenceAnimator!.skip(0);

                                            setState(() {
                                              loopText = imageSequenceAnimator!
                                                      .isLooping
                                                  ? "Start Loop"
                                                  : "Stop Loop";
                                              boomerangText = "Start Boomerang";
                                              imageSequenceAnimator!
                                                  .setIsLooping(
                                                      !imageSequenceAnimator!
                                                          .isLooping);
                                            });

                                            imageSequenceAnimator!.play();

                                            Navigator.pop(context);

                                            break;
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: SpringButton(
                                      SpringButtonType.OnlyScale,
                                      row(
                                        boomerangText,
                                        Colors.deepPurpleAccent,
                                      ),
                                      useCache: false,
                                      onTap: () async {
                                        setState(() {
                                          loopText = "Start Loop";
                                          boomerangText =
                                              imageSequenceAnimator!.isBoomerang
                                                  ? "Start Boomerang"
                                                  : "Stop Boomerang";
                                          imageSequenceAnimator!.setIsBoomerang(
                                              !imageSequenceAnimator!
                                                  .isBoomerang);
                                        });

                                        Navigator.pop(context);
                                        Get.snackbar(
                                          'Boomerang is only applicable to video',
                                          "In Boomerang mode, no audio will be played. Only the video will be played in boomerang mode.",
                                          duration: Duration(seconds: 5),
                                          overlayColor:
                                              constantColors.navButton,
                                          colorText: constantColors.black,
                                          snackPosition: SnackPosition.TOP,
                                          forwardAnimationCurve:
                                              Curves.elasticInOut,
                                          reverseAnimationCurve: Curves.easeOut,
                                          backgroundColor: constantColors
                                              .navButton
                                              .withOpacity(0.6),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Icon(Icons.volume_down),
                                  Expanded(
                                    child: ValueListenableBuilder<double>(
                                      valueListenable: point,
                                      builder: (context, mark, _) {
                                        return CupertinoSlider(
                                          value: mark,
                                          min: 0,
                                          max: 1,
                                          onChanged: (double value) async {
                                            if (widget.MyAR.audioFlag == true) {
                                              point.value = value;

                                              await _player!
                                                  .setVolume(point.value);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Icon(Icons.volume_up_rounded),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SpringButton(
                                SpringButtonType.OnlyScale,
                                row(
                                  backgroundText,
                                  Colors.deepOrangeAccent,
                                ),
                                useCache: false,
                                onTap: () {
                                  setState(() {
                                    backgroundText = "Hide Camera Feed";
                                    showCamera = !showCamera;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
        leading: IconButton(
          onPressed: () {
            imageSequenceAnimator!.dispose();
            _player!.dispose();
            controller!.dispose();
            super.dispose();
            log("disposed");
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
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
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: list.map((value) {
                      return GestureDetector(
                        onScaleStart: (details) {
                          if (value == null) return;
                          _initPos = details.focalPoint;
                          _currentPos =
                              Offset(value.xPosition!, value.yPosition!);
                          _currentScale = value.scale;
                          _currentRotation = value.rotation;
                        },
                        onScaleUpdate: (details) {
                          if (value == null) return;
                          final delta = details.focalPoint - _initPos!;
                          final left =
                              (delta.dx / screen!.width) + _currentPos!.dx;
                          final top =
                              (delta.dy / screen!.height) + _currentPos!.dy;

                          setState(() {
                            value.xPosition = Offset(left, top).dx;
                            value.yPosition = Offset(left, top).dy;
                            value.rotation =
                                details.rotation + _currentRotation!;
                            value.scale = details.scale * _currentScale!;
                          });
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              right: -value.xPosition! * screen!.width,
                              bottom: -value.yPosition! * screen!.height,
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
                                          _currentPos = Offset(value.xPosition!,
                                              value.yPosition!);
                                          _currentScale = value.scale;
                                          _currentRotation = value.rotation;
                                          log("rotation == ${value.rotation! * 3.14 / 180}");
                                        },
                                        child: InkWell(
                                          onLongPress: () {
                                            setState(() {
                                              list.remove(value);
                                            });
                                          },
                                          child: Container(
                                              height: value.height,
                                              width: value.width,
                                              child: ImageSequenceAnimator(
                                                "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/imgSeqServer/imgSeq",
                                                "imgSeq",
                                                1,
                                                0,
                                                "png",
                                                30,
                                                key: Key("online"),
                                                isAutoPlay: true,
                                                isOnline: true,
                                                fps: 30,
                                                waitUntilCacheIsComplete: true,
                                                fullPaths: widget.MyAR.imgSeq,
                                                cacheProgressIndicatorBuilder:
                                                    (context, progress) {
                                                  return CircularProgressIndicator(
                                                    value: progress,
                                                    backgroundColor: color1,
                                                  );
                                                },
                                                onReadyToPlay:
                                                    onOnlineReadyToPlay,
                                                onPlaying: onOnlinePlaying,
                                                onStartPlaying: (s) {
                                                  if (widget.MyAR.audioFlag ==
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
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
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
                          milliseconds: int.parse(imageSequenceAnimator!
                              .currentTime
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
                          : ((imageSequenceAnimator!.currentTime.ceil() / 1000)
                                  .toStringAsFixed(0) +
                              "/" +
                              (imageSequenceAnimator!.totalTime.ceil() / 1000)
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
          ),
        ],
      ),
    );
  }
}
