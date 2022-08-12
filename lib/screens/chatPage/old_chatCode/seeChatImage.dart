import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SeeChatImage extends StatelessWidget {
  const SeeChatImage({Key? key, required this.chatImageUrl}) : super(key: key);

  final chatImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(chatImageUrl),
        ),
      ),
    );
  }
}
