import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_video_page.dart';
import 'package:diamon_rose_app/screens/homePage/video_post_item.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowingVideosFeed extends StatelessWidget {
  const FollowingVideosFeed({Key? key, required this.recommendedProvider})
      : super(key: key);
  final RecommendedProvider recommendedProvider;

  @override
  Widget build(BuildContext context) {
    final HomeScreenProvider homeScreenProvider =
        Provider.of<HomeScreenProvider>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    switch (recommendedProvider.noFollowers) {
      case true:
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Text(
              "You dont follow anyone yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      case false:
        return FollowingVideoPage();
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
