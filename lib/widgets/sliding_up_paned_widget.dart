import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingUpPanelWidget extends StatelessWidget {
  SlidingUpPanelWidget({
    Key? key,
    required this.body,
    required this.bottomSheet,
    this.showDragPoint = false,
    this.backdropEnabled = true,
    this.backdropOpacity = 0.5,
    this.minHeight = 30,
    this.radius = 20,
    this.padding,
    this.height,
    this.background = Colors.transparent,
    this.controller,
    this.onPanelOpened,
    this.onPanelClosed,
    this.onPanelSlide,
  }) : super(key: key);

  final Widget body;
  final Widget bottomSheet;
  final bool showDragPoint;
  final bool backdropEnabled;
  final double backdropOpacity;
  final double minHeight;
  final double? height;
  final double radius;
  final EdgeInsets? padding;
  final Color background;
  final PanelController? controller;
  final Future<void> Function()? onPanelOpened;
  final Future<void> Function()? onPanelClosed;
  final void Function(double)? onPanelSlide;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      backdropEnabled: backdropEnabled,
      backdropOpacity: backdropOpacity,
      minHeight: minHeight,
      color: background,
      boxShadow: [BoxShadow(color: Colors.transparent)],
      backdropColor: AppColors.black,
      maxHeight: (height ?? MediaQuery.of(context).size.height) + minHeight,
      controller: controller,
      parallaxEnabled: false,
      panel: Container(
        margin: EdgeInsets.only(top: showDragPoint ? 0 : minHeight),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          color: AppColors.bottomSheetColor.withOpacity(0.5),
        ),
        child: bottomSheet,
      ),
      body: body,
      onPanelOpened: onPanelOpened,
      onPanelClosed: onPanelClosed,
      onPanelSlide: onPanelSlide,
    );
  }
}
