import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:flutter/material.dart';

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  Text build(BuildContext context) {
    final Duration clockTimer = Duration(seconds: animation.value);
    final minute = clockTimer.inMinutes.remainder(60).toString();
    final second =
        (clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0');
    final String timerText = '$minute:$second';

    return Text(
      "$timerText",
      style: TextStyle(color: AppColors.white),
    );
  }
}
