import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_binding.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_screen.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_binding.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_screen.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/edit_video_binding.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/edit_video/edit_video_screen.dart';
import 'package:get/get.dart';

class Routers {
  static final route = [
    GetPage(
        transitionDuration: Duration(milliseconds: 300),
        transition: Transition.rightToLeft,
        name: ROUTER_CREATE_VIDEO,
        page: () => CreateVideoView(),
        binding: CreateVideoBinding()),
    GetPage(
        transitionDuration: Duration(milliseconds: 300),
        transition: Transition.rightToLeft,
        name: ROUTER_CREATE_VIDEO_CAMERA,
        page: () => ArRecordScreen(),
        binding: ArRecordBinding()),
    GetPage(
        transitionDuration: Duration(milliseconds: 300),
        transition: Transition.rightToLeft,
        name: ROUTER_EDIT_VIDEO,
        page: () => EditVideoScreen(),
        binding: EditVideoBinding()),
  ];
}
