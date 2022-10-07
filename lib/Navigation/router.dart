import 'package:diamon_rose_app/Navigation/page.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_binding.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_screen.dart';

import 'package:get/get.dart' hide Trans;

class Routers {
  static final route = [
    GetPage(
        transitionDuration: Duration(milliseconds: 300),
        transition: Transition.rightToLeft,
        name: ROUTER_CREATE_VIDEO_CAMERA,
        page: () => ArRecordScreen(),
        binding: ArRecordBinding()),
  ];
}
