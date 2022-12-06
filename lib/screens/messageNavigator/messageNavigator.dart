import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class FCMNotificationNavigator extends StatefulWidget {
  const FCMNotificationNavigator({required this.videoId});
  final String videoId;

  @override
  State<FCMNotificationNavigator> createState() =>
      _FCMNotificationNavigatorState();
}

class _FCMNotificationNavigatorState extends State<FCMNotificationNavigator> {
  Future goToPost() async {
    Video videoVal = await context
        .read<FirebaseOperations>()
        .getVideoPosts(videoId: widget.videoId);
    Navigator.pushReplacement(
        context,
        PageTransition(
            child: PostDetailsScreen(
              video: videoVal,
            ),
            type: PageTransitionType.fade));
  }

  @override
  void initState() {
    goToPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
