import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/tick_mark.dart';
import 'package:flutter/material.dart';

class VideoRangeSliderWidget extends StatelessWidget {
  VideoRangeSliderWidget({
    Key? key,
    this.values,
    this.onChanged,
    this.label,
    this.max = 100,
    this.min = 0,
    this.primaryTickUnit = 10,
    this.subTickUnit = 2,
    this.hideTickMark = false,
    this.tickMarkColor,
    this.tickMarkTextColor,
  }) : super(key: key);
  final RangeValues? values;
  final void Function(RangeValues value)? onChanged;
  final String? label;
  final double min;
  final double max;
  final int primaryTickUnit;
  final int subTickUnit;
  final bool hideTickMark;
  final Color? tickMarkColor;
  final Color? tickMarkTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
            child: Text(
              label ?? '',
              style: AppStyles.typeTextNormal(color: AppColors.white),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              rangeThumbShape:
                  RangeThumbShapeCustom(thumbColor: AppColors.black),
              rangeTrackShape: GradientRangeTrackShapeCustom(
                max: max.toInt(),
                primaryTickUnit: primaryTickUnit,
                subTickUnit: subTickUnit,
                hideTickMark: hideTickMark,
                tickMarkColor: tickMarkColor,
                tickMarkTextColor: tickMarkTextColor,
              ),
            ).copyWith(
              trackHeight: 20,
            ),
            child: SizedBox(
              height: 40,
              child: RangeSlider(
                min: min,
                max: max,
                divisions: max.toInt(),
                labels: RangeLabels(
                    '${values?.start.toInt()}', '${values?.end.toInt()}'),
                onChanged: onChanged,
                values: values ?? RangeValues(0, 100),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RangeThumbShapeCustom extends RangeSliderThumbShape {
  RangeThumbShapeCustom({this.thumbColor, this.height = 10, Size? thumbSize})
      : this.thumbSize = thumbSize ?? const Size(8, 20);
  final Color? thumbColor;
  final double? height;
  final Size thumbSize;

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      bool isDiscrete = false,
      bool isEnabled = false,
      bool? isOnTop,
      TextDirection? textDirection,
      required SliderThemeData sliderTheme,
      Thumb? thumb,
      bool? isPressed}) {
    final Canvas canvas = context.canvas;

    Path thumbPath = Path();
    if (textDirection != null) {
      switch (textDirection) {
        case TextDirection.rtl:
          if (thumb != null) {
            switch (thumb) {
              case Thumb.start:
                thumbPath = _rightTriangle(thumbSize, center);
                break;
              case Thumb.end:
                thumbPath = _leftTriangle(thumbSize, center);
                break;
            }
          }
          break;
        case TextDirection.ltr:
          if (thumb != null) {
            switch (thumb) {
              case Thumb.start:
                thumbPath = _leftTriangle(thumbSize, center);
                break;
              case Thumb.end:
                thumbPath = _rightTriangle(thumbSize, center);
                break;
            }
          }
          break;
      }
      canvas.drawPath(
          thumbPath,
          Paint()
            ..color = thumbColor ?? sliderTheme.thumbColor ?? AppColors.black);
    }
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(30, 50);

  Path _rightTriangle(Size size, Offset thumbCenter, {bool invert = false}) {
    final Path thumbPath = Path()
      ..moveTo(thumbCenter.dx + size.width, thumbCenter.dy + size.height)
      ..lineTo(thumbCenter.dx - size.width, thumbCenter.dy + size.height)
      ..lineTo(thumbCenter.dx, thumbCenter.dy)
      ..close();
    return thumbPath;
  }

  Path _leftTriangle(Size size, Offset thumbCenter) =>
      _rightTriangle(size, thumbCenter, invert: true);
}

class GradientRangeTrackShapeCustom extends RangeSliderTrackShape {
  const GradientRangeTrackShapeCustom({
    this.background: const Color(0xA155BEC2),
    this.hideTickMark: false,
    this.tickMarkColor,
    this.tickMarkTextColor,
    this.max: 100,
    this.primaryTickUnit: 20,
    this.subTickUnit: 5,
  });

  final Color background;
  final bool hideTickMark;
  final Color? tickMarkColor;
  final Color? tickMarkTextColor;
  final int max;
  final int primaryTickUnit;
  final int subTickUnit;

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset startThumbCenter,
      required Offset endThumbCenter,
      bool isEnabled = false,
      bool isDiscrete = false,
      required TextDirection textDirection}) {
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }
    final Rect trackRect = getPreferredRect(
        parentBox: parentBox,
        offset: offset,
        sliderTheme: sliderTheme,
        isEnabled: isEnabled,
        isDiscrete: isDiscrete);

    context.canvas.drawRect(
        Offset(trackRect.left - 10, trackRect.top) &
            Size(trackRect.width + 20, trackRect.height),
        Paint()..color = background);

    if (!hideTickMark) {
      DrawTickMark(
        context.canvas,
        trackRect,
        max,
        primaryTickUnit,
        subTickUnit,
        tickMarkColor: tickMarkColor,
        textColor: tickMarkTextColor,
      );
    }
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool? isEnabled,
    bool? isDiscrete,
  }) {
    final double trackHeight = parentBox.size.height;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
