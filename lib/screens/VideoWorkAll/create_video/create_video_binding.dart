// Package imports:
import 'package:diamon_rose_app/screens/VideoWorkAll/create_video/create_video_view_model.dart';
import 'package:get/get.dart';

// Project imports:

class CreateVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateVideoVideoModel());
  }
}
