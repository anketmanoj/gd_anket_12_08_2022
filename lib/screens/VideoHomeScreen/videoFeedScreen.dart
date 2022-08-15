import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/description.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/feed_viewmodel.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_video_player/cached_video_player.dart' as cachedVP;

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({Key? key}) : super(key: key);

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final feedViewModel = GetIt.instance<FeedViewModel>();
  final ConstantColors constantColors = ConstantColors();

  @override
  void initState() {
    feedViewModel.loadVideo(0);
    feedViewModel.loadNext(1);
    feedViewModel.setInitialised(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
      disposeViewModel: false,
      builder: (context, model, child) => videoScreen(),
      viewModelBuilder: () => feedViewModel,
    );
  }

  Widget videoScreen() {
    return Scaffold(
      backgroundColor: GetIt.instance<FeedViewModel>().actualScreen == 0
          ? Colors.black
          : Colors.white,
      body: scrollFeed(),
    );
  }

  Widget currentScreen() {
    switch (feedViewModel.actualScreen) {
      case 0:
        return feedVideos();
      // case 1:
      //   return BlocProvider(
      //     create: (context) => SelectVideoBloc()..add(LoadVideos()),
      //     child: SelectVideos(),
      //   );
      // case 2:
      //   return AllVideoPage();
      default:
        return feedVideos();
    }
  }

  Widget scrollFeed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: currentScreen()),
        // BottomBar(),
      ],
    );
  }

  Widget feedVideos() {
    return Stack(
      children: [
        PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          itemCount: feedViewModel.videos.length,
          onPageChanged: (index) {
            index = index % (feedViewModel.videos.length);
            feedViewModel.changeVideo(index);
          },
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            index = index % (feedViewModel.videos.length);

            return videoCard(feedViewModel.videos[index]);
          },
        ),
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Following',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70)),
                  SizedBox(
                    width: 7,
                  ),
                  Container(
                    color: Colors.white70,
                    height: 10,
                    width: 1.0,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text('For You',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                ]),
          ),
        ),
      ],
    );
  }

  Future<dynamic> reportVideoMenu(
      {required BuildContext context, required Video video}) {
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
          height: 85.h,
          width: 100.w,
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

  Widget videoCard(Video video) {
    return Stack(
      children: [
        video.controller!.value.isInitialized != false
            ? GestureDetector(
                onTap: () {
                  if (video.controller!.value.isPlaying) {
                    video.controller?.pause();
                  } else {
                    video.controller?.play();
                  }
                },
                child: SizedBox.expand(
                    child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: video.controller?.value.size.width ?? 0,
                    height: video.controller?.value.size.height ?? 0,
                    child: cachedVP.CachedVideoPlayer(video.controller!),
                  ),
                )),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    color: Colors.black,
                    child: Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    )),
                  ),
                ),
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            VideoDescription(video.username, video.videotitle, video.caption,
                video.userimage),
          ],
        ),
        Positioned(
          right: 10,
          bottom: 40,
          child: SpeedDial(
            backgroundColor: constantColors.navButton,
            childrenButtonSize: Size(20.w, 8.h),
            childPadding: EdgeInsets.all(10),
            overlayOpacity: 0,
            // animatedIcon: AnimatedIcons.menu_close,
            spacing: 0.1.h,
            animatedIcon: AnimatedIcons.menu_close,
            closeManually: false,
            children: [
              SpeedDialChild(
                child: Icon(
                  Icons.report_gmailerrorred,
                ),
                onTap: () {
                  reportVideoMenu(context: context, video: video);
                },
              ),
              SpeedDialChild(
                // visible: video.isPaid,
                child: Icon(
                  FontAwesomeIcons.shoppingCart,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isDismissible: false,
                    isScrollControlled: true,
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 50.h,
                        width: 10.w,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 150),
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
                              height: 30.h,
                              width: 100.w,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("posts")
                                      .doc(video.id)
                                      .collection("materials")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          return snapshot.data!.docs[index]
                                                      ["ownerId"] ==
                                                  video.useruid
                                              ? ListTile(
                                                  leading: Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: CachedNetworkImage(
                                                      imageUrl: snapshot.data!
                                                          .docs[index]["gif"],
                                                      fit: BoxFit.cover,
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    "${snapshot.data!.docs[index]["layerType"]} by ${video.username}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : ListTile(
                                                  tileColor:
                                                      constantColors.bioBg,
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
                                                                          .docs[index]
                                                                      [
                                                                      "videoId"],
                                                                ),
                                                                type:
                                                                    PageTransitionType
                                                                        .fade));
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
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
                                                              child: Text(
                                                                "Visit Owner",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
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
                                                    child: CachedNetworkImage(
                                                      imageUrl: snapshot.data!
                                                          .docs[index]["gif"],
                                                      fit: BoxFit.cover,
                                                      progressIndicatorBuilder:
                                                          (context, url,
                                                                  downloadProgress) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    "${snapshot.data!.docs[index]["layerType"]} by ${snapshot.data!.docs[index]["ownerName"]}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
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
                                mainAxisAlignment: video.isPaid
                                    ? MainAxisAlignment.spaceBetween
                                    : MainAxisAlignment.center,
                                children: [
                                  video.isPaid
                                      ? video.discountAmount == 0
                                          ? Text(
                                              "Total: \$${video.price}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            )
                                          : video.discountAmount >= 0 &&
                                                  DateTime.now().isAfter(
                                                      (video.startDiscountDate)
                                                          .toDate()) &&
                                                  DateTime.now().isBefore(
                                                      (video.endDiscountDate)
                                                          .toDate())
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      "Total: ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      " \$${video.price}",
                                                      style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      " \$${video.price * (1 - video.discountAmount / 100)}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  "Total: \$${video.price}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                )
                                      : Container(),
                                  video.isPaid
                                      ? ElevatedButton(
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
                                            // await selectPaymentOptionsSheet(
                                            //     ctx: context,
                                            //     firebaseOperations:
                                            //         firebaseOperations);
                                          },
                                          // paymentController.makePayment(
                                          //     amount: "10", currency: "USD"),
                                          child: Text(
                                            "Purchase",
                                            style: TextStyle(
                                              color: constantColors.navButton,
                                            ),
                                          ),
                                        )
                                      : ElevatedButton(
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
                                              text: "Saving to your collection",
                                              barrierDismissible: false,
                                            );
                                            await context
                                                .read<FirebaseOperations>()
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
                      await DynamicLinkService.createDynamicLink(video.id,
                          short: true);
                  Share.share(
                    'check out this video ' + generatedLink.toString(),
                  );
                },
              ),
              SpeedDialChild(
                child: Icon(
                  FontAwesomeIcons.paperPlane,
                ),
                onTap: () async {
                  await Provider.of<FirebaseOperations>(context, listen: false)
                      .messageUser(
                          messagingUid: video.useruid,
                          messagingDocId: Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId,
                          messagingData: {
                            'username': Provider.of<FirebaseOperations>(context,
                                    listen: false)
                                .getInitUserName,
                            'userimage': Provider.of<FirebaseOperations>(
                                    context,
                                    listen: false)
                                .getInitUserImage,
                            'useremail': Provider.of<FirebaseOperations>(
                                    context,
                                    listen: false)
                                .getInitUserEmail,
                            'useruid': Provider.of<Authentication>(context,
                                    listen: false)
                                .getUserId,
                            'time': Timestamp.now(),
                          },
                          messengerUid: Provider.of<Authentication>(context,
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
                          UserModel user = UserModel.fromMap(value.data()!);
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
                          .doc(context.read<Authentication>().getUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.exists) {
                            return IconButton(
                              onPressed: () {
                                context
                                    .read<FirebaseOperations>()
                                    .deleteLikePost(
                                        postUid: video.id,
                                        userUid: context
                                            .read<Authentication>()
                                            .getUserId,
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
                                  await context
                                      .read<FirebaseOperations>()
                                      .likePost(
                                        sendToUserToken: video.ownerFcmToken!,
                                        likerUsername: context
                                            .read<FirebaseOperations>()
                                            .initUserName,
                                        postUid: video.id,
                                        userUid: context
                                            .read<Authentication>()
                                            .getUserId,
                                        context: context,
                                      )
                                      .then((value) {
                                    context
                                        .read<FirebaseOperations>()
                                        .addLikeNotification(
                                          postId: video.id,
                                          userUid: context
                                              .read<Authentication>()
                                              .getUserId,
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
                        .doc(Provider.of<Authentication>(context, listen: false)
                            .getUserId)
                        .collection("favorites")
                        .doc(video.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.data!.exists) {
                          return IconButton(
                            onPressed: () async {
                              await context
                                  .read<FirebaseOperations>()
                                  .removeFromFavs(
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
                              await context
                                  .read<FirebaseOperations>()
                                  .addToFavs(video: video, context: context);
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
                  context.read<FirebaseOperations>().goToUserProfile(
                      userUid: video.useruid, context: context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // feedViewModel.controller?.dispose();
    super.dispose();
  }
}
