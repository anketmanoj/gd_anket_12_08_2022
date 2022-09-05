import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/Effect_BG_Model.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  PurchaseHistoryScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();

  void runARCommand(
      {required MyArCollection myAr, required BuildContext context}) {
    final String audioFile = myAr.audioFile;

    // ignore: cascade_invocations
    final String folderName = audioFile.split(myAr.id).toList()[0];
    final String fileName = "${myAr.id}imgSeq";

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageSeqAniScreen(
          folderName: folderName,
          fileName: fileName,
          MyAR: myAr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Diamond Histroy", context: context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .collection("MyCollection")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snaps) {
          if (snaps.hasError) {
            return Center(
              child: Text("No Diamond History"),
            );
          }

          if (snaps.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snaps.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if ((snaps.data!.docs[index].data() as Map<String, dynamic>)
                      .containsKey("ispaid") &&
                  (snaps.data!.docs[index].data() as Map<String, dynamic>)
                      .containsKey("videoType")) {
                Video video = Video.fromJson(
                    snaps.data!.docs[index].data() as Map<String, dynamic>);

                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: PostDetailsScreen(
                              videoId: video.id,
                            ),
                            type: PageTransitionType.fade));
                  },
                  leading: Container(
                    height: 50,
                    width: 50,
                    child: ImageNetworkLoader(imageUrl: video.thumbnailurl),
                  ),
                  title: Text(video.videotitle),
                  subtitle: Text(video.username),
                  trailing: video.isFree
                      ? Text("Free")
                      : Text(
                          "\$${(video.price * (1 - video.discountAmount / 100)).toStringAsFixed(2)}"),
                );
              } else {
                if (!(snaps.data!.docs[index].data() as Map<String, dynamic>)
                    .containsKey("usage")) {
                  return Container();
                }
                if (snaps.data!.docs[index]['usage'] == "Material") {
                  switch (
                      (snaps.data!.docs[index].data() as Map<String, dynamic>)
                          .containsKey("alpha")) {
                    case true:
                      MyArCollection myArCollection = MyArCollection.fromJson(
                          snaps.data!.docs[index].data()
                              as Map<String, dynamic>);
                      switch (myArCollection.ownerId ==
                          context.read<Authentication>().getUserId) {
                        case false:
                          return ListTile(
                            onTap: () => runARCommand(
                                context: context, myAr: myArCollection),
                            title: Text(myArCollection.ownerName),
                            leading: Container(
                              height: 50,
                              width: 50,
                              child: ImageNetworkLoader(
                                  imageUrl: myArCollection.gif),
                            ),
                            subtitle: Text(myArCollection.usage!),
                          );

                        default:
                          return Container();
                      }

                    case false:
                      switch ((snaps.data!.docs[index].data()
                              as Map<String, dynamic>)
                          .containsKey("layerType")) {
                        case false:
                          return Container();

                        default:
                          switch (snaps.data!.docs[index]['layerType']) {
                            case "Background":
                              return Container();
                            default:
                              EffectModel effectModel = EffectModel.fromMap(
                                  snaps.data!.docs[index].data()
                                      as Map<String, dynamic>);
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        child: ArViewerPage(
                                          gifUrl: effectModel.gif,
                                        ),
                                        type: PageTransitionType.rightToLeft),
                                  );
                                },
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: ImageNetworkLoader(
                                      imageUrl: effectModel.gif),
                                ),
                                title: Text(effectModel.owner ??
                                    effectModel.layerType!),
                                subtitle: Text(effectModel.usage),
                              );
                          }
                      }

                    default:
                      return ListTile(
                        title: Text("Material"),
                      );
                  }
                } else {
                  switch (snaps.data!.docs[index]['main'].toString()) {
                    case "null":
                      return Container();

                    default:
                      MyArCollection myArCollection = MyArCollection.fromJson(
                          snaps.data!.docs[index].data()
                              as Map<String, dynamic>);
                      switch (myArCollection.usage) {
                        case "Pending":
                          return Container();

                        default:
                          switch (myArCollection.ownerId ==
                              context.read<Authentication>().getUserId) {
                            case false:
                              return ListTile(
                                onTap: () => runARCommand(
                                    context: context, myAr: myArCollection),
                                title: Text(myArCollection.ownerName),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: ImageNetworkLoader(
                                      imageUrl: myArCollection.gif),
                                ),
                                subtitle: Text(myArCollection.usage!),
                              );

                            default:
                              return Container();
                          }
                      }
                  }
                  // return Container();

                }
              }
            },
          );
        },
      ),
    );
  }
}
