import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionsToolbarCreateVideo extends StatelessWidget {
  const ActionsToolbarCreateVideo({Key? key, required this.controller})
      : super(key: key);
  final CreateVideoVideoModel controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/svg/ic_save.svg",
          ),
          onPressed: controller.onDone,
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/svg/ic_undo.svg",
          ),
          onPressed: () {
            if (controller.canUndo) {
              controller.onUndo();
            }
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/svg/ic_layer_list.svg",
          ),
          onPressed: controller.panelController.value.open,
        ),
      ]),
    );
  }
}
