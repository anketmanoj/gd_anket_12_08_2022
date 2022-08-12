import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTest extends StatefulWidget {
  const VideoTest({Key? key, required this.videoFile}) : super(key: key);

  final File videoFile;
  @override
  _VideoTestState createState() => _VideoTestState();
}

class _VideoTestState extends State<VideoTest> {
  late VideoPlayerController controller;

  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  loadVideoPlayer() {
    controller = VideoPlayerController.file(widget.videoFile);
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Video Player in Flutter"),
        backgroundColor: Colors.redAccent,
      ),
      body: controller.value.isInitialized
          ? Column(children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              Container(
                //duration of video
                child: Text(
                    "Total Duration: " + controller.value.duration.toString()),
              ),
              Container(
                  child: VideoProgressIndicator(controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        backgroundColor: Colors.redAccent,
                        playedColor: Colors.green,
                        bufferedColor: Colors.purple,
                      ))),
              Container(
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }

                          setState(() {});
                        },
                        icon: Icon(controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow)),
                    IconButton(
                        onPressed: () {
                          controller.seekTo(Duration(seconds: 0));

                          setState(() {});
                        },
                        icon: Icon(Icons.stop))
                  ],
                ),
              )
            ])
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
