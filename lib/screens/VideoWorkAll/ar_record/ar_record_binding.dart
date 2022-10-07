import 'package:diamon_rose_app/screens/VideoWorkAll/ar_record/ar_record_view_model.dart';
import 'package:get/get.dart' hide Trans;

class ArRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArRecordViewModel());
  }
}
