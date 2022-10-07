import 'package:diamon_rose_app/screens/VideoWorkAll/select_model/select_model_view_model.dart';
import 'package:get/get.dart' hide Trans;

class SelectModelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SelectModelPresenter());
  }
}
