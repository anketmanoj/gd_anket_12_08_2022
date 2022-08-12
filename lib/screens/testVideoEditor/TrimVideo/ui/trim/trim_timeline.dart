import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/video_editor.dart';
import 'package:flutter/material.dart';

class TrimTimeline extends StatefulWidget {
  /// Show the timeline corresponding to the [TrimSlider]
  const TrimTimeline({
    Key? key,
    required this.controller,
    this.secondGap = 5,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// The [controller] param is mandatory so depending on the [controller.maxDuration], the generated timeline will be different
  final VideoEditorController controller;

  /// The [secondGap] param specifies time gap in second between every points of the timeline
  /// The default value of this property is 5 seconds
  final double secondGap;

  /// The [margin] param specifies the space surrounding the timeline
  final EdgeInsets margin;

  @override
  _TrimTimelineState createState() => _TrimTimelineState();
}

class _TrimTimelineState extends State<TrimTimeline> {
  int _timeGap = 0;

  @override
  void initState() {
    final Duration _duration = widget.controller.maxDuration;
    _timeGap = (_duration.inSeconds / (widget.secondGap + 1)).ceil();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.margin,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0;
                  i <=
                      (widget.controller.videoDuration.inSeconds / _timeGap)
                          .ceil();
                  i++)
                Text(
                  "${(i * _timeGap <= widget.controller.videoDuration.inSeconds ? i * _timeGap : '').toString()}s",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
            ]));
  }
}
