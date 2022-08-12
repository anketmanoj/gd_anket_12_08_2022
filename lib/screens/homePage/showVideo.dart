import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreenWidget extends StatefulWidget {
  const VideoScreenWidget({
    Key? key,
    required this.video,
    required this.position,
  }) : super(key: key);

  final Video video;
  final int position;

  @override
  State<VideoScreenWidget> createState() => _VideoScreenWidgetState();
}

class _VideoScreenWidgetState extends State<VideoScreenWidget> {
  ConstantColors constantColors = ConstantColors();

  VideoPlayerController? _controller;

  // dispose the controller when the widget is disposed
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print("playing === ${widget.video.videourl}");
    _controller = VideoPlayerController.network(widget.video.videourl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller!.play();
        _controller!.setLooping(true);
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? GestureDetector(
            onTap: () {
              _controller!.value.isPlaying
                  ? _controller!.pause()
                  : _controller!.play();
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayer(
                  _controller!,
                ),
              ),
            ),
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
