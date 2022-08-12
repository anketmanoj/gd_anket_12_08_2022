import 'package:chewie/chewie.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideoViewer extends StatefulWidget {
  const BackgroundVideoViewer({Key? key, required this.videoUrl})
      : super(key: key);
  final String videoUrl;

  @override
  State<BackgroundVideoViewer> createState() => _BackgroundVideoViewerState();
}

class _BackgroundVideoViewerState extends State<BackgroundVideoViewer> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  final ConstantColors constantColors = ConstantColors();

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 2160 / 3840,
      autoInitialize: true,
      showControls: false,
      autoPlay: true,
      looping: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Scaffold(
        backgroundColor: constantColors.black,
        body: Stack(
          children: [
            InkWell(
              onTap: () {
                _chewieController.videoPlayerController.value.isPlaying
                    ? _chewieController.pause()
                    : _chewieController.play();
              },
              child: Container(
                child: Chewie(controller: _chewieController),
              ),
            ),
            Positioned(
              top: 10,
              left: 15,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: constantColors.whiteColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
