import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/ShareWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Custom Feed Widget consisting video
class VideoWidget extends StatelessWidget {
  const VideoWidget({
    Key? key,
    required this.isLoading,
    required this.controller,
    required this.video,
  });

  final bool isLoading;
  final VideoPlayerController controller;
  final Video video;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);
    return VisibilityDetector(
      key: Key('${video.videotitle} + ${video.caption}'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage == 0) {
          log("${video.videotitle} paused");
          controller.pause();
        } else {
          log("${video.videotitle} played");
          controller.play();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  },
                  child: VideoPlayer(
                    controller,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: size.width * 0.2,
                  left: 5,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.pause();
                            firebaseOperations.goToUserProfile(
                                userUid: video.useruid, context: context);
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  image: DecorationImage(
                                    image: Image.network(video.userimage).image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: <Widget>[
                                          // Stroked text as border.
                                          Text(
                                            video.username,
                                            style: TextStyle(
                                              fontSize: 16,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 3
                                                ..color = Colors.black,
                                            ),
                                          ),
                                          // Solid text as fill.
                                          Text(
                                            video.username,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: video.verifiedUser ?? false,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: VerifiedMark(),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          child: Stack(
                            children: <Widget>[
                              // Stroked text as border.
                              Text(
                                video.videotitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3
                                    ..color = Colors.black,
                                ),
                              ),
                              // Solid text as fill.
                              Text(
                                video.videotitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 5),
                          child: Stack(
                            children: <Widget>[
                              // Stroked text as border.
                              Text(
                                video.caption,
                                style: TextStyle(
                                  fontSize: 16,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3
                                    ..color = Colors.black,
                                ),
                              ),
                              // Solid text as fill.
                              Text(
                                video.caption,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: SpeedDial(
                    backgroundColor: constantColors.navButton,
                    childrenButtonSize:
                        Size(size.width * 0.2, size.height * 0.08),
                    childPadding: EdgeInsets.all(10),
                    overlayOpacity: 0,
                    // animatedIcon: AnimatedIcons.menu_close,
                    spacing: size.height * 0.001,
                    animatedIcon: AnimatedIcons.menu_close,
                    closeManually: false,
                    children: [
                      SpeedDialChild(
                        child: Icon(
                          Icons.report_gmailerrorred,
                        ),
                        onTap: () {
                          reportVideoMenu(context, size);
                        },
                      ),
                      SpeedDialChild(
                        // visible: video.isPaid,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: constantColors.whiteColor,
                            image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: AssetImage(
                                "assets/icons/cat_icon.png",
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: false,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                height: size.height * 0.5,
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: constantColors.navButton,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 150),
                                      child: Divider(
                                        thickness: 4,
                                        color: constantColors.whiteColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      video.videoType == "video"
                                          ? "Materials"
                                          : "AR View Only Items",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      height: size.height * 0.3,
                                      width: size.width,
                                      child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection("posts")
                                              .doc(video.id)
                                              .collection("materials")
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return ListView.builder(
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  return snapshot.data!
                                                                  .docs[index]
                                                              ["ownerId"] ==
                                                          video.useruid
                                                      ? ListTile(
                                                          leading: Container(
                                                            height: 40,
                                                            width: 40,
                                                            child:
                                                                ImageNetworkLoader(
                                                              imageUrl: snapshot
                                                                      .data!
                                                                      .docs[
                                                                  index]["gif"],
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "${snapshot.data!.docs[index]["layerType"]} by ${video.username}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        )
                                                      : ListTile(
                                                          tileColor:
                                                              constantColors
                                                                  .bioBg,
                                                          trailing: Container(
                                                            height: 50,
                                                            width: 80,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    PageTransition(
                                                                        child:
                                                                            PostDetailsScreen(
                                                                          videoId: snapshot
                                                                              .data!
                                                                              .docs[index]["videoId"],
                                                                        ),
                                                                        type: PageTransitionType
                                                                            .fade));
                                                              },
                                                              child: Container(
                                                                height: 50,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        "Visit Owner",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "Owned by ${snapshot.data!.docs[index]["ownerName"]}",
                                                          ),
                                                          leading: Container(
                                                            height: 40,
                                                            width: 40,
                                                            child:
                                                                ImageNetworkLoader(
                                                              imageUrl: snapshot
                                                                      .data!
                                                                      .docs[
                                                                  index]["gif"],
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "${snapshot.data!.docs[index]["layerType"]} by ${snapshot.data!.docs[index]["ownerName"]}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        );
                                                },
                                              );
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          }),
                                    ),
                                    Divider(
                                      color: constantColors.whiteColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      constantColors.bioBg),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                            onPressed: () async {
                                              // ignore: unawaited_futures
                                              CoolAlert.show(
                                                context: context,
                                                type: CoolAlertType.loading,
                                                text:
                                                    "Saving to your collection",
                                                barrierDismissible: false,
                                              );
                                              await firebaseOperations
                                                  .addToMyCollection(
                                                videoOwnerId: video.useruid,
                                                videoItem: video,
                                                isFree: video.isFree,
                                                ctx: context,
                                                videoId: video.id,
                                              );
                                            },
                                            // paymentController.makePayment(
                                            //     amount: "10", currency: "USD"),
                                            child: Text(
                                              video.videoType == "video"
                                                  ? "Add to My Materials"
                                                  : "Add to AR View Collection",
                                              style: TextStyle(
                                                color: constantColors.navButton,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: Icon(
                          FontAwesomeIcons.shareAlt,
                        ),
                        onTap: () async {
                          var generatedLink =
                              await DynamicLinkService.createDynamicLink(
                                  video.id,
                                  short: true);
                          final String message = generatedLink.toString();

                          Get.bottomSheet(
                            ShareWidget(msg: message, urlPath: video.videourl),
                          );
                        },
                      ),
                      SpeedDialChild(
                        child: Icon(
                          FontAwesomeIcons.paperPlane,
                        ),
                        onTap: () async {
                          await Provider.of<FirebaseOperations>(context,
                                  listen: false)
                              .messageUser(
                                  messagingUid: video.useruid,
                                  messagingDocId: Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId,
                                  messagingData: {
                                    'username': Provider.of<FirebaseOperations>(
                                            context,
                                            listen: false)
                                        .getInitUserName,
                                    'userimage':
                                        Provider.of<FirebaseOperations>(context,
                                                listen: false)
                                            .getInitUserImage,
                                    'useremail':
                                        Provider.of<FirebaseOperations>(context,
                                                listen: false)
                                            .getInitUserEmail,
                                    'useruid': Provider.of<Authentication>(
                                            context,
                                            listen: false)
                                        .getUserId,
                                    'time': Timestamp.now(),
                                  },
                                  messengerUid: Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId,
                                  messengerDocId: video.useruid,
                                  messengerData: {
                                    'username': video.username,
                                    'userimage': video.userimage,
                                    'useremail': 'test - remove later',
                                    'useruid': video.useruid,
                                    'time': Timestamp.now(),
                                  })
                              .whenComplete(() async {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(video.useruid)
                                .get()
                                .then((value) {
                              if (value.exists) {
                                try {
                                  UserModel user =
                                      UserModel.fromMap(value.data()!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivateMessage(
                                        documentSnapshot: value,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  print(e.toString());
                                }
                              }
                            });
                          });
                        },
                      ),
                      SpeedDialChild(
                          child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("posts")
                                  .doc(video.id)
                                  .collection("likes")
                                  .doc(authentication.getUserId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.exists) {
                                    return IconButton(
                                      onPressed: () {
                                        firebaseOperations.deleteLikePost(
                                            postUid: video.id,
                                            userUid: authentication.getUserId,
                                            context: context);
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                    );
                                  } else {
                                    return IconButton(
                                        onPressed: () async {
                                          await firebaseOperations
                                              .likePost(
                                            sendToUserToken:
                                                video.ownerFcmToken!,
                                            likerUsername:
                                                firebaseOperations.initUserName,
                                            postUid: video.id,
                                            userUid: authentication.getUserId,
                                            context: context,
                                          )
                                              .then((value) {
                                            firebaseOperations
                                                .addLikeNotification(
                                              postId: video.id,
                                              userUid: authentication.getUserId,
                                              context: context,
                                              videoOwnerUid: video.useruid,
                                            );
                                          });
                                        },
                                        icon: Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                        ));
                                  }
                                } else {
                                  return Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                  );
                                }
                              }),
                          onLongPress: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: ShowLikesPage(
                                      postId: video.id,
                                    ),
                                    type: PageTransitionType.fade));
                          }),
                      SpeedDialChild(
                        child: Icon(
                          FontAwesomeIcons.comment,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ShowCommentsPage(
                                    ownerFcmToken: video.ownerFcmToken,
                                    postOwnerId: video.useruid,
                                    postId: video.id,
                                  ),
                                  type: PageTransitionType.fade));
                        },
                      ),
                      SpeedDialChild(
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserId)
                                .collection("favorites")
                                .doc(video.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else {
                                if (snapshot.data!.exists) {
                                  return IconButton(
                                    onPressed: () async {
                                      await firebaseOperations.removeFromFavs(
                                          video: video, context: context);
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.solidStar,
                                      color: Colors.black,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    onPressed: () async {
                                      await firebaseOperations.addToFavs(
                                          video: video, context: context);
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.star,
                                      color: Colors.black,
                                    ),
                                  );
                                }
                              }
                            }),
                      ),
                      SpeedDialChild(
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            image: DecorationImage(
                              image: Image.network(video.userimage).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: () {
                          firebaseOperations.goToUserProfile(
                              userUid: video.useruid, context: context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> reportVideoMenu(BuildContext context, Size size) {
    List<String> reportingReasons = [
      "It's spam",
      "Nudity or sexual activity",
      "Hate speech or symbols",
      "I just dont like it",
      "Bullying or harassment",
      "False Information",
      "Violence or dangerous organizations",
      "Scam or fraud",
      "Intellectual property violation"
    ];
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: size.height * 0.85,
          width: size.width,
          decoration: BoxDecoration(
            color: constantColors.navButton,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Report Video",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                "Why are you reporting this post?",
                style: TextStyle(
                  color: constantColors.bioBg,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "Your report is anonymous, except if you're reporting an intellectual property infringement. If someone is in immediate danger, call the local emergency services - dont wait.",
                style: TextStyle(
                  color: constantColors.bioBg,
                  fontSize: 12,
                ),
                textAlign: TextAlign.justify,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: 60.h,
                  width: 100.w,
                  child: ListView.builder(
                    itemCount: reportingReasons.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await FirebaseOperations().reportVideo(
                            video: video,
                            ctx: context,
                            reason: reportingReasons[index],
                          );
                          Navigator.pop(context);
                          Get.snackbar(
                            'Video Reported',
                            'Thank you for letting us know!',
                            overlayColor: constantColors.navButton,
                            colorText: constantColors.whiteColor,
                            snackPosition: SnackPosition.TOP,
                            forwardAnimationCurve: Curves.elasticInOut,
                            reverseAnimationCurve: Curves.easeOut,
                          );
                        },
                        child: Column(
                          children: [
                            Divider(
                              color: constantColors.bioBg,
                              height: 0,
                              thickness: 1,
                            ),
                            ListTile(
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                              ),
                              title: Text(
                                reportingReasons[index],
                                style: TextStyle(
                                  color: constantColors.bioBg,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Divider(
                              color: constantColors.bioBg,
                              height: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
