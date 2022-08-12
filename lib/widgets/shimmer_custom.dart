import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCustom extends StatelessWidget {
  ShimmerCustom(
      {Key? key,
      required this.child,
      this.time = 1000,
      this.highlightColor,
      this.baseColor})
      : super(key: key);

  final int time;
  final Widget child;
  final Color? highlightColor;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        highlightColor: highlightColor ?? AppColors.white,
        baseColor: baseColor ?? AppColors.dimGray02,
        period: Duration(milliseconds: time),
        child: child);
  }
}
