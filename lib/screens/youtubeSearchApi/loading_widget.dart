import 'dart:ffi';

import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

Widget loadingWidget(BuildContext context, {double size: 150}) {
  return LoadingAnimationWidget.staggeredDotsWave(
      color: constantColors.navButton, size: size);
}
