import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({Key? key}) : super(key: key);
  ConstantColors _constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      appBar: AppBarWidget(text: LocaleKeys.favorites.tr(), context: context),
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(authentication.getUserId)
                .collection('favorites')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.docs.length > 0) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          try {
                            Video videoVal = await context
                                .read<FirebaseOperations>()
                                .getVideoPosts(
                                    videoId: snapshot.data!.docs[index]
                                        ["videoid"]);

                            videoVal.userimage =
                                snapshot.data!.docs[index]["userimage"];
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: PostDetailsScreen(
                                      video: videoVal,
                                    ),
                                    type: PageTransitionType.fade));
                          } catch (e) {
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              title: "Post No Longer Exists",
                              text: "This post has been removed by the creator",
                            );
                          }
                        },
                        title: Text(
                          snapshot.data!.docs[index]['videotitle'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(snapshot.data!.docs[index]['username']),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              snapshot.data!.docs[index]['thumbnailurl']),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      LocaleKeys.nofavorites.tr(),
                      style: TextStyle(
                          fontSize: 20, color: constantColors.mainColor),
                    ),
                  );
                }
              }
            }),
      ),
    );
  }
}
