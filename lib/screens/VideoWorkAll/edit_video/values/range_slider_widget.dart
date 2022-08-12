import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/values/tick_mark.dart';
import 'package:flutter/material.dart';

class RangeSliderWidget extends StatelessWidget {
  RangeSliderWidget({
    Key? key,
    this.values,
    this.onChanged,
    this.label,
    this.max = 30,
    this.min = 0,
    this.isSelected = false,
    this.primaryTickUnit = 10,
    this.subTickUnit = 2,
    this.hideTickMark = false,
    this.tickMarkColor,
    this.tickMarkTextColor,
    this.tickHeight = 1,
  }) : super(key: key);
  final RangeValues? values;
  final void Function(RangeValues value)? onChanged;
  final String? label;
  final double min;
  final double max;
  final bool isSelected;
  final int primaryTickUnit;
  final int subTickUnit;
  final bool hideTickMark;
  final Color? tickMarkColor;
  final Color? tickMarkTextColor;
  final double? tickHeight;

  @override
  Widget build(BuildContext context) {
    print("max = $max");
    return SliderTheme(
      data: SliderThemeData(
        overlayShape: SliderComponentShape.noThumb,
        rangeThumbShape: RangeThumbShapeCustom(thumbColor: AppColors.black),
        rangeTrackShape: GradientRangeTrackShapeCustom(
          max: max.toInt(),
          primaryTickUnit: primaryTickUnit,
          subTickUnit: subTickUnit,
          hideTickMark: hideTickMark,
          tickMarkColor: tickMarkColor,
          tickMarkTextColor: tickMarkTextColor,
          tickHeight: tickHeight,
        ),
      ).copyWith(
        trackHeight: 8,
      ),
      child: SizedBox(
        height: 30,
        child: RangeSlider(
          min: min,
          max: max,
          divisions: max.toInt(),
          labels:
              RangeLabels('${values?.start.toInt()}', '${values?.end.toInt()}'),
          inactiveColor: AppColors.dimGray01,
          onChanged: onChanged,
          values: values ?? RangeValues(0, 100),
        ),
      ),
    );
  }
}

class RangeThumbShapeCustom extends RangeSliderThumbShape {
  RangeThumbShapeCustom({this.thumbColor, Size? thumbSize})
      : this.thumbSize = thumbSize ?? const Size(6, 10);
  final Color? thumbColor;
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
                thumbPath = _rightTriangle(thumbSize.width, center);
                break;
              case Thumb.end:
                thumbPath = _leftTriangle(thumbSize.width, center);
                break;
            }
          }
          break;
        case TextDirection.ltr:
          if (thumb != null) {
            switch (thumb) {
              case Thumb.start:
                thumbPath = _leftTriangle(thumbSize.width, center);
                break;
              case Thumb.end:
                thumbPath = _rightTriangle(thumbSize.width, center);
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
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(30, 30);

  Path _rightTriangle(double size, Offset thumbCenter, {bool invert = false}) {
    final Path thumbPath = Path();
    final double halfSize = size;
    final double sign = invert ? -1.0 : 1.0;
    thumbPath
      ..moveTo(thumbCenter.dx + halfSize * sign, thumbCenter.dy)
      ..lineTo(thumbCenter.dx, thumbCenter.dy - size)
      ..lineTo(thumbCenter.dx, thumbCenter.dy + size)
      ..close();
    return thumbPath;
  }

  Path _leftTriangle(double size, Offset thumbCenter) =>
      _rightTriangle(size, thumbCenter, invert: true);
}

class GradientRangeTrackShapeCustom extends RangeSliderTrackShape {
  const GradientRangeTrackShapeCustom({
    this.gradient: AppColors.sliderGradient,
    this.hideTickMark: false,
    this.tickMarkColor,
    this.tickMarkTextColor,
    this.max: 100,
    this.primaryTickUnit: 20,
    this.subTickUnit: 5,
    this.tickHeight,
  });

  final Gradient gradient;
  final bool hideTickMark;
  final Color? tickMarkColor;
  final Color? tickMarkTextColor;
  final int max;
  final int primaryTickUnit;
  final int subTickUnit;
  final double? tickHeight;

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

    final activeRightTrackPaint = Paint()
      ..shader = gradient.createShader(trackRect);
    final inactiveTrackPaint = Paint()..color = sliderTheme.inactiveTrackColor!;
    final Radius trackRadius = Radius.circular(trackRect.height / 2);

    context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          trackRect.left - 10,
          trackRect.top,
          startThumbCenter.dx,
          trackRect.bottom,
          topLeft: trackRadius,
          bottomLeft: trackRadius,
        ),
        inactiveTrackPaint);
    context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          startThumbCenter.dx,
          trackRect.top,
          endThumbCenter.dx,
          trackRect.bottom,
        ),
        activeRightTrackPaint);
    context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          endThumbCenter.dx,
          trackRect.top,
          trackRect.right + 10,
          trackRect.bottom,
          topRight: trackRadius,
          bottomRight: trackRadius,
        ),
        inactiveTrackPaint);

    if (!hideTickMark) {
      DrawTickMark(context.canvas, trackRect, max, primaryTickUnit, subTickUnit,
          tickMarkColor: tickMarkColor,
          textColor: tickMarkTextColor,
          tickHeight: tickHeight);
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
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - (trackHeight ?? 0)) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight ?? 0);
  }
}
