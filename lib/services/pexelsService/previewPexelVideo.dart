import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/InitVideoEditorScreen.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;

class PreviewPexelVideoScreen extends StatefulWidget {
  const PreviewPexelVideoScreen({Key? key, required this.pexelVideoUrl})
      : super(key: key);
  final String pexelVideoUrl;

  @override
  State<PreviewPexelVideoScreen> createState() =>
      _PreviewPexelVideoScreenState();
}

class _PreviewPexelVideoScreenState extends State<PreviewPexelVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.pexelVideoUrl);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<int> audioCheck(
      {required String videoUrl, required BuildContext context}) async {
    context.read<ArVideoCreation>().setFromPexel(true);
    context.read<VideoEditorProvider>().setBackgroundVideoId(null);
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
    final String imageName = "videoFilePexel.mp4";

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, imageName));
    file.writeAsBytesSync(res.data as List<int>);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar:
          AppBarWidget(text: "Preview Pexel Video", context: context, actions: [
        IconButton(
          onPressed: () async {
            _controller.pause();
            CoolAlert.show(
                context: context,
                type: CoolAlertType.loading,
                barrierDismissible: false);
            final int audioFlag = await audioCheck(
                videoUrl: widget.pexelVideoUrl, context: context);

            switch (audioFlag) {
              case 1:
                await getImage(url: widget.pexelVideoUrl).then((value) {
                  context
                      .read<VideoEditorProvider>()
                      .setBackgroundVideoFile(File(value.path));

                  context
                      .read<VideoEditorProvider>()
                      .setBackgroundVideoController();
                });

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            InitVideoEditorScreen()));

                break;
              default:
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.info,
                  title: LocaleKeys.videocontainsnoaudio.tr(),
                  text: LocaleKeys.onlyVideoWithAudioSupported.tr(),
                );
            }
          },
          icon: Icon(
            Icons.arrow_forward,
          ),
        ),
      ]),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(_controller),
              ClosedCaption(text: _controller.value.caption.text),
              _ControlsOverlay(controller: _controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

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
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
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
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
      ],
    );
  }
}
