import 'package:get/get.dart' hide Trans;

class GlobalMessagesController extends GetxController {
  RxMap<String, String> messageToShow = RxMap<String, String>();

  void displayNewMessage(Map<String, String> messageData) {
    messageToShow.value = messageData;
  }
}
