import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

final videoStreamController = PublishSubject<VideoAction>();
enum VideoAction { play, pause, stop }

class LayerVideoWidget extends StatefulWidget {
  const LayerVideoWidget({
    Key? key,
    required this.url,
    this.isLocal = false,
    this.autoPlay = false,
    this.mixWithOthers = false,
    this.loadingWidget,
  }) : super(key: key);

  final String url;
  final bool isLocal;
  final bool autoPlay;
  final bool mixWithOthers;
  final Widget? loadingWidget;

  @override
  _LayerVideoWidgetState createState() => _LayerVideoWidgetState();
}

class _LayerVideoWidgetState extends State<LayerVideoWidget> {
  String url = '';
  VideoPlayerController? _videoPlayerController;
  late StreamSubscription<VideoAction>? _streamSubscription;

  Future<void> _initializePlayer() async {
    url = widget.url;
    _videoPlayerController = VideoPlayerController.network(url,
        videoPlayerOptions:
            VideoPlayerOptions(mixWithOthers: widget.mixWithOthers));
    setState(() {});
  }

  void _videoStreamListen() {
    _streamSubscription = videoStreamController.stream.listen((action) {
      print('Video playing is: $action');
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized) {
        if (action == VideoAction.stop) {
          _videoPlayerController!
            ..pause()
            ..seekTo(Duration.zero);
        } else if (action == VideoAction.play) {
          _videoPlayerController?.play();
        } else {
          _videoPlayerController?.pause();
        }
      }
    });
  }

  @override
  void initState() {
    _initializePlayer();
    _videoStreamListen();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LayerVideoWidget oldWidget) {
    if (url != widget.url &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _videoPlayerController!.dispose();
      _initializePlayer();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized
        ? FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
                width: _videoPlayerController?.value.size.width,
                height: _videoPlayerController?.value.size.height,
                child: VideoPlayer(_videoPlayerController!)),
          )
        : widget.loadingWidget ?? SizedBox.shrink();
  }

  @override
  void dispose() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _videoPlayerController?.dispose();
    }
    _streamSubscription?.cancel();
    super.dispose();
  }
}
