import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_view_model.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/value/layer_bottom_sheet_tab_bar.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/value/layer_bottom_sheet_tab_view.dart';
import 'package:flutter/material.dart';

class BottomBarCreateVideo extends StatelessWidget {
  const BottomBarCreateVideo({Key? key, required this.controller})
      : super(key: key);
  final CreateVideoVideoModel controller;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: DefaultTabController(
          length: 3,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            LayerBottomSheetTabBar(controller),
            LayerBottomSheetTabView(controller),
          ]),
        ),
      );
    });
  }
}
