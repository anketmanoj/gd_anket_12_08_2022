// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/GiphyTest/get_giphy_gifs.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/frame/frame_slider_painter.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/frame/frame_thumbnail_slider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/ui/video_viewer.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/VideoThumbnailSelectionScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/testingVideoOutput.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/img_seq_animator.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/extensions.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:diamon_rose_app/widgets/measure_widget_size.dart';
import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:dio/dio.dart' as dio;
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:giphy_get/giphy_get.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:just_audio/just_audio.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

enum _FrameBoundaries { left, right, inside, progress, none }

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen>
    with AutomaticKeepAliveClientMixin<CreateVideoScreen> {
  ConstantColors constantColors = ConstantColors();
  final _boundary = ValueNotifier<_FrameBoundaries>(_FrameBoundaries.none);
  // final _imgSeqProgress = ValueNotifier<double>(0);
  // final _imgSeqContainerWidth = ValueNotifier<double>(0);
  // final _showAr = ValueNotifier<bool>(true);
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  bool _exported = false;
  String _exportText = "";
  final _bgProgress = ValueNotifier<double>(0);
  final _scrollController = ScrollController();
  //Gif
  GiphyGif? currentGif;
  // Giphy Client
  GiphyClient? client;
  // Random ID
  String randomId = "";
  String giphyApiKey = "0X2ffUW2nnfVcPUc2C7alPhfdrj2tA6M";
  VideoPlayerController? _finalVideoController;

  Rect _rect = Rect.zero;
  Size _trimLayout = Size.zero;
  Size _fullLayout = Size.zero;
  late VideoEditorController _controller;
  late VideoPlayerController _videoController;
  final double height = 60;

  // * for Ar videos
  bool uploadAR = false;
  bool loading = true;
  String? folderName;
  ARList? selected;

  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  ValueNotifier<List<ARList>> list = ValueNotifier<List<ARList>>([]);
  int listVal = 0;
  Size? screen;
  bool onFinishedPlaying = false;
  ValueNotifier<int> arIndexVal = ValueNotifier<int>(0);

  // * for effects
  File? _selectedGifFile;
  ValueNotifier<int> effectIndexVal = ValueNotifier<int>(0);
  PlatformFile? selectedFile;
  late File thumbnailFile;

  ValueNotifier<int> indexCounter = ValueNotifier<int>(1);

  _openFileManager() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gif'],
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        effectIndexVal.value = list.value
                .where((element) => element.layerType == LayerType.Effect)
                .length +
            1;
      });

      if (effectIndexVal.value <= 2) {
        if (list.value.isNotEmpty) {
          list.value.last.layerType == LayerType.AR
              ? indexCounter.value = indexCounter.value + 2
              : indexCounter.value = indexCounter.value + 1;
        }

        await runGifFFmpegCommand(
          arVal: indexCounter.value,
          gifFile: File(selectedFile!.path!),
          fromFirebase: false,
        ).then((value) {
          setState(() {});
        });
      } else {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.info,
          title: "Max Effects's Reached",
          text: "You can only have 2 effects's",
        );
      }
    }
  }

  // * to get the size of the AR's
  var myChildSize = Size.zero;

  final videoContainerKey = GlobalKey();

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

  double _thumbnailPosition = 0.0;
  double? _ratio;
  // trim line width set in the style
  double _trimWidth = 0.0;

  double deg2rad(double deg) => deg * pi / 180;
  double posX = 0.0001;
  final oneSec = Duration(milliseconds: 100);
  bool gotArContainerWidth = false;
  double arContainerWidth = 0;
  bool showArContainer = false;
  // late String _videoPath;

  late Timer timer;

  @override
  void initState() {
    screen = Size(50, 50);

    // _videoPath =
    //     context.read<VideoEditorProvider>().getBackgroundVideoFile.path;

    client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      client!.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });

    _controller =
        context.read<VideoEditorProvider>().getBackgroundVideoController;
    _videoController =
        context.read<VideoEditorProvider>().getVideoPlayerController;

    _controller.video.setLooping(false);

    setState(() {});

    _ratio = getRatioDuration();
    _trimWidth = _controller.trimStyle.lineWidth;

    timer = Timer.periodic(oneSec, (Timer t) {
      double bgDuration = _fullLayout.width * _controller.trimPosition;

      _bgProgress.value = bgDuration;

      if (listVal < list.value.length) {
        setState(() {
          listVal = list.value.length;
        });
      }

      for (ARList arElement in list.value) {
        if (_controller.video.value.position.inMicroseconds <= 0 &&
            list.value.isNotEmpty) {
          if (arElement.finishedCaching!.value == true &&
              arElement.arState != null) {
            arElement.arState!.skip(0);
          }
          if (arElement.audioFlag == true)
            arElement.audioPlayer!.seek(Duration(milliseconds: 0));
        }

        if (arElement.startingPositon! < _bgProgress.value &&
            (arElement.endingPosition! + arElement.startingPositon!) >=
                _bgProgress.value &&
            _controller.isPlaying) {
          // _showAr.value = true;
          arElement.showAr!.value = true;
          // imageSequenceAnimator!.play();
          if (arElement.finishedCaching!.value == true)
            arElement.arState!.play();
          if (arElement.audioFlag == true) arElement.audioPlayer!.play();

          print("Show ar now ${arElement.showAr!.value}");
        } else if (arElement.showAr!.value == true &&
            (arElement.endingPosition! + arElement.startingPositon!) <=
                _bgProgress.value) {
          // _showAr.value = false;
          arElement.showAr!.value = false;

          print("Dont Show ar now ${arElement.showAr!.value}");
        }

        if (_controller.isPlaying == false &&
            arElement.startingPositon! >= bgDuration &&
            (arElement.startingPositon! + arElement.endingPosition! <=
                bgDuration)) {
          if (arElement.finishedCaching!.value == true &&
              arElement.arState != null) {
            arElement.arState!.pause();
            arElement.arState!.skip(bgDuration);
          }
          if (arElement.audioFlag == true &&
              arElement.finishedCaching!.value == true) {
            arElement.audioPlayer!.pause();
            arElement.audioPlayer!.seek(Duration(
                seconds: int.parse(
                    "${(arElement.arState!.currentTime.ceil() / 1000).toStringAsFixed(0)}")));
          }
        }

        if (arElement.arState != null && arElement.endingPosition == 0) {
          final double imgSeqTotalTime = arElement.totalDuration!;

          final double controllerTotalTime = double.parse(
              "${_fullLayout.width / _controller.video.value.duration.inSeconds}");

          final double arContainer = imgSeqTotalTime * controllerTotalTime;

          print(" arContainerWidth == $arContainer");

          setState(() {
            arContainerWidth = arContainer;
            gotArContainerWidth = true;
            arElement.endingPosition = arContainer +
                (_fullLayout.width / _controller.maxDuration.inSeconds);
          });
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;

  // * running ffmpeg to get video with no background
  Future<void> runFFmpegCommand({
    required int arVal,
    required MyArCollection myAr,
  }) async {
    if (await Permission.storage.request().isGranted) {
      dev.log("AR INDEX == $arVal");
      // ignore: unawaited_futures
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false,
        text: LocaleKeys.loadingar.tr(),
      );
      // Form matte file
      final Directory appDocument = await getApplicationDocumentsDirectory();
      final String rawDocument = appDocument.path;
      final String imgSeqFolder = "${rawDocument}/";

      setState(() {
        folderName = imgSeqFolder;
      });

      try {
        await FFprobeKit.execute(
                '-i ${Uri.parse(myAr.main)} -show_entries format=duration -v quiet -of json')
            .then((value) {
          value.getOutput().then((mapOutput) async {
            final Map<String, dynamic> json = jsonDecode(mapOutput!);

            final String durationString = json['format']['duration'];

            print("durationString: $durationString");

            final String setDuration = double.parse(durationString) >=
                    _controller.video.value.duration.inSeconds
                ? _controller.video.value.duration.inSeconds.toString()
                : durationString;

            //! #############################################################

            final List<String> _fullPathsOnline = myAr.imgSeq;

            final File arCutOutFile = await getImage(url: _fullPathsOnline[0]);
            dev.log("ArCut out ois here  = ${arCutOutFile.path}");

            File? audioFile;
            final AudioPlayer? _player = AudioPlayer();

            if (myAr.audioFlag == true) {
              try {
                await FFmpegKit.execute(
                        '-vn -sn -dn -y -i ${Uri.parse(myAr.audioFile)} -t ${double.parse(setDuration)} -vn -acodec copy ${imgSeqFolder}${arVal}audio.aac')
                    .then((rc) {
                  print("FFmpeg audio extraction success");
                  audioFile = File("${imgSeqFolder}${arVal}audio.aac");
                  print(audioFile!.path + "in");
                });
              } catch (e) {
                print("FFmpeg audio extraction Error ==== ${e.toString()}");
              }

              print(audioFile!.path + "out");

              await _player!.setFilePath(audioFile!.path);
              await _player.pause();
            }

            final containerKey = GlobalKey();

            try {
              await FFprobeKit.execute(
                      "-v error -show_streams -print_format json -i ${_fullPathsOnline[0]}")
                  .then((value) {
                value.getOutput().then((imageDetails) {
                  final Map<String, dynamic> json = jsonDecode(imageDetails!);

                  final int videoWidth = json['streams'][0]['width'];
                  final int videoHeight = json['streams'][0]['height'];

                  list.value.add(ARList(
                    arId: myAr.id,
                    arIndex: arVal,
                    height: ((videoContainerKey.globalPaintBounds!.height *
                                videoHeight) /
                            1920) /
                        1.3,
                    rotation: 0,
                    scale: 1,
                    width: ((videoContainerKey.globalPaintBounds!.width *
                                videoWidth) /
                            1080) /
                        1.3,
                    xPosition: 0,
                    yPosition: 0,
                    pathsForVideoFrames: _fullPathsOnline,
                    startingPositon: 0,
                    endingPosition: 0,
                    totalDuration: _fullPathsOnline.length / 30,
                    showAr: ValueNotifier(false),
                    audioPlayer: _player,
                    layerType: LayerType.AR,
                    arKey: containerKey,
                    fromFirebase: true,
                    mainFile: myAr.main,
                    alphaFile: myAr.alpha,
                    audioFlag: myAr.audioFlag,
                    finishedCaching: ValueNotifier(false),
                    ownerId: myAr.ownerId,
                    ownerName: myAr.ownerName,
                    selectedMaterial: ValueNotifier<bool>(true),
                    arCutOutFile: arCutOutFile,
                  ));

                  _controllerSeekTo(0);
                  if (!mounted) return;

                  arIndexVal.value += 1;

                  dev.log(
                      "list AR ${arIndexVal.value} | index counter == $arVal");
                  Get.back();
                  Get.back();
                  setState(() {});
                });
              });
            } catch (e) {
              print("error running ffprobe on image == ${e.toString()}");
            }

            final bool showMessage =
                SharedPreferencesHelper.getBool("dontShowMessage");

            if (showMessage == false) {
              final ValueNotifier<bool> dontShowMessage =
                  ValueNotifier<bool>(false);
              await Get.dialog(
                SimpleDialog(
                  children: [
                    Container(
                      width: 100.w,
                      child: Text(
                        "AR Quality in the Video Editor may seem low resolution.\nThis is to be able to process multiple layers together.\nPlease go to the next page to see the actual quality",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: dontShowMessage,
                        builder: (context, messageOpt, _) {
                          return ListTile(
                            title: Text("Dont show message again"),
                            trailing: Checkbox(
                              value: dontShowMessage.value,
                              onChanged: (v) {
                                dontShowMessage.value = !dontShowMessage.value;
                              },
                            ),
                          );
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              constantColors.navButton),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        onPressed: () {
                          SharedPreferencesHelper.setBool(
                              "dontShowMessage", dontShowMessage.value);
                          Get.back();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            Text(
                              LocaleKeys.understood.tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // setState(() {
            //   loading = false;
            // });
            // print("folder name $folderName");

            //! #############################################################
          });
        });
      } catch (e) {
        print("FFmpeg Error ==== ${e.toString()}");
      }
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
  }

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

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, imageName));
    file.writeAsBytesSync(res.data as List<int>);

    return file;
  }

  // * running ffmpeg for Gif to add as Effect
  Future<void> runGifFFmpegCommand({
    required File gifFile,
    required int arVal,
    required bool fromFirebase,
    String? arId,
    String? ownerId,
    String? ownerName,
  }) async {
    final PermissionStatus req = await Permission.storage.request();
    dev.log("req == ${req}");

    if (req.isGranted) {
      dev.log("Owner id == $ownerId | OwnerName == $ownerName");
      // ignore: unawaited_futures
      CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        barrierDismissible: false,
        text: "Loading Effect",
      );
      // Form matte file
      final Directory appDocument = await getTemporaryDirectory();
      final String rawDocument = appDocument.path;
      final String gifSeqFolder = "${rawDocument}/";

      final String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

      setState(() {
        folderName = gifSeqFolder;
      });

      try {
        await FFprobeKit.execute(
                '-i ${gifFile.path} -show_entries format=duration -v quiet -of json')
            .then((value) {
          value.getOutput().then((mapOutput) async {
            final Map<String, dynamic> json = jsonDecode(mapOutput!);

            String durationString = json['format']['duration'];

            print("durationString: $durationString");

            durationString =
                double.parse(durationString) < 1 ? "1" : durationString;

            final String setDuration = double.parse(durationString) >=
                    _controller.video.value.duration.inSeconds
                ? _controller.video.value.duration.inSeconds.toString()
                : durationString;

            //! #############################################################
            final String commandForGifSeqFile =
                '-y -i ${gifFile.path} -filter_complex "fps=30,scale=360:-1"  -preset ultrafast  ${gifSeqFolder}${arVal}${timeNow}gifSeq%d.png';

            final List<String> _fullPathsOffline = [];

            try {
              await FFmpegKit.execute(commandForGifSeqFile).then((rc) async {
                for (int i = 0;
                    i < (double.parse(setDuration).floor() * 30);
                    i++) {
                  _fullPathsOffline
                      .add("${gifSeqFolder}${arVal}${timeNow}gifSeq$i.png");
                }
              });

              _fullPathsOffline.removeAt(0);

              final _player = AudioPlayer();

              _player.pause();

              final containerKey = GlobalKey();

              await FFmpegKit.execute(
                      "-i ${gifFile.path} -crf 30 -preset ultrafast -filter_complex \"[0:v] split [a][b]; [a] palettegen=reserve_transparent=on [p]; [b][p] paletteuse\" -y ${gifSeqFolder}gifFile${timeNow}${arVal}.gif")
                  .then((vv) async {
                try {
                  await FFprobeKit.execute(
                          "-v error -show_streams -print_format json -i ${_fullPathsOffline[0]}")
                      .then((value) {
                    value.getOutput().then((imageDetails) {
                      final Map<String, dynamic> json =
                          jsonDecode(imageDetails!);

                      final int videoWidth = json['streams'][0]['width'];
                      final int videoHeight = json['streams'][0]['height'];

                      list.value.add(ARList(
                        arId: arId,
                        fromFirebase: fromFirebase,
                        arIndex: arVal,
                        height: ((videoContainerKey.globalPaintBounds!.height *
                                    videoHeight) /
                                960) /
                            1.3,
                        rotation: 0,
                        scale: 1,
                        width: ((videoContainerKey.globalPaintBounds!.width *
                                    videoWidth) /
                                540) /
                            1.3,
                        xPosition: 0,
                        yPosition: 0,
                        pathsForVideoFrames: _fullPathsOffline,
                        startingPositon: 0,
                        endingPosition: 0,
                        totalDuration: _fullPathsOffline.length / 30,
                        showAr: ValueNotifier(false),
                        audioPlayer: _player,
                        layerType: LayerType.Effect,
                        gifFilePath:
                            "${gifSeqFolder}gifFile${timeNow}${arVal}.gif",
                        arKey: containerKey,
                        finishedCaching: ValueNotifier(true),
                        ownerId: ownerId ??
                            Provider.of<Authentication>(context, listen: false)
                                .getUserId,
                        ownerName: ownerName ??
                            Provider.of<FirebaseOperations>(context,
                                    listen: false)
                                .initUserName,
                        selectedMaterial: ValueNotifier<bool>(true),
                      ));

                      _controllerSeekTo(0);

                      if (!mounted) return;

                      effectIndexVal.value += 1;
                      dev.log(
                          "list effect = ${effectIndexVal.value} || index counter == $arVal");
                      Get.back();
                      // Get.back();
                      setState(() {});
                    });
                  });
                } catch (e) {
                  print("error running ffprobe on image == ${e.toString()}");
                }
              });

              // Navigator.pop(context);

            } catch (e) {
              Navigator.pop(context);
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                text: "Error in loading effect",
              );
            }
            //! #############################################################
          });
        });
      } catch (e) {
        print("FFmpeg gif Error ==== ${e.toString()}");
      }
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  //--------//
  //GESTURES//
  //--------//
  void _onHorizontalDragStart(DragStartDetails details) {
    final double margin = 25.0 + 0.0;
    final double pos = details.localPosition.dx;
    final double max = _rect.right;
    final double min = _rect.left;
    final double progressTrim = _getTrimPosition();
    final List<double> minMargin = [min - margin, min + margin];
    final List<double> maxMargin = [max - margin, max + margin];

    //IS TOUCHING THE GRID
    if (pos >= minMargin[0] && pos <= maxMargin[1]) {
      //TOUCH BOUNDARIES
      if (pos >= minMargin[0] && pos <= minMargin[1]) {
        _boundary.value = _FrameBoundaries.left;
      } else if (pos >= maxMargin[0] && pos <= maxMargin[1]) {
        _boundary.value = _FrameBoundaries.right;
      } else if (pos >= progressTrim - margin && pos <= progressTrim + margin) {
        _boundary.value = _FrameBoundaries.progress;
      } else if (pos >= minMargin[1] && pos <= maxMargin[0]) {
        _boundary.value = _FrameBoundaries.inside;
      } else {
        _boundary.value = _FrameBoundaries.none;
      }
      _updateControllerIsTrimming(true);
    } else {
      _boundary.value = _FrameBoundaries.none;
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final Offset delta = details.delta;
    switch (_boundary.value) {
      case _FrameBoundaries.left:
        final pos = _rect.topLeft + delta;
        // avoid minTrim to be bigger than maxTrim
        if (pos.dx > 0.0 && pos.dx < _rect.right - _trimWidth * 2) {
          _changeTrimRect(left: pos.dx, width: _rect.width - delta.dx);
        }
        break;
      case _FrameBoundaries.right:
        final pos = _rect.topRight + delta;
        // avoid maxTrim to be smaller than minTrim
        if (pos.dx < _trimLayout.width + 0.0 &&
            pos.dx > _rect.left + _trimWidth * 2) {
          _changeTrimRect(width: _rect.width + delta.dx);
        }
        break;
      case _FrameBoundaries.inside:
        final pos = _rect.topLeft + delta;
        // Move thumbs slider when the trimmer is on the edges
        if (_rect.topLeft.dx + delta.dx < 0.0 ||
            _rect.topRight.dx + delta.dx > _trimLayout.width) {
          _scrollController.position.moveTo(
            _scrollController.offset + delta.dx,
          );
        }
        if (pos.dx > 0.0 && pos.dx < _rect.right) {
          _changeTrimRect(left: pos.dx);
        }
        break;
      case _FrameBoundaries.progress:
        final double pos = details.localPosition.dx;
        if (pos >= _rect.left && pos <= _rect.right) _controllerSeekTo(pos);
        break;
      case _FrameBoundaries.none:
        break;
    }
  }

  void _onHorizontalDragEnd(_) {
    if (_boundary.value != _FrameBoundaries.none) {
      final double _progressTrim = _getTrimPosition();
      if (_progressTrim >= _rect.right || _progressTrim < _rect.left) {
        _controllerSeekTo(_progressTrim);
      }
      _updateControllerIsTrimming(false);
      if (_boundary.value != _FrameBoundaries.progress) {
        if (_boundary.value != _FrameBoundaries.right) {
          _controllerSeekTo(_rect.left);
        }
        _updateControllerTrim();
      }
    }
  }

  //----//
  //RECT//
  //----//
  void _changeTrimRect({double? left, double? width}) {
    left = left ?? _rect.left;
    width = width ?? _rect.width;

    final Duration diff = _getDurationDiff(left, width);

    if (left >= 0 &&
        left + width - 0.0 <= _trimLayout.width &&
        diff <= _controller.maxDuration) {
      // _rect = Rect.fromLTWH(left, _rect.top, width, _rect.height);
      // _updateControllerTrim();
    }
  }

  void _createTrimRect() {
    _rect = Rect.fromPoints(
      Offset(_controller.minTrim * _fullLayout.width + 0.0, 0.0),
      Offset(_controller.maxTrim * _fullLayout.width + 0.0, height),
    );
  }

  //----//
  //MISC//
  //----//
  void _controllerSeekTo(double position) async {
    await _videoController.seekTo(
      _videoController.value.duration * (position / _fullLayout.width),
    );

    for (ARList ar in list.value) {
      if (position >= ar.startingPositon! &&
          position <= ar.startingPositon! + ar.endingPosition!) {
        _controller.video.pause();
        if (ar.finishedCaching!.value == true && ar.arState != null) {
          ar.arState!.pause();
          ar.arState!.skip(position);
        }
        if (ar.audioFlag == true && ar.finishedCaching!.value == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(
              seconds: int.parse(
                  "${(ar.arState!.currentTime.ceil() / 1000).toStringAsFixed(0)}")));
        }
        ar.showAr!.value = true;
      } else if (position < ar.startingPositon!) {
        _controller.video.pause();
        ar.arState!.pause();
        if (ar.audioFlag == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(seconds: 0));
        }
        ar.showAr!.value = false;
        ar.arState!.skip(0);
      } else if (position > ar.startingPositon! + ar.endingPosition!) {
        _controller.video.pause();
        ar.arState!.pause();
        if (ar.audioFlag == true) {
          ar.audioPlayer!.pause();
          ar.audioPlayer!.seek(Duration(
              seconds: int.parse(
                  "${(ar.arState!.totalTime.ceil() / 1000).toStringAsFixed(0)}")));
        }
        ar.showAr!.value = false;
        ar.arState!.skip(ar.arState!.totalTime);
      }
    }
  }

  void _updateControllerTrim() {
    final double width = _fullLayout.width;
    _controller.updateTrim((_rect.left + _thumbnailPosition - 0.0) / width,
        (_rect.right + _thumbnailPosition - 0.0) / width);
  }

  void _updateControllerIsTrimming(bool value) {
    if (_boundary.value != _FrameBoundaries.none &&
        _boundary.value != _FrameBoundaries.progress) {
      _controller.isTrimming = value;
    }
  }

  double _getTrimPosition() {
    _bgProgress.value =
        _fullLayout.width * _controller.trimPosition - _thumbnailPosition + 0.0;
    // print(
    //     "thumbnail position ${_fullLayout.width * _controller.trimPosition - _thumbnailPosition + 0.0}");
    // print("total width ${_fullLayout.width}");
    // print(_controller.video.value.position);
    return _fullLayout.width * _controller.trimPosition -
        _thumbnailPosition +
        0.0;
  }

  double getRatioDuration() {
    return _controller.videoDuration.inMilliseconds /
        _controller.maxDuration.inMilliseconds;
  }

  Duration _getDurationDiff(double left, double width) {
    final double min = (left - 0.0) / _fullLayout.width;
    final double max = (left + width - 0.0) / _fullLayout.width;
    final Duration duration = _videoController.value.duration;
    return (duration * max) - (duration * min);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final ArVideoCreation arVideoCreation =
        Provider.of<ArVideoCreation>(context, listen: false);
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
            dev.log("here");

            if (effectIndexVal.value <= 10) {
              if (list.value.isNotEmpty) {
                list.value.last.layerType == LayerType.AR
                    ? indexCounter.value = indexCounter.value + 2
                    : indexCounter.value = indexCounter.value + 1;
              }

              if (indexCounter.value <= 0) {
                indexCounter.value = 1;
              }

              dev.log("index value before in gif == ${indexCounter.value}");

              final File gifFile = await getImage(
                  url: "https://i.giphy.com/media/${gif.id}/giphy.gif");
              Get.back();

              await runGifFFmpegCommand(
                arVal: indexCounter.value,
                gifFile: File(gifFile.path),
                fromFirebase: false,
              );
            } else {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.info,
                title: "Max Effects's Reached",
                text: "You can only have 10 effects's",
              );
            }

            // setState(() {
            //   currentGif = gif;
            // });
          });
          return Scaffold(
            backgroundColor: Colors.grey,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            _videoController.value.isInitialized
                                ? Container(
                                    key: videoContainerKey,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videoController.value.aspectRatio,
                                      child: VideoViewer(
                                        controller: _controller,
                                      ),
                                    ),
                                  )
                                : Center(child: CircularProgressIndicator()),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: LayoutBuilder(
                                  builder: (context, videoConstaints) {
                                return Stack(
                                  children: list.value.map((value) {
                                    return ValueListenableBuilder<Object>(
                                        valueListenable: value.showAr!,
                                        builder: (context, boolVal, _) {
                                          return Opacity(
                                            opacity: boolVal == true ? 1 : 0,
                                            child: GestureDetector(
                                              onScaleStart: (details) {
                                                if (value == null) return;
                                                _initPos = details.focalPoint;
                                                _currentPos = Offset(
                                                    value.xPosition!,
                                                    value.yPosition!);
                                                _currentScale = value.scale;
                                                _currentRotation =
                                                    value.rotation;
                                              },
                                              onScaleUpdate: (details) {
                                                if (value == null) return;
                                                final delta =
                                                    details.focalPoint -
                                                        _initPos!;
                                                final left =
                                                    (delta.dx / screen!.width) +
                                                        _currentPos!.dx;
                                                final top = (delta.dy /
                                                        screen!.height) +
                                                    _currentPos!.dy;

                                                setState(() {
                                                  value.xPosition =
                                                      Offset(left, top).dx;
                                                  value.yPosition =
                                                      Offset(left, top).dy;
                                                  value.rotation =
                                                      details.rotation +
                                                          _currentRotation!;
                                                  value.scale = details.scale *
                                                      _currentScale!;
                                                });

                                                // !Found rotation in degrees here
                                                dev.log(
                                                    "scale == ${value.scale}");
                                                dev.log(
                                                    "rot = ${value.rotation! * 180 / pi}");
                                              },
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    right: -value.xPosition! *
                                                        screen!.width,
                                                    bottom: -value.yPosition! *
                                                        screen!.height,
                                                    child: Transform.scale(
                                                      scale: value.scale,
                                                      child: Transform.rotate(
                                                        angle: value.rotation!,
                                                        child: Container(
                                                          key: value.arKey,
                                                          height: value.height,
                                                          width: value.width,
                                                          child: FittedBox(
                                                            fit: BoxFit.cover,
                                                            child: Listener(
                                                              onPointerDown:
                                                                  (details) {
                                                                // _initPos = details.position;
                                                                // _currentPos = Offset(
                                                                //     value.xPosition!, value.yPosition!);
                                                                // _currentScale = value.scale;
                                                                // _currentRotation = value.rotation;
                                                                // print(" _initPos = ${_initPos!.dx}");
                                                                setState(() {
                                                                  _controller
                                                                      .video
                                                                      .pause();

                                                                  selected =
                                                                      value;

                                                                  for (ARList arPlaying
                                                                      in list
                                                                          .value) {
                                                                    if (arPlaying
                                                                            .showAr!
                                                                            .value ==
                                                                        true) {
                                                                      arPlaying
                                                                          .arState!
                                                                          .pause();
                                                                      if (arPlaying
                                                                              .audioFlag ==
                                                                          true) {
                                                                        arPlaying
                                                                            .audioPlayer!
                                                                            .pause();
                                                                      }
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                              onPointerUp:
                                                                  (details) {
                                                                _initPos = details
                                                                    .position;
                                                                _currentPos = Offset(
                                                                    value
                                                                        .xPosition!,
                                                                    value
                                                                        .yPosition!);
                                                                _currentScale =
                                                                    value.scale;
                                                                _currentRotation =
                                                                    value
                                                                        .rotation;
                                                              },
                                                              child: InkWell(
                                                                onTap: () {},
                                                                child:
                                                                    Container(
                                                                  height: value
                                                                      .height,
                                                                  width: value
                                                                      .width,
                                                                  child:
                                                                      ImageSequenceAnimator(
                                                                    "",
                                                                    "imgSeq",
                                                                    1,
                                                                    0,
                                                                    "png",
                                                                    30,
                                                                    isOnline: value.layerType ==
                                                                            LayerType.AR
                                                                        ? true
                                                                        : false,
                                                                    key: value.layerType ==
                                                                            LayerType
                                                                                .AR
                                                                        ? Key(
                                                                            "online")
                                                                        : Key(
                                                                            "offline"),
                                                                    fullPaths: value
                                                                        .pathsForVideoFrames,
                                                                    onReadyToPlay:
                                                                        (ImageSequenceAnimatorState
                                                                            _imageSequenceAnimator) {
                                                                      value.arState =
                                                                          _imageSequenceAnimator;
                                                                      if (value
                                                                              .layerType ==
                                                                          LayerType
                                                                              .AR)
                                                                        value.finishedCaching =
                                                                            ValueNotifier(true);
                                                                    },
                                                                    waitUntilCacheIsComplete:
                                                                        true,
                                                                    fps: 35,
                                                                    frameHeight:
                                                                        value
                                                                            .height!,
                                                                    frameWidth:
                                                                        value
                                                                            .width!,
                                                                    isAutoPlay:
                                                                        false,
                                                                    onPlaying: value.layerType ==
                                                                            LayerType.AR
                                                                        ? onOnlinePlaying
                                                                        : null,
                                                                  ),
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
                                            ),
                                          );
                                        });
                                  }).toList(),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      width: size.width,
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.isPlaying
                                  ? _controller.video.pause()
                                  : _controller.video.play();

                              for (ARList arPlaying in list.value) {
                                if (arPlaying.showAr!.value == true) {
                                  arPlaying.arState!.isPlaying &&
                                          arPlaying.finishedCaching!.value ==
                                              true
                                      ? arPlaying.arState!.pause()
                                      : arPlaying.arState!.play();

                                  arPlaying.audioPlayer!.playing &&
                                          arPlaying.audioFlag == true
                                      ? arPlaying.audioPlayer!.pause()
                                      : arPlaying.audioPlayer!.play();
                                }
                              }
                            });
                          },
                          icon: Icon(
                            !_controller.isPlaying
                                ? Icons.play_arrow
                                : Icons.pause,
                            color: constantColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // For Foreground videos
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 20, left: 10),
                                child: Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              Expanded(
                                child: ValueListenableBuilder<List<ARList>>(
                                  valueListenable: list,
                                  builder: (context, arListValFull, child) {
                                    return LayoutBuilder(
                                        builder: (context, constaints) {
                                      final Size trimLayout = Size(
                                          constaints.maxWidth - 0.0 * 2,
                                          constaints.maxHeight);
                                      final Size fullLayout = Size(
                                          trimLayout.width *
                                              (_ratio! > 1 ? _ratio! : 1),
                                          constaints.maxHeight);

                                      return Column(
                                        children: [
                                          Column(
                                            children:
                                                arListValFull.map((arVal) {
                                              return InkWell(
                                                onDoubleTap: () {
                                                  dev.log("this");
                                                  setState(() {
                                                    selected = arVal;
                                                  });
                                                },
                                                onTap: () {
                                                  if (arVal.audioFlag == true)
                                                    showAlertDialog(
                                                        context: context,
                                                        ar: arVal);
                                                },
                                                child: Container(
                                                  width: fullLayout.width,
                                                  height: 50,
                                                  color:
                                                      constantColors.greyColor,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      AnimatedPositioned(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    100),
                                                        left: arVal
                                                            .startingPositon,
                                                        key: UniqueKey(),
                                                        child: Container(
                                                          height: 50,
                                                          width: arVal.finishedCaching!
                                                                      .value ==
                                                                  true
                                                              ? arVal
                                                                  .endingPosition
                                                              : size.width *
                                                                  0.3,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: arVal.layerType ==
                                                                    LayerType.AR
                                                                ? constantColors
                                                                    .mainColor
                                                                : constantColors
                                                                    .darkColor,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: selected ==
                                                                      arVal
                                                                  ? 3
                                                                  : 1,
                                                            ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            child: arVal.finishedCaching!
                                                                            .value ==
                                                                        true &&
                                                                    arVal.layerType ==
                                                                        LayerType
                                                                            .AR
                                                                ? Image.file(arVal
                                                                    .arCutOutFile!)
                                                                : arVal.layerType ==
                                                                        LayerType
                                                                            .Effect
                                                                    ? Image
                                                                        .file(
                                                                        File(arVal
                                                                            .pathsForVideoFrames![1]),
                                                                      )
                                                                    : Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      ),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onPanStart: (details) {
                                                          _controller.video
                                                              .pause();
                                                        },
                                                        onPanUpdate: (details) {
                                                          if (details.localPosition
                                                                      .dx >=
                                                                  0 &&
                                                              details.localPosition
                                                                      .dx <=
                                                                  fullLayout
                                                                          .width -
                                                                      arVal
                                                                          .endingPosition!) {
                                                            setState(() {
                                                              arVal.startingPositon =
                                                                  details
                                                                      .localPosition
                                                                      .dx;
                                                            });
                                                          }

                                                          // ! to get the starting point in seconds

                                                          // print((arVal.startingPositon! /
                                                          //         _fullLayout.width) *
                                                          //     _videoController.value
                                                          //         .duration.inSeconds);
                                                          // ^ this gives the starting point of the AR video in seconds
                                                          // next we need to convert it from seconds to HH:mm:ss

                                                          // _controller.video.pause();

                                                          // print(
                                                          //     "ending time ${arVal.pathsForVideoFrames!.length / 30}");

                                                          for (ARList arElement
                                                              in list.value) {
                                                            if (arElement
                                                                    .arState!
                                                                    .isPlaying ||
                                                                arElement
                                                                    .audioPlayer!
                                                                    .playing) {
                                                              arElement.arState!
                                                                  .pause();
                                                              if (arElement
                                                                      .audioFlag ==
                                                                  true) {
                                                                arElement
                                                                    .audioPlayer!
                                                                    .pause();
                                                              }
                                                            }
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                constantColors
                                                                    .navButton),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          _controller.video
                                                              .pause();
                                                        });
                                                        selectArBottomSheet(
                                                            context, size);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            LocaleKeys.addar
                                                                .tr(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: AnimatedBuilder(
                                                        animation:
                                                            Listenable.merge([
                                                          effectIndexVal,
                                                          arIndexVal,
                                                        ]),
                                                        builder: (context, _) {
                                                          return ElevatedButton(
                                                            style: ButtonStyle(
                                                              foregroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      constantColors
                                                                          .navButton),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                _controller
                                                                    .video
                                                                    .pause();
                                                              });
                                                              // _openFileManager();
                                                              // ! get giphy here
                                                              giphyGetWrapper
                                                                  .getGif(
                                                                '',
                                                                context,
                                                              );
                                                              // selectEffectBottomSheet(
                                                              //   context: context,
                                                              //   size: size,
                                                              //   effectValIndex:
                                                              //       effectIndexVal
                                                              //           .value,
                                                              //   arValIndex:
                                                              //       arIndexVal.value,
                                                              // );
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(LocaleKeys
                                                                    .addeffect
                                                                    .tr()),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );

                                      // return Container(
                                      //   color: constantColors.greyColor,
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.center,
                                      //     children: [
                                      //       ElevatedButton(
                                      //         onPressed: () async {
                                      //           await runFFmpegCommand();
                                      //           setState(() {
                                      //             _showAr.value = false;
                                      //           });
                                      //         },
                                      //         child: Text("Select AR"),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );

                                      // return arContainerWidth != 0
                                      //     ? Container(
                                      //         width: fullLayout.width,
                                      //         height: 50,
                                      //         color: constantColors.greyColor,
                                      //         child: Stack(
                                      //           alignment: Alignment.center,
                                      //           children: [
                                      //             AnimatedPositioned(
                                      //               duration:
                                      //                   const Duration(milliseconds: 100),
                                      //               left: posX,
                                      //               key: const ValueKey("item 1"),
                                      //               child: Container(
                                      //                 height: 50,
                                      //                 width: arContainerWidth,
                                      //                 decoration: BoxDecoration(
                                      //                   color: constantColors.mainColor,
                                      //                   border: Border.all(
                                      //                     color: Colors.white,
                                      //                     width: 1,
                                      //                   ),
                                      //                 ),
                                      //                 alignment: Alignment.center,
                                      //                 child: Container(
                                      //                   child: Image.file(
                                      //                       File(_fullPathsOffline[0])),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             GestureDetector(
                                      //               onPanStart: (details) {
                                      //                 _controller.video.pause();
                                      //               },
                                      //               onPanUpdate: (details) {
                                      //                 if (details.localPosition.dx > 0 &&
                                      //                     details.localPosition.dx <=
                                      //                         fullLayout.width -
                                      //                             arContainerWidth) {
                                      //                   setState(() {
                                      //                     posX = details.localPosition.dx;
                                      //                   });
                                      //                 }

                                      //                 _imgSeqProgress.value = posX;

                                      //                 print(
                                      //                     "posX == ${_imgSeqProgress.value}");
                                      //               },
                                      //             )
                                      //           ],
                                      //         ),
                                      //       )
                                      //     : Container(
                                      //         color: constantColors.greyColor,
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.center,
                                      //           children: [
                                      //             ElevatedButton(
                                      //               onPressed: () async {
                                      //                 await runFFmpegCommand();
                                      //                 setState(() {
                                      //                   _showAr.value = false;
                                      //                 });
                                      //               },
                                      //               child: Text("Select AR"),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          // For background videos
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20, left: 10),
                                  child: Icon(
                                    EvaIcons.videoOutline,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                Expanded(
                                  child: _controller.video.value.isInitialized
                                      ? Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: height / 4),
                                          child: LayoutBuilder(
                                              builder: (_, contrainst) {
                                            final Size trimLayout = Size(
                                                contrainst.maxWidth - 0.0 * 2,
                                                contrainst.maxHeight);
                                            final Size fullLayout = Size(
                                                trimLayout.width *
                                                    (_ratio! > 1 ? _ratio! : 1),
                                                contrainst.maxHeight);
                                            _fullLayout = fullLayout;

                                            if (_trimLayout != trimLayout) {
                                              _trimLayout = trimLayout;
                                              _createTrimRect();
                                            }

                                            return InkWell(
                                              onLongPress: () {
                                                showBgAlertDialog(
                                                    context: context,
                                                    controller: _controller);
                                              },
                                              child: SizedBox(
                                                  width: _fullLayout.width,
                                                  child: Stack(children: [
                                                    NotificationListener<
                                                        ScrollNotification>(
                                                      child:
                                                          SingleChildScrollView(
                                                        controller:
                                                            _scrollController,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0.0),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: height,
                                                                width:
                                                                    _fullLayout
                                                                        .width,
                                                                child: FrameThumbnailSlider(
                                                                    controller:
                                                                        _controller,
                                                                    height:
                                                                        height,
                                                                    quality: 1),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    _fullLayout
                                                                        .width,
                                                                child:
                                                                    FrameTimeline(
                                                                  controller:
                                                                      _controller,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      onNotification:
                                                          (notification) {
                                                        _boundary.value =
                                                            _FrameBoundaries
                                                                .inside;
                                                        _updateControllerIsTrimming(
                                                            true);
                                                        if (notification
                                                            is ScrollEndNotification) {
                                                          _thumbnailPosition =
                                                              notification
                                                                  .metrics
                                                                  .pixels;
                                                          _controllerSeekTo(
                                                              _rect.left);
                                                          for (ARList element
                                                              in list.value) {
                                                            element.arState!
                                                                .skip(
                                                                    _rect.left);
                                                            if (element
                                                                    .audioFlag ==
                                                                true) {
                                                              element
                                                                  .audioPlayer!
                                                                  .seek(Duration(
                                                                      seconds: _rect
                                                                          .left
                                                                          .toInt()));
                                                            }
                                                          }
                                                          _updateControllerIsTrimming(
                                                              false);
                                                          _updateControllerTrim();
                                                        }
                                                        return true;
                                                      },
                                                    ),
                                                    GestureDetector(
                                                      onHorizontalDragUpdate:
                                                          _onHorizontalDragUpdate,
                                                      onHorizontalDragStart:
                                                          _onHorizontalDragStart,
                                                      onHorizontalDragEnd:
                                                          _onHorizontalDragEnd,
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            Listenable.merge([
                                                          _controller,
                                                          _videoController,
                                                        ]),
                                                        builder: (_, __) {
                                                          return CustomPaint(
                                                            size:
                                                                Size.fromHeight(
                                                                    height),
                                                            painter:
                                                                FrameSliderPainter(
                                                              _rect,
                                                              _getTrimPosition(),
                                                              _controller
                                                                  .trimStyle,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ])),
                                            );
                                          }),
                                        )
                                      : Container(
                                          height: 90,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: constantColors.navButton,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () async {
                        await DefaultCacheManager().emptyCache();
                        if (list.value.isNotEmpty) {
                          _exportingProgress.dispose();
                          _isExporting.dispose();

                          timer.cancel();
                          _controller.dispose();
                          for (ARList element in list.value) {
                            if (element.gifFilePath != null) {
                              await deleteFile([element.gifFilePath!]);
                            }
                            await deleteFile(element.pathsForVideoFrames!);
                            if (element.arState != null) {
                              element.arState!.dispose();
                              if (element.audioFlag == true)
                                element.audioPlayer!.dispose();
                            }
                          }
                          // for (ARList arVal in list.value) {
                          //   await deleteFile(arVal.pathsForVideoFrames!);
                          // }
                        }

                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.trashAlt,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () {
                        _controllerSeekTo(0);
                        if (selected != null) {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.warning,
                            title:
                                "Delete ${selected!.layerType == LayerType.Effect ? 'Effect' : 'AR'}?",
                            showCancelBtn: true,
                            onConfirmBtnTap: () async {
                              dev.log(
                                  "start indexcounter == ${indexCounter.value}");

                              final indexVal = list.value.indexWhere(
                                  (element) =>
                                      element.arIndex! == selected!.arIndex!);

                              dev.log(
                                  "selected arindex = ${selected!.arIndex} | || ar type == ${selected!.layerType} || index val; = $indexVal ");
                              // if (selected!.layerType == LayerType.AR) {
                              //   final indexVal = list.value.indexWhere(
                              //       (element) =>
                              //           element.arIndex! == selected!.arIndex!);

                              //   final int lastAtIndex = indexCounter.value;

                              //   for (int i = indexVal + 1;
                              //       i < lastAtIndex;
                              //       i++) {
                              //     // "list index $i goes from arIndex of ${list.value[i].arIndex} to ${list.value[i].arIndex! - 2}"
                              //     list.value[i].arIndex =
                              //         list.value[i].arIndex! - 2;
                              //   }
                              // } else {
                              // final indexVal = list.value.indexWhere(
                              //     (element) =>
                              //         element.arIndex! == selected!.arIndex!);

                              //   final int lastAtIndex = indexCounter.value;

                              //   for (int i = indexVal; i < lastAtIndex; i++) {
                              //     // "list index $i goes from arIndex of ${list.value[i].arIndex} to ${list.value[i].arIndex! - 1}"
                              //     list.value[i].arIndex =
                              //         list.value[i].arIndex! - 1;
                              //   }
                              // }

                              // await deleteFile(selected!.pathsForVideoFrames!);

                              // Future.delayed(Duration(seconds: 2));

                              for (final ARList element in list.value) {
                                if (selected!.arIndex! > element.arIndex!) {
                                  dev.log(
                                      "arIndex == ${element.arIndex!} || ar type == ${element.layerType} ignore this");
                                }

                                if (selected!.arIndex! < element.arIndex!) {
                                  switch (selected!.layerType!) {
                                    case LayerType.AR:
                                      dev.log(
                                          "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === move - 2 places (before moving)");
                                      element.arIndex = element.arIndex! - 2;
                                      dev.log(
                                          "arIndex == ${element.arIndex! - 2} || ar type == ${element.layerType} === moved (after moving)");

                                      break;
                                    case LayerType.Effect:
                                      dev.log(
                                          "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === move - 1 place (before moving)");
                                      element.arIndex = element.arIndex! - 1;
                                      dev.log(
                                          "arIndex == ${element.arIndex! - 1} || ar type == ${element.layerType} === moved (after moving)");

                                      break;
                                  }
                                }

                                if (selected!.arIndex! == element.arIndex) {
                                  dev.log(
                                      "arIndex == ${element.arIndex!} || ar type == ${element.layerType} === remove this");
                                  dev.log(
                                      "len before removing == ${list.value.length}");

                                  // list.value.remove(selected);
                                  dev.log(
                                      "len after removing == ${list.value.length - 1}");
                                }
                              }

                              switch (selected!.layerType!) {
                                case LayerType.AR:
                                  dev.log(
                                      "AR INDEX BEFORE = ${arIndexVal.value}");
                                  if (list.value.last == selected) {
                                    indexCounter.value = indexCounter.value - 1;
                                  } else {
                                    indexCounter.value = indexCounter.value - 2;
                                  }
                                  arIndexVal.value -= 1;
                                  dev.log(
                                      "AR INDEX NOW = ${arIndexVal.value} | indexCounter.value = ${indexCounter.value}");
                                  break;
                                case LayerType.Effect:
                                  dev.log(
                                      "EFFECT INDEX BEFORE = ${effectIndexVal.value}");
                                  if (list.value.first.layerType ==
                                          LayerType.AR &&
                                      list.value.last == selected &&
                                      list.value.length == 2) {
                                    indexCounter.value = indexCounter.value - 2;
                                  } else {
                                    indexCounter.value = indexCounter.value - 1;
                                  }
                                  effectIndexVal.value -= 1;
                                  await deleteFile(
                                      selected!.pathsForVideoFrames!);
                                  dev.log(
                                      "EFFECT INDEX NOW = ${effectIndexVal.value} | indexCounter.value = ${indexCounter.value}");
                                  break;
                              }

                              // setState(() {
                              // selected!.layerType == LayerType.AR
                              //     ? indexCounter.value =
                              //         indexCounter.value - 2
                              //     : indexCounter.value =
                              //         indexCounter.value - 1;

                              // _controllerSeekTo(0);
                              // });
                              list.value.remove(selected);
                              selected = null;
                              setState(() {});

                              dev.log(
                                  "end indexcounter == ${indexCounter.value}");

                              Navigator.pop(context);
                            },
                            onCancelBtnTap: () {
                              Navigator.pop(context);
                            },
                          );
                        } else {
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.info,
                            title: LocaleKeys.noarselected.tr(),
                            onConfirmBtnTap: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: list.value.isNotEmpty
                          ? () async {
                              await _controller.video.seekTo(Duration.zero);
                              await _controller.video.pause();
                              // ! for x = W - w (and the final bit for Ar position on screen)
                              double finalVideoContainerPointX =
                                  videoContainerKey
                                      .globalPaintBounds!.bottomRight.dx;
                              double finalVideoContainerPointY =
                                  videoContainerKey
                                      .globalPaintBounds!.bottomRight.dy;

                              // * to calculate videoContainer Height
                              double videoContainerHeight =
                                  videoContainerKey.globalPaintBounds!.height;

                              // * to calculate videoContainer Width
                              double videoContainerWidth =
                                  videoContainerKey.globalPaintBounds!.width;

                              // *ffmpeg list string
                              List<String> ffmpegInputList = [];
                              List<String> alphaTransparencyLayer = [];
                              List<String> ffmpegStartPointList = [];
                              List<String> ffmpegArFiltercomplex = [];
                              List<String> ffmpegOverlay = [];
                              List<String> ffmpegVolumeList = [];
                              List<String> ffmpegSoundInputs = [];
                              ValueNotifier<int> lastVal =
                                  ValueNotifier<int>(0);

                              for (ARList arElement in list.value) {
                                dev.log(
                                    "rotations for ${arElement.arId} = rot = ${arElement.rotation}");
                                double finalArContainerPointX = arElement
                                    .arKey!.globalPaintBounds!.bottomRight.dx;
                                double finalArContainerPointY = arElement
                                    .arKey!.globalPaintBounds!.bottomRight.dy;
                                // print(
                                //     "arIndexhere = ${arElement.arIndex} |finalVideoContainerPointX $finalVideoContainerPointX | finalVideoContainerPointY $finalVideoContainerPointY");
                                // print(
                                //     "arIndex = ${arElement.arIndex} |finalArContainerPointX $finalArContainerPointX | finalArContainerPointY $finalArContainerPointY");
                                // * move x pixels to the right (minus) / left (plus) from left border of video
                                double x = ((finalVideoContainerPointX -
                                        finalArContainerPointX) *
                                    (1080 / videoContainerWidth) *
                                    -1);
                                // print("ar ${arElement.arIndex} x = $x");
                                // * move y pixels to the top (minus) / bottom (plus) from bottom border of video
                                double y = ((finalVideoContainerPointY -
                                        finalArContainerPointY) *
                                    (1920 / videoContainerHeight) *
                                    -1);

                                //  videoContainerHeight (322.5) = 1920
                                // videoContainerWidth (177.375) = 1080
                                // (finalVideoContainerPointX - finalArContainerPointX) is x =

                                // ar start time
                                double arStartTime = (arElement
                                            .startingPositon! /
                                        _fullLayout.width) *
                                    _videoController.value.duration.inSeconds;

                                // ar end time
                                double arEndTime =
                                    (arElement.totalDuration!) + arStartTime;

                                // * to calculate arContainer Height & Width

                                double arScaleWidth =
                                    (arElement.width! * arElement.scale!)
                                        .floorToDouble();
                                double arScaleHeigth =
                                    (arElement.height! * arElement.scale!)
                                        .floorToDouble();

                                double arContainerHeight =
                                    arElement.arKey!.globalPaintBounds!.height;

                                double arScaleHeightVal = arContainerHeight *
                                    1920 /
                                    videoContainerHeight;

                                double arContainerWidth =
                                    arElement.arKey!.globalPaintBounds!.width;

                                double arScaleWidthVal = arContainerWidth *
                                    1080 /
                                    videoContainerWidth;
                                print("x = $x | y = $y");
                                print(
                                    "ar point x $finalArContainerPointX | screen height $videoContainerHeight");

                                if (arElement.layerType == LayerType.AR) {
                                  ffmpegInputList.add(
                                      " -i ${arElement.mainFile} -i ${arElement.alphaFile}");
                                } else {
                                  ffmpegInputList
                                      .add(" -i ${arElement.gifFilePath!}");
                                }

                                if (arElement.layerType == LayerType.AR) {
                                  alphaTransparencyLayer.add(
                                      "[${arElement.arIndex! + 1}][${arElement.arIndex}]scale2ref[mask][main];[main][mask]alphamerge[vid${arElement.arIndex}];");
                                }

                                if (arElement.layerType == LayerType.AR) {
                                  ffmpegStartPointList.add(
                                      "[vid${arElement.arIndex}]setpts=PTS-STARTPTS+${arStartTime.toStringAsFixed(0)}/TB[top${arElement.arIndex}];");
                                } else {
                                  ffmpegStartPointList.add(
                                      "[${arElement.arIndex}]setpts=PTS-STARTPTS+${arStartTime.toStringAsFixed(0)}/TB[top${arElement.arIndex}];");
                                }

                                ffmpegArFiltercomplex.add(
                                    "[top${arElement.arIndex}]rotate=${arElement.rotation! * 180 / pi}*PI/180:c=none:ow=rotw(${arElement.rotation! * 180 / pi}*PI/180):oh=roth(${arElement.rotation! * 180 / pi}*PI/180),scale=${arScaleWidthVal}:${arScaleHeightVal}:force_original_aspect_ratio=decrease[${arElement.arIndex}ol_vid];");

                                if (arElement.arIndex == 1) {
                                  ffmpegOverlay.add(
                                      "[bg_vid][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(0)}\"\\,\"${arEndTime.toStringAsFixed(0)}\")':eof_action=pass[${arElement.arIndex}out];");
                                  lastVal.value = arElement.arIndex!;
                                } else {
                                  ffmpegOverlay.add(
                                      "[${lastVal.value}out][${arElement.arIndex}ol_vid]overlay=x=(W-w)${x <= 0 ? "$x" : "+${x}"}:y=(H-h)${y <= 0 ? "$y" : "+${y}"}:enable='between(t\\,\"${arStartTime.toStringAsFixed(0)}\"\\,\"${arEndTime.toStringAsFixed(0)}\")':eof_action=pass[${arElement.arIndex}out];");
                                  lastVal.value = arElement.arIndex!;
                                }
                                if (arElement.layerType == LayerType.AR &&
                                    arElement.audioFlag == true) {
                                  ffmpegVolumeList.add(
                                      "[${arElement.arIndex}:a]volume=${arElement.audioPlayer!.volume},adelay=${arStartTime.toStringAsFixed(0)}s:all=1[a${arElement.arIndex}];");
                                  ffmpegSoundInputs
                                      .add("[a${arElement.arIndex}]");
                                }

                                if (arElement.finishedCaching!.value == true)
                                  arElement.arState!.skip(0);
                                arElement.arState!.pause();
                                if (arElement.audioFlag == true)
                                  arElement.audioPlayer!
                                      .seek(Duration(milliseconds: 0));
                                arElement.audioPlayer!.pause();

                                // print("arIndex = ${arElement.arIndex} | x = $x | y = $y");

                              }

                              // list.value.forEach((arElement) {
                              // });

                              String commandNoBgAudio =
                                  "${ffmpegInputList.join()} -t ${_videoController.value.duration} -filter_complex \"${alphaTransparencyLayer.join()}${ffmpegStartPointList.join()}[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];${ffmpegArFiltercomplex.join()}${ffmpegOverlay.join()}${ffmpegVolumeList.join()}${ffmpegSoundInputs.join()}${ffmpegSoundInputs.isEmpty ? '' : 'amix=inputs=${ffmpegSoundInputs.length + 1}[a]'}\" -map ''[${lastVal.value}out]'' ${ffmpegSoundInputs.isEmpty ? '' : '-map ' '[a]' ''} -y ";

                              String command =
                                  "${ffmpegInputList.join()} -t ${_videoController.value.duration} -filter_complex \"${alphaTransparencyLayer.join()}${ffmpegStartPointList.join()}[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];${ffmpegArFiltercomplex.join()}${ffmpegOverlay.join()}${ffmpegVolumeList.join()}[0:a]volume=${_controller.video.value.volume}[a0];[a0]${ffmpegSoundInputs.join()}amix=inputs=${ffmpegSoundInputs.length + 1}[a]\" -map ''[${lastVal.value}out]'' -map ''[a]'' -y ";

                              dev.log(arVideoCreation.getArAudioFlagGeneral == 1
                                  ? command
                                  : commandNoBgAudio);
                              // * for combining Ar with BG
                              // ignore: unawaited_futures
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.loading,
                                text: LocaleKeys.processingvideo.tr(),
                                barrierDismissible: false,
                              );
                              try {
                                await combineBgAr(
                                  bgVideoFile: context
                                      .read<VideoEditorProvider>()
                                      .getBackgroundVideoFile,
                                  ffmpegArCommand:
                                      arVideoCreation.getArAudioFlagGeneral == 1
                                          ? command
                                          : commandNoBgAudio,
                                  bgVideoDuartion:
                                      _videoController.value.duration,
                                  onProgress: (stats, value) =>
                                      _exportingProgress.value = value,
                                  onCompleted: (file) async {
                                    if (file != null) {
                                      dev.log("we're here now");

                                      await context
                                          .read<VideoEditorProvider>()
                                          .setAfterEditorVideoController(file);

                                      dev.log("Done!!!!!");

                                      await context
                                          .read<VideoEditorProvider>()
                                          .setBgMaterialThumnailFile();

                                      // context
                                      //     .read<VideoEditorProvider>()
                                      //     .setBackgroundVideoFile(file);

                                      dev.log("Send!");
                                      Get.back();
                                      await Get.to(
                                        () => VideothumbnailSelector(
                                          arList: list.value,
                                        ),
                                      );

                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     PageTransition(
                                      //         child: VideothumbnailSelector(
                                      //           arList: list.value,
                                      //           file: file,
                                      //           bgMaterialThumnailFile:
                                      //               bgMaterialThumnailFile,
                                      //         ),
                                      //         type: PageTransitionType.fade));

                                      dev.log("we're here?");
                                    } else {
                                      Navigator.pop(context);
                                      CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.error,
                                        title: LocaleKeys.errorprocessingvideo
                                            .tr(),
                                        text:
                                            "Device RAM issue. Main Please free up space on your phone to be able to process the video properly",
                                      );
                                      dev.log("hello ?? ");
                                    }

                                    setState(() => _exported = true);
                                    Future.delayed(
                                        const Duration(seconds: 2),
                                        () =>
                                            setState(() => _exported = false));
                                  },
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  title: "Error processing video",
                                  text: e.toString(),
                                );
                              }

                              // * for combining effect with BG
                              // await combineBgEffect(
                              //   bgVideoFile: widget.file,
                              //   effectFile: File(selectedFile!.path!),
                              //   arScaleWidth: "${arScaleWidthVal.floor()}",
                              //   arScaleHeight: "${arScaleHeightVal.floor()}",
                              //   arXCoordinate: x < 0 ? "-$x" : "+$x",
                              //   arYCoordinate: y < 0 ? "-$y" : "+$y",
                              //   arStartTime: arStartTime.toString(),
                              //   arEndTime: "${arEndTime + arStartTime}",
                              //   bgVideoDuartion: _videoController.value.duration,
                              //   onProgress: (stats, value) =>
                              //       _exportingProgress.value = value,
                              //   onCompleted: (file) async {
                              //     _isExporting.value = false;
                              //     if (!mounted) return;
                              //     if (file != null) {
                              //       final VideoPlayerController _videoController =
                              //           VideoPlayerController.file(file);

                              //       // ignore: unawaited_futures
                              //       _videoController.initialize().then((value) async {
                              //         setState(() {});

                              //         _videoController.setLooping(true);
                              //         await showDialog(
                              //           context: context,
                              //           builder: (_) => Padding(
                              //             padding: const EdgeInsets.all(30),
                              //             child: Container(
                              //               color: Colors.black,
                              //               child: Column(
                              //                 children: [
                              //                   Container(
                              //                     height: 50,
                              //                     color: Colors.white,
                              //                     child: Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment.center,
                              //                       children: [
                              //                         Text(
                              //                           "Preview",
                              //                           style: TextStyle(
                              //                             color: Colors.black,
                              //                             fontSize: 20,
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                   Container(
                              //                     height:
                              //                         MediaQuery.of(context).size.height *
                              //                             0.6,
                              //                     child: Center(
                              //                       child: GestureDetector(
                              //                         onTap: () {
                              //                           _videoController.value.isPlaying
                              //                               ? _videoController.pause()
                              //                               : _videoController.play();
                              //                         },
                              //                         child: AspectRatio(
                              //                           aspectRatio: _videoController
                              //                               .value.aspectRatio,
                              //                           child:
                              //                               VideoPlayer(_videoController),
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Container(
                              //                     color: Colors.white,
                              //                     child: Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment.spaceEvenly,
                              //                       children: [
                              //                         ElevatedButton(
                              //                           onPressed: () {
                              //                             Navigator.pop(context);
                              //                           },
                              //                           child: Text(
                              //                             "Cancel",
                              //                           ),
                              //                         ),
                              //                         ElevatedButton(
                              //                           onPressed: () {
                              //                             Navigator.push(
                              //                                 context,
                              //                                 PageTransition(
                              //                                     child: PreviewVideoScreen(
                              //                                         thumbnailFile:
                              //                                             thumbnailfile,
                              //                                         videoFile:
                              //                                             File(file.path),
                              //                                         videoPlayerController:
                              //                                             _videoController),
                              //                                     type: PageTransitionType
                              //                                         .fade));
                              //                           },
                              //                           child: Text(
                              //                             "Next",
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //         await _videoController.pause();
                              //         _videoController.dispose();
                              //       });

                              //       _exportText = "Video success export!";
                              //     } else {
                              //       _exportText = "Error on export video :(";
                              //     }

                              //     setState(() => _exported = true);
                              //     Future.delayed(const Duration(seconds: 2),
                              //         () => setState(() => _exported = false));
                              //   },
                              // );
                            }
                          : () {
                              Get.snackbar(
                                LocaleKeys.noareffectadded.tr(),
                                LocaleKeys.OneAROrOneEffect.tr(),
                                overlayColor: constantColors.navButton,
                                colorText: constantColors.whiteColor,
                                duration: Duration(seconds: 10),
                                snackPosition: SnackPosition.TOP,
                                forwardAnimationCurve: Curves.elasticInOut,
                                reverseAnimationCurve: Curves.easeOut,
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> combineBgAr({
    required File bgVideoFile,
    required String ffmpegArCommand,
    required Duration bgVideoDuartion,
    required void Function(File? file) onCompleted,
    void Function(Statistics, double)? onProgress,
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    final String tempPath = (await getApplicationDocumentsDirectory()).path;
    final String bgVideoPath = bgVideoFile.path;
    // final String arPath = arFile;

    final int epoch = DateTime.now().millisecondsSinceEpoch;
    final String outputPath = "$tempPath/output.mp4";
    final String thumbnailPath = "$tempPath/output.gif";

    print("path : $bgVideoPath");

    final String commandToExecute = "-v error -y -i ${bgVideoPath}" +
        ffmpegArCommand +
        " -crf ${Platform.isIOS ? '30' : '40'} -preset ultrafast ${outputPath}";

    print("command : $commandToExecute");

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        dev.log(' network connected');
        // PROGRESS CALLBACKS
        // PROGRESS CALLBACKS

        await FFmpegKit.execute(commandToExecute).then((value) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await value.getState());
          final code = await value.getReturnCode();
          final failStackTrace = await value.getFailStackTrace();

          debugPrint(
              "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");
          dev.log("code value == ${code!.isValueSuccess()}");

          if (code.isValueError()) {
            Navigator.pop(context);
            CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              title: LocaleKeys.errorprocessingvideo.tr(),
              text:
                  "Device RAM issue. FFMPEG Please free up space on your phone to be able to process the video properly",
            );
          }

          onCompleted(code.isValueSuccess() == true ? File(outputPath) : null);
        });
        // await FFmpegKit.executeAsync(
        //   commandToExecute,
        //   (session) async {
        //     final state =
        //         FFmpegKitConfig.sessionStateToString(await session.getState());
        //     final code = await session.getReturnCode();
        //     final failStackTrace = await session.getFailStackTrace();

        //     debugPrint(
        //         "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");

        //     if (code!.isValueError()) {
        //       Navigator.pop(context);
        //       CoolAlert.show(
        //         context: context,
        //         type: CoolAlertType.error,
        //         title: "Error Processing Video",
        //       );
        //     }

        //     onCompleted(
        //         code.isValueSuccess() == true ? File(outputPath) : null);
        //   },
        //   null,
        //   onProgress != null
        //       ? (stats) {
        //           // Progress value of encoded video
        //           double progressValue = stats.getTime() /
        //               (Duration.zero - bgVideoDuartion).inMilliseconds;
        //           onProgress(stats, progressValue.clamp(0.0, 1.0));
        //         }
        //       : null,
        // );
      }
    } on SocketException catch (_) {
      dev.log('network not connected');
      Navigator.pop(context);
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: LocaleKeys.errorprocessingvideo.tr(),
        text:
            "This is due to poor network  / wifi connection. Please ensure you have a strong stable connection and try again!",
      );
    }
  }

  // Future<void> combineBgEffect({
  //   required File bgVideoFile,
  //   required File effectFile,
  //   required String arScaleWidth,
  //   required String arScaleHeight,
  //   required String arXCoordinate,
  //   required String arYCoordinate,
  //   required String arStartTime,
  //   required String arEndTime,
  //   required Duration bgVideoDuartion,
  //   String? name,
  //   required void Function(File? file) onCompleted,
  //   void Function(Statistics, double)? onProgress,
  //   VideoExportPreset preset = VideoExportPreset.none,
  //   bool isFiltersEnabled = true,
  // }) async {
  //   _exportingProgress.value = 0;
  //   _isExporting.value = true;
  //   final String tempPath = (await getTemporaryDirectory()).path;
  //   final String bgVideoPath = bgVideoFile.path;
  //   final String arEffectPath = effectFile.path;
  //   name ??= path.basenameWithoutExtension(bgVideoPath);
  //   final int epoch = DateTime.now().millisecondsSinceEpoch;
  //   final String outputPath = "$tempPath/${name}_$epoch.mp4";
  //   final String thumbnailPath = "$tempPath/${name}_$epoch.gif";

  //   final String commandToExecute =
  //       "-v error -i ${bgVideoPath} -i ${arEffectPath} -t ${bgVideoDuartion.inSeconds} -filter_complex \"[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:-1:-1,setsar=1[bg_vid];[1:v]scale=${arScaleWidth}:$arScaleHeight:force_original_aspect_ratio=decrease[ol_vid];[bg_vid][ol_vid]overlay=x=W-w${arXCoordinate}:y=H-h${arYCoordinate}:enable='between(t,${arStartTime},${arEndTime})'\" ${outputPath}";

  //   // PROGRESS CALLBACKS
  //   await FFmpegKit.executeAsync(
  //     commandToExecute,
  //     (session) async {
  //       final state =
  //           FFmpegKitConfig.sessionStateToString(await session.getState());
  //       final code = await session.getReturnCode();
  //       final failStackTrace = await session.getFailStackTrace();

  //       await FFmpegKit.execute(
  //               "-y -i ${outputPath} -to 00:00:02 -vf scale=-2:480 -r 20/1 ${thumbnailPath}")
  //           .then((value) {
  //         setState(() {
  //           thumbnailfile = File(thumbnailPath);
  //         });
  //       });

  //       debugPrint(
  //           "FFmpeg process exited with state $state and return code $code.${(failStackTrace == null) ? "" : "\\n" + failStackTrace}");

  //       onCompleted(code?.isValueSuccess() == true ? File(outputPath) : null);
  //     },
  //     null,
  //     onProgress != null
  //         ? (stats) {
  //             // Progress value of encoded video
  //             double progressValue = stats.getTime() /
  //                 (Duration.zero - bgVideoDuartion).inMilliseconds;
  //             onProgress(stats, progressValue.clamp(0.0, 1.0));
  //           }
  //         : null,
  //   );
  // }

  showAlertDialog({required BuildContext context, required ARList ar}) {
    final point = ValueNotifier<double>(ar.audioPlayer!.volume);
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        print(point.value);
        await ar.audioPlayer!.setVolume(point.value);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        LocaleKeys.arvolume.tr(),
      ),
      content: Row(
        children: [
          Icon(Icons.volume_down),
          ValueListenableBuilder<double>(
            valueListenable: point,
            builder: (context, mark, _) {
              return CupertinoSlider(
                value: mark,
                min: 0,
                max: 1,
                onChanged: (double value) async {
                  point.value = value;
                  print(point.value);
                  await ar.audioPlayer!.setVolume(point.value);
                  // await ar.audioPlayer!.setVolume(value);
                },
              );
            },
          ),
          Icon(Icons.volume_up_rounded),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBgAlertDialog(
      {required BuildContext context,
      required VideoEditorController controller}) {
    final point = ValueNotifier<double>(controller.video.value.volume);
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        print(point.value);
        await controller.video.setVolume(point.value);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        LocaleKeys.bgvolume.tr(),
      ),
      content: Row(
        children: [
          Icon(Icons.volume_down),
          ValueListenableBuilder<double>(
            valueListenable: point,
            builder: (context, mark, _) {
              return CupertinoSlider(
                value: mark,
                min: 0,
                max: 1,
                onChanged: (double value) async {
                  point.value = value;
                  print(point.value);
                  await controller.video.setVolume(point.value);

                  // await ar.audioPlayer!.setVolume(value);
                },
              );
            },
          ),
          Icon(Icons.volume_up_rounded),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  PersistentBottomSheetController<dynamic> selectArBottomSheet(
      BuildContext context, Size size) {
    return showBottomSheet(
        context: context,
        builder: (context) {
          return ValueListenableBuilder<int>(
              valueListenable: arIndexVal,
              builder: (context, arIndex, _) {
                return Container(
                  height: size.height * 0.5,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.navButton,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 150),
                        child: Divider(
                          thickness: 4,
                          color: constantColors.whiteColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("users")
                                  // .doc("ijdI08UkGadVifmUcvS2KPjmuAE2")
                                  .doc(Provider.of<Authentication>(context,
                                          listen: false)
                                      .getUserId)
                                  .collection("MyCollection")
                                  .where("layerType", isEqualTo: "AR")
                                  .where("usage", isEqualTo: "Material")
                                  .orderBy("timestamp", descending: true)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.data!.docs.isEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No AR Materials have been created yet",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "To create your first Material AR:",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "AR Options > Select Video > Submit as Material",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var myArCollectionSnap =
                                        snapshot.data!.docs[index];
                                    MyArCollection myArCollection =
                                        MyArCollection.fromJson(
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>);

                                    return InkWell(
                                      onTap: () async {
                                        dev.log("arIndexVal = ${arIndex}");

                                        if (arIndexVal.value <= 2) {
                                          if (list.value.isNotEmpty) {
                                            list.value.last.layerType ==
                                                    LayerType.AR
                                                ? indexCounter.value =
                                                    indexCounter.value + 2
                                                : indexCounter.value =
                                                    indexCounter.value + 1;
                                          }

                                          if (indexCounter.value <= 0) {
                                            indexCounter.value = 1;
                                          }

                                          await runFFmpegCommand(
                                            arVal: indexCounter.value,
                                            myAr: myArCollection,
                                          );
                                        } else {
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.info,
                                            title: "Max AR's Reached",
                                            text: "You can only have 2 AR's",
                                          );
                                        }
                                      },
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: ImageNetworkLoader(
                                              imageUrl: myArCollection.gif),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  PersistentBottomSheetController<dynamic> selectEffectBottomSheet(
      {required BuildContext context,
      required Size size,
      required int effectValIndex,
      required int arValIndex}) {
    return showBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: size.height * 0.5,
            width: size.width,
            decoration: BoxDecoration(
              color: constantColors.navButton,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: InkWell(
                    onTap: _openFileManager,
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: constantColors.bioBg,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        LocaleKeys.selectneweffect.tr(),
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(Provider.of<Authentication>(context,
                                    listen: false)
                                .getUserId)
                            .collection("MyCollection")
                            .where("layerType", isEqualTo: "Effect")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Effects previously used",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "To use Effect, they must be saved on your phone in GIF Format",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: constantColors.whiteColor,
                                  ),
                                ),
                              ],
                            );
                          }

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var myArCollectionSnap =
                                  snapshot.data!.docs[index];

                              return InkWell(
                                onTap: () async {
                                  setState(() {
                                    effectIndexVal.value = list.value
                                        .where((element) =>
                                            element.layerType ==
                                            LayerType.Effect)
                                        .length;
                                  });
                                  if (effectIndexVal.value <= 2) {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.loading,
                                    );
                                    final http.Response responseData =
                                        await http.get(Uri.parse(
                                            "${myArCollectionSnap['gif']}"));
                                    var uint8list = responseData.bodyBytes;
                                    var buffer = uint8list.buffer;
                                    ByteData byteData = ByteData.view(buffer);
                                    var tempDir = await getTemporaryDirectory();
                                    File gifFileVal =
                                        await File('${tempDir.path}/img')
                                            .writeAsBytes(buffer.asUint8List(
                                                byteData.offsetInBytes,
                                                byteData.lengthInBytes));

                                    Navigator.pop(context);

                                    if (list.value.isNotEmpty) {
                                      list.value.last.layerType == LayerType.AR
                                          ? indexCounter.value =
                                              indexCounter.value + 2
                                          : indexCounter.value =
                                              indexCounter.value + 1;
                                    }

                                    await runGifFFmpegCommand(
                                      fromFirebase: true,
                                      arVal: indexCounter.value,
                                      gifFile: gifFileVal,
                                      arId: myArCollectionSnap['id'],
                                      ownerId: myArCollectionSnap['ownerId'],
                                      ownerName:
                                          myArCollectionSnap['ownerName'] ??
                                              Provider.of<FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .initUserName,
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.info,
                                      title: "Max Effects's Reached",
                                      text: "You can only have 2 Effect's",
                                    );
                                  }
                                },
                                child: Container(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ImageNetworkLoader(
                                          imageUrl:
                                              "${myArCollectionSnap['gif']}")),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
