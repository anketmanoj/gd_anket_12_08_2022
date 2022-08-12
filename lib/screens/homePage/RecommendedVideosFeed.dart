import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/screens/homePage/video_post_item.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecommendedVideosFeed extends StatelessWidget {
  const RecommendedVideosFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeScreenProvider homeScreenProvider =
        Provider.of<HomeScreenProvider>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .orderBy("timestamp", descending: true)
          .where("ispaid", isEqualTo: false)
          .snapshots(),
      builder: (context, videoList) {
        if (videoList.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (videoList.hasError) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Text(
                "Error Loading Posts, please naviagte out of this screen and come back",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        if (videoList.data!.docs.length != 0) {
          return Container(
              child: PageView.builder(
            itemCount: videoList.data!.docs.length,
            // preloadPagesCount: 2,
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            itemBuilder: (BuildContext context, int position) {
              final video = Video.fromJson(videoList.data!.docs[position]
                  .data()! as Map<String, dynamic>);

              return homeScreenProvider.isHomeScreen
                  ? Stack(
                      children: [
                        Container(
                          height: size.height,
                          width: size.width,
                          color: Colors.black,
                          child: VideoPostItem(
                            video: video,
                          ),
                        ),
                      ],
                    )
                  : Container();
            },
            // controller: PreloadPageController(initialPage: 1),
            onPageChanged: (int position) {},
          ));
        }

        return Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Text(
              "No Posts in Recommended Tab",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
