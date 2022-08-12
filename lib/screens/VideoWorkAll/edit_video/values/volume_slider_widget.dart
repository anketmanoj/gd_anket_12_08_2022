import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:flutter/material.dart';

class VolumeSliderWidget extends StatelessWidget {
  VolumeSliderWidget({
    Key? key,
    this.volume = 0,
    required this.onChanged,
    this.thumbColor,
    this.borderColor,
    this.thumbSize,
    this.thumbBorder,
    this.gradient,
  }) : super(key: key);
  final double volume;
  final void Function(double volume) onChanged;
  final Color? thumbColor;
  final Color? borderColor;
  final double? thumbSize;
  final double? thumbBorder;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
              onTap: () => onChanged(0),
              child: RotatedBox(
                quarterTurns: 1,
                child: Icon(
                    volume > 0 ? Icons.volume_up_rounded : Icons.volume_off),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SliderTheme(
                data: SliderThemeData(
                  overlayShape: SliderComponentShape.noThumb,
                  thumbShape: ThumbShapeCustom(
                    thumbColor: thumbColor,
                    borderColor: borderColor,
                    thumbSize: thumbSize,
                    thumbBorder: thumbBorder,
                  ),
                  trackShape: GradientTrackShapeCustom(gradient: gradient),
                ).copyWith(
                  trackHeight: 6,
                ),
                child: Slider(
                    value: volume,
                    max: 1,
                    min: 0,
                    onChanged: onChanged,
                    inactiveColor: AppColors.dimGray01,
                    thumbColor: AppColors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThumbShapeCustom extends SliderComponentShape {
  ThumbShapeCustom({
    Color? thumbColor,
    Color? borderColor,
    double? thumbSize,
    double? thumbBorder,
  })  : this.thumbColor = thumbColor ?? const Color(0xFF9B38D9),
        this.borderColor = borderColor ?? const Color(0xFF8E8A8A),
        this.thumbSize = thumbSize ?? 7,
        this.thumbBorder = thumbBorder ?? 5;

  final Color thumbColor;
  final Color borderColor;
  final double thumbSize;
  final double thumbBorder;

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbBorder;
    canvas
      ..drawCircle(center, thumbSize, borderPaint)
      ..drawCircle(center, thumbSize, thumbPaint);
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(30, 30);
}

class GradientTrackShapeCustom extends SliderTrackShape {
  const GradientTrackShapeCustom({
    Gradient? gradient,
  }) : this.gradient = gradient ?? AppColors.sliderGradient;

  final Gradient gradient;

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

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
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
          offset.dx,
          trackRect.top,
          thumbCenter.dx,
          trackRect.bottom,
          topLeft: trackRadius,
          bottomLeft: trackRadius,
        ),
        activeRightTrackPaint);
    context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          thumbCenter.dx,
          trackRect.top,
          trackRect.right,
          trackRect.bottom,
          topRight: trackRadius,
          bottomRight: trackRadius,
        ),
        inactiveTrackPaint);
  }
}
