import 'package:flutter/material.dart';

void DrawTickMark(
  Canvas canvas,
  Rect trackRect,
  int max,
  int primaryTickUnit,
  int subTickUnit, {
  double? tickHeight,
  Color? tickMarkColor,
  Color? textColor,
}) {
  final textStyle = TextStyle(
    color: textColor ?? tickMarkColor ?? Colors.black,
    fontSize: 12,
  );

  final center = trackRect.center.dy;
  final unitTickWith = trackRect.width * subTickUnit / max;
  var tickCurrent = 0;
  double tickStart = 0;

  for (var i = 0; i <= max; i += subTickUnit) {
    var height = tickHeight ?? 2;
    if (i == 0 || i == max || i == tickCurrent) {
      final textSpan = TextSpan(
        text: '$tickCurrent',
        style: textStyle,
      );
      final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(minWidth: 0, maxWidth: 60);
      final offset = Offset(tickStart - textPainter.width * 0.5, center - 20);
      textPainter.paint(canvas, offset);
      tickCurrent += primaryTickUnit;
      height *= 3;
    }
    canvas.drawPath(_tickPath(Size(1, height), Offset(tickStart, center)),
        Paint()..color = tickMarkColor ?? Colors.black38);
    tickStart += unitTickWith;
  }
}

Path _tickPath(Size size, Offset thumbCenter) {
  final Path thumbPath = Path()
    ..moveTo(thumbCenter.dx + size.width, thumbCenter.dy + size.height)
    ..lineTo(thumbCenter.dx - size.width, thumbCenter.dy - size.height)
    ..lineTo(thumbCenter.dx - size.width, thumbCenter.dy + size.height)
    ..moveTo(thumbCenter.dx - size.width, thumbCenter.dy - size.height)
    ..lineTo(thumbCenter.dx + size.width, thumbCenter.dy + size.height)
    ..lineTo(thumbCenter.dx + size.width, thumbCenter.dy - size.height)
    ..close();
  return thumbPath;
}
