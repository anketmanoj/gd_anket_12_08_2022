// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/ForAnonUsers/AnonUserSignUprequired.dart';
import 'package:diamon_rose_app/screens/HelpScreen/tutorialVideos.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/PostPage/postMaterialModel.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/buyCaratScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/screens/audioPlayer/audioPlayerScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage_helpers.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/ShareWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:diamon_rose_app/widgets/readMoreWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Custom Feed Widget consisting video
class VideoWidget extends StatelessWidget {
  VideoWidget(
      {Key? key,
      required this.isLoading,
      required this.controller,
      required this.video,
      this.homeScreenOptions = HomeScreenOptions.Free,
      this.showIconNow = false});

  final bool isLoading;
  final VideoPlayerController controller;
  final Video video;
  final HomeScreenOptions homeScreenOptions;
  final bool showIconNow;

  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  Offset? _initPosDiamond;
  Offset? _currentPosDiamond = Offset(0, 0);
  ContainerList tipsNTricksContainer = ContainerList(
    gifSelected: "assets/images/tipsntricks.png",
    height: 105,
    width: 105,
    rotation: 0,
    scale: 1,
    xPosition: 0,
    yPosition: 0,
  );

  ContainerList diamondContainer = ContainerList(
    gifSelected: "assets/images/getDiamonds.png",
    height: 100,
    width: 100,
    rotation: 0,
    scale: 1,
    xPosition: 0,
    yPosition: 0,
  );

  Size screen = Size(400, 500);

  @override
  Widget build(BuildContext context) {
    if (context.read<Authentication>().getIsAnon == false) {
      if (adminUserId.contains(context.read<Authentication>().getUserId)) {
        return ViewableContent(context);
      }
      return !video.boughtBy
                  .contains(context.read<Authentication>().getUserId) &&
              video.isPaid
          ? paidVideoNotBought(context)
          : ViewableContent(context);
    } else {
      return ViewableContent(context);
    }
  }

  Widget paidVideoNotBought(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 100.h,
          width: 100.w,
          child: ImageNetworkLoader(imageUrl: video!.thumbnailurl),
        ),
        Positioned(
          child: Center(
            child: BlurryContainer.expand(
              blur: 8,
              elevation: 0,
              color: Colors.transparent,
              padding: const EdgeInsets.all(8),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20.h,
                        width: 100.w,
                        child: ImageNetworkLoader(
                          imageUrl: video!.thumbnailurl,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 7.h,
                        width: 100.w,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            viewMaterials(context);
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                constantColors.black),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.lock_open,
                            color: constantColors.whiteColor,
                            size: 30,
                          ),
                          label: Text(
                            "Purchase Content",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // back button

        Positioned(
          bottom: 10,
          right: 20.w,
          left: 5,
          child: Container(
            padding: EdgeInsets.all(5),
            width: 100.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    context.read<FirebaseOperations>().goToUserProfile(
                        userUid: video!.useruid, context: context);
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: Image.network(video!.userimage).image,
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
                                    video!.username,
                                    style: TextStyle(
                                      fontSize: 14,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.black,
                                    ),
                                  ),
                                  // Solid text as fill.
                                  Text(
                                    video!.username,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: video!.verifiedUser ?? false,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
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
                        video!.videotitle,
                        style: TextStyle(
                          fontSize: 14,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        video!.videotitle,
                        style: TextStyle(
                          fontSize: 14,
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
                      ReadMoreText(
                        video!.caption,
                        trimLines: 2,
                        colorClickableText: constantColors.navButton,
                        trimMode: TrimMode.Line,
                        moreStyle: TextStyle(
                          shadows: outlinedText(
                            strokeColor: constantColors.whiteColor,
                          ),
                          color: constantColors.mainColor,
                        ),
                        lessStyle: TextStyle(
                          shadows: outlinedText(
                            strokeColor: constantColors.whiteColor,
                          ),
                          color: constantColors.mainColor,
                        ),
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          shadows: outlinedText(
                            strokeColor: constantColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Stack(
                    children: <Widget>[
                      // Stroked text as border.
                      Text(
                        timeago.format((video!.timestamp).toDate()),
                        style: TextStyle(
                          fontSize: 10,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        timeago.format((video!.timestamp).toDate()),
                        style: TextStyle(
                          fontSize: 10,
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
            childrenButtonSize: Size(20.w, 8.h),
            childPadding: EdgeInsets.all(10),
            overlayOpacity: 0,
            // animatedIcon: AnimatedIcons.menu_close,
            spacing: 0.01.h,
            animatedIcon: AnimatedIcons.menu_close,
            closeManually: false,
            children: [
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
                onTap: () => video!.isFree
                    ? freeMaterialsBottomSheet(
                        context, context.read<FirebaseOperations>())
                    : viewMaterials(
                        context,
                      ),
              ),
              SpeedDialChild(
                child: Icon(
                  FontAwesomeIcons.shareAlt,
                ),
                onTap: () async {
                  var generatedLink =
                      await DynamicLinkService.createDynamicLink(video!.id,
                          short: true);
                  final String message = generatedLink.toString();

                  bool canShareVal = false;

                  if (video!.isPaid) {
                    if (video!.boughtBy
                        .contains(context.read<Authentication>().getUserId)) {
                      canShareVal = true;
                    }
                    if (video!.useruid ==
                        context.read<Authentication>().getUserId) {
                      canShareVal == true;
                    }
                  } else {
                    canShareVal = true;
                  }

                  Get.bottomSheet(
                    ShareWidget(
                      msg: message,
                      urlPath: video!.videourl,
                      videoOwnerName: video!.username,
                      canShareToSocialMedia: canShareVal,
                    ),
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
                          messagingUid: video!.useruid,
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
                          messengerDocId: video!.useruid,
                          messengerData: {
                            'username': video!.username,
                            'userimage': video!.userimage,
                            'useremail': 'test - remove later',
                            'useruid': video!.useruid,
                            'time': Timestamp.now(),
                          })
                      .whenComplete(() async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(video!.useruid)
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
                          .doc(video!.id)
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
                                        postUid: video!.id,
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
                                        videoOwnerId: video!.useruid,
                                        sendToUserToken: video!.ownerFcmToken!,
                                        likerUsername: context
                                            .read<FirebaseOperations>()
                                            .initUserName,
                                        postUid: video!.id,
                                        userUid: context
                                            .read<Authentication>()
                                            .getUserId,
                                        context: context,
                                      )
                                      .then((value) {
                                    context
                                        .read<FirebaseOperations>()
                                        .addLikeNotification(
                                          postId: video!.id,
                                          userUid: context
                                              .read<Authentication>()
                                              .getUserId,
                                          context: context,
                                          videoOwnerUid: video!.useruid,
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
                              postId: video!.id,
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
                            ownerFcmToken: video!.ownerFcmToken,
                            postOwnerId: video!.useruid,
                            postId: video!.id,
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
                        .doc(video!.id)
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
                                      video: video!, context: context);
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
                                  .addToFavs(video: video!, context: context);
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: Image.network(video.userimage).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {
                  context.read<FirebaseOperations>().goToUserProfile(
                      userUid: video!.useruid, context: context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget ViewableContent(BuildContext context) {
    return Stack(
      children: [
        VisibilityDetector(
          key:
              Key('${video.videotitle} + ${video.caption} + ${DateTime.now()}'),
          onVisibilityChanged: (visibilityInfo) {
            var visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (visiblePercentage == 100) {
              log("${video.videotitle} played");

              controller.play();
            } else {
              log("${video.videotitle} paused");
              controller.pause();
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
                      left: 5,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: 100.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.pause();
                                context
                                    .read<FirebaseOperations>()
                                    .goToUserProfile(
                                        userUid: video.useruid,
                                        context: context);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      image: DecorationImage(
                                        image: Image.network(video.userimage)
                                            .image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          video.username,
                                          style: TextStyle(
                                            shadows: outlinedText(
                                              strokeColor: constantColors.black,
                                            ),
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Visibility(
                                          visible: video.verifiedUser ?? false,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: VerifiedMark(),
                                          ),
                                        ),
                                        if (context
                                                .read<Authentication>()
                                                .getIsAnon ==
                                            false)
                                          StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(video.useruid)
                                                  .collection("followers")
                                                  .doc(context
                                                      .read<Authentication>()
                                                      .getUserId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                if (snapshot.data!.exists) {
                                                  return SizedBox();
                                                } else {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                  FirebaseOperations>()
                                                              .goToUserProfile(
                                                                  userUid: video
                                                                      .useruid,
                                                                  context:
                                                                      context);
                                                        },
                                                        child: Container(
                                                          width: 25.w,
                                                          height: 4.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  constantColors
                                                                      .bioBg,
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            LocaleKeys
                                                                .visitprofile
                                                                .tr(),
                                                            style: TextStyle(
                                                              color:
                                                                  constantColors
                                                                      .bioBg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 5,
                                right: 30,
                              ),
                              child: Text(
                                video.videotitle,
                                style: TextStyle(
                                  shadows: outlinedText(
                                    strokeColor: constantColors.black,
                                  ),
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                top: 5,
                                right: 15.w,
                              ),
                              child: Stack(
                                children: <Widget>[
                                  // Solid text as fill.
                                  ReadMoreText(
                                    video.caption,
                                    trimLines: 2,
                                    colorClickableText:
                                        constantColors.navButton,
                                    trimMode: TrimMode.Line,
                                    moreStyle: TextStyle(
                                      shadows: outlinedText(
                                        strokeColor: constantColors.whiteColor,
                                      ),
                                      color: constantColors.mainColor,
                                    ),
                                    lessStyle: TextStyle(
                                      shadows: outlinedText(
                                        strokeColor: constantColors.whiteColor,
                                      ),
                                      color: constantColors.mainColor,
                                    ),
                                    trimCollapsedText: 'Show more',
                                    trimExpandedText: 'Show less',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      shadows: outlinedText(
                                        strokeColor: constantColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: (video.timestamp).toDate().isAfter(
                                  DateTime.now().add(Duration(days: -3))),
                              replacement: Padding(
                                padding: EdgeInsets.only(left: 10, top: 5),
                                child: Stack(
                                  children: <Widget>[
                                    // Stroked text as border.

                                    Text(
                                      (video.timestamp)
                                          .toDate()
                                          .toString()
                                          .substring(0, 10),
                                      style: TextStyle(
                                        shadows: outlinedText(
                                          strokeColor: constantColors.black,
                                        ),
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, top: 5),
                                child: Stack(
                                  children: <Widget>[
                                    // Stroked text as border.
                                    Text(
                                      timeago
                                          .format((video.timestamp).toDate()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 3
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    // Solid text as fill.
                                    Text(
                                      timeago
                                          .format((video.timestamp).toDate()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
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
                        childrenButtonSize: Size(20.w, 8.h),
                        childPadding: EdgeInsets.all(10),
                        overlayOpacity: 0,
                        // animatedIcon: AnimatedIcons.menu_close,
                        spacing: 0.01.h,
                        animatedIcon: AnimatedIcons.menu_close,
                        closeManually: false,
                        children: [
                          if (context.read<Authentication>().getIsAnon == false)
                            SpeedDialChild(
                              child: Icon(
                                Icons.report_gmailerrorred,
                              ),
                              onTap: () {
                                reportVideoMenu(context);
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
                            onTap: context.read<Authentication>().getIsAnon ==
                                    false
                                ? () => video.isFree
                                    ? freeMaterialsBottomSheet(context,
                                        context.read<FirebaseOperations>())
                                    : viewMaterials(context)
                                : () {
                                    SignUpRequired(context);
                                  },
                          ),
                          SpeedDialChild(
                            child: Icon(
                              FontAwesomeIcons.shareAlt,
                            ),
                            onTap: context.read<Authentication>().getIsAnon ==
                                    false
                                ? () async {
                                    var generatedLink = await DynamicLinkService
                                        .createDynamicLink(video.id,
                                            short: true);
                                    final String message =
                                        generatedLink.toString();

                                    bool canShareVal = false;

                                    if (video.isPaid) {
                                      if (video.boughtBy.contains(context
                                          .read<Authentication>()
                                          .getUserId)) {
                                        canShareVal = true;
                                      }
                                      if (video.useruid ==
                                          context
                                              .read<Authentication>()
                                              .getUserId) {
                                        canShareVal == true;
                                      }
                                    } else {
                                      canShareVal = true;
                                    }

                                    final androidInfo =
                                        await DeviceInfoPlugin().androidInfo;
                                    late final Map<Permission, PermissionStatus>
                                        statusess;

                                    if (androidInfo.version.sdkInt! <= 32 ||
                                        Platform.isIOS) {
                                      statusess =
                                          await [Permission.storage].request();
                                    } else {
                                      statusess = await [
                                        Permission.photos,
                                        Permission.notification,
                                        Permission.videos,
                                        Permission.audio,
                                        Permission.camera,
                                      ].request();
                                    }

                                    var allAccept = true;

                                    statusess.forEach((permission, status) {
                                      if (status != PermissionStatus.granted) {
                                        allAccept = false;
                                      }
                                    });

                                    if (allAccept) {
                                      await Get.bottomSheet(
                                        ShareWidget(
                                          msg: message,
                                          urlPath: video.videourl,
                                          videoOwnerName: video.username,
                                          canShareToSocialMedia: canShareVal,
                                        ),
                                      );
                                    } else {
                                      await Get.dialog(
                                        SimpleDialog(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Device permissions required",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Permissions are required to store the videos on your device so you can share the videos on various other social media platforms!",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SubmitButton(
                                                    text: "Open Settings",
                                                    function: () async {
                                                      await openAppSettings();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                : () {
                                    SignUpRequired(context);
                                  },
                          ),
                          SpeedDialChild(
                            child: Icon(
                              FontAwesomeIcons.paperPlane,
                            ),
                            onTap: context.read<Authentication>().getIsAnon ==
                                    false
                                ? () async {
                                    await Provider.of<FirebaseOperations>(
                                            context,
                                            listen: false)
                                        .messageUser(
                                            messagingUid: video.useruid,
                                            messagingDocId:
                                                Provider.of<Authentication>(
                                                        context,
                                                        listen: false)
                                                    .getUserId,
                                            messagingData: {
                                              'username': Provider.of<
                                                          FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .getInitUserName,
                                              'userimage': Provider.of<
                                                          FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .getInitUserImage,
                                              'useremail': Provider.of<
                                                          FirebaseOperations>(
                                                      context,
                                                      listen: false)
                                                  .getInitUserEmail,
                                              'useruid':
                                                  Provider.of<Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                              'time': Timestamp.now(),
                                            },
                                            messengerUid:
                                                Provider.of<Authentication>(
                                                        context,
                                                        listen: false)
                                                    .getUserId,
                                            messengerDocId: video.useruid,
                                            messengerData: {
                                              'username': video.username,
                                              'userimage': video.userimage,
                                              'useremail':
                                                  'test - remove later',
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
                                            UserModel user = UserModel.fromMap(
                                                value.data()!);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PrivateMessage(
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
                                  }
                                : () {
                                    SignUpRequired(context);
                                  },
                          ),
                          SpeedDialChild(
                              child: context.read<Authentication>().getIsAnon ==
                                      false
                                  ? StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection("posts")
                                          .doc(video.id)
                                          .collection("likes")
                                          .doc(context
                                              .read<Authentication>()
                                              .getUserId)
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
                                                            .read<
                                                                Authentication>()
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
                                                      .read<
                                                          FirebaseOperations>()
                                                      .likePost(
                                                        videoOwnerId:
                                                            video.useruid,
                                                        sendToUserToken: video
                                                            .ownerFcmToken!,
                                                        likerUsername: context
                                                            .read<
                                                                FirebaseOperations>()
                                                            .initUserName,
                                                        postUid: video.id,
                                                        userUid: context
                                                            .read<
                                                                Authentication>()
                                                            .getUserId,
                                                        context: context,
                                                      )
                                                      .then((value) {
                                                    context
                                                        .read<
                                                            FirebaseOperations>()
                                                        .addLikeNotification(
                                                          postId: video.id,
                                                          userUid: context
                                                              .read<
                                                                  Authentication>()
                                                              .getUserId,
                                                          context: context,
                                                          videoOwnerUid:
                                                              video.useruid,
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
                                      })
                                  : IconButton(
                                      onPressed: () {
                                        SignUpRequired(context);
                                      },
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Colors.red,
                                      )),
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
                            onTap: context.read<Authentication>().getIsAnon ==
                                    false
                                ? () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ShowCommentsPage(
                                              ownerFcmToken:
                                                  video.ownerFcmToken,
                                              postOwnerId: video.useruid,
                                              postId: video.id,
                                            ),
                                            type: PageTransitionType.fade));
                                  }
                                : () {
                                    SignUpRequired(context);
                                  },
                          ),
                          SpeedDialChild(
                            child: context.read<Authentication>().getIsAnon ==
                                    false
                                ? StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
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
                                              await context
                                                  .read<FirebaseOperations>()
                                                  .removeFromFavs(
                                                      video: video,
                                                      context: context);
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
                                                  .addToFavs(
                                                      video: video,
                                                      context: context);
                                            },
                                            icon: Icon(
                                              FontAwesomeIcons.star,
                                              color: Colors.black,
                                            ),
                                          );
                                        }
                                      }
                                    })
                                : IconButton(
                                    onPressed: () {
                                      SignUpRequired(context);
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.star,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          SpeedDialChild(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: Image.network(video.userimage).image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            onTap: () {
                              context
                                  .read<FirebaseOperations>()
                                  .goToUserProfile(
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
        ),
        SharedPreferencesHelper.getBool("hideTutorial") == false
            ? StatefulBuilder(builder: (context, innerState) {
                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Container(
                    height: 90.h,
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onScaleStart: (details) {
                            if (tipsNTricksContainer == null) return;
                            _initPos = details.focalPoint;

                            _currentPos = Offset(
                                SharedPreferencesHelper.getDxValue("dxVal") /
                                    screen.width,
                                SharedPreferencesHelper.getDxValue("dyVal") /
                                    screen.height);

                            log("starting");
                          },
                          onScaleUpdate: (details) {
                            if (tipsNTricksContainer == null) return;
                            final delta = details.focalPoint - _initPos!;
                            final left =
                                (delta.dx / screen.width) + _currentPos!.dx;
                            final top =
                                (delta.dy / screen.height) + _currentPos!.dy;

                            innerState(() {
                              tipsNTricksContainer.xPosition =
                                  Offset(left, top).dx;
                              tipsNTricksContainer.yPosition =
                                  Offset(left, top).dy;
                            });

                            // tipsNTricksContainer.value.xPosition =
                            //     Offset(left, top).dx;
                            // tipsNTricksContainer.value.yPosition =
                            //     Offset(left, top).dy;

                            SharedPreferencesHelper.setDxValue("dxVal",
                                tipsNTricksContainer.xPosition! * screen.width);
                            SharedPreferencesHelper.setDyValue(
                                "dyVal",
                                tipsNTricksContainer.yPosition! *
                                    screen.height);
                            // print(
                            //     "x value = ${left * MediaQuery.of(context).size.width}");
                            // print(
                            //     " y value = ${top * MediaQuery.of(context).size.height}");
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left:
                                    SharedPreferencesHelper.getDxValue("dxVal"),
                                top:
                                    SharedPreferencesHelper.getDyValue("dyVal"),
                                child: Transform.scale(
                                  scale: 1,
                                  child: Transform.rotate(
                                    angle: tipsNTricksContainer.rotation!,
                                    child: Container(
                                      height: tipsNTricksContainer.height,
                                      width: tipsNTricksContainer.width,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Listener(
                                          onPointerDown: (details) {
                                            // if (_inAction) return;
                                            // _inAction = true;
                                            // _activeItem = val;
                                            _initPos = details.position;
                                            _currentPos = Offset(
                                                tipsNTricksContainer.xPosition!,
                                                tipsNTricksContainer
                                                    .yPosition!);
                                          },
                                          onPointerUp: (details) {
                                            // _inAction = false;
                                          },
                                          child: InkWell(
                                            onTap: () {
                                              controller.pause();
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child:
                                                          TutorialVideoScreen(),
                                                      type: PageTransitionType
                                                          .fade));
                                            },
                                            child: Image.asset(
                                              "assets/images/tipsntricks.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            : SizedBox(),
        SharedPreferencesHelper.getBool("hideDiamondAd") == false &&
                showIconNow == true
            ? StatefulBuilder(builder: (context, innerState) {
                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Container(
                    height: 90.h,
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onScaleStart: (details) {
                            if (diamondContainer == null) return;
                            _initPosDiamond = details.focalPoint;

                            _currentPosDiamond = Offset(
                                SharedPreferencesHelper.getDxValueForDiamond(
                                        "dxValDiamond") /
                                    screen.width,
                                SharedPreferencesHelper.getDyValueForDiamond(
                                        "dyValDiamond") /
                                    screen.height);

                            log("starting");
                          },
                          onScaleUpdate: (details) {
                            if (diamondContainer == null) return;
                            final delta = details.focalPoint - _initPosDiamond!;
                            final left = (delta.dx / screen.width) +
                                _currentPosDiamond!.dx;
                            final top = (delta.dy / screen.height) +
                                _currentPosDiamond!.dy;

                            innerState(() {
                              diamondContainer.xPosition = Offset(left, top).dx;
                              diamondContainer.yPosition = Offset(left, top).dy;
                            });

                            // diamondContainer.value.xPosition =
                            //     Offset(left, top).dx;
                            // diamondContainer.value.yPosition =
                            //     Offset(left, top).dy;

                            SharedPreferencesHelper.setDxValueForDiamond(
                                "dxValDiamond",
                                diamondContainer.xPosition! * screen.width);
                            SharedPreferencesHelper.setDyValueForDiamond(
                                "dyValDiamond",
                                diamondContainer.yPosition! * screen.height);
                            // print(
                            //     "x value = ${left * MediaQuery.of(context).size.width}");
                            // print(
                            //     " y value = ${top * MediaQuery.of(context).size.height}");
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: SharedPreferencesHelper
                                    .getDxValueForDiamond("dxValDiamond"),
                                top: SharedPreferencesHelper
                                    .getDyValueForDiamond("dyValDiamond"),
                                child: Transform.scale(
                                  scale: 1,
                                  child: Transform.rotate(
                                    angle: diamondContainer.rotation!,
                                    child: Container(
                                      height: diamondContainer.height,
                                      width: diamondContainer.width,
                                      child: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Listener(
                                          onPointerDown: (details) {
                                            // if (_inAction) return;
                                            // _inAction = true;
                                            // _activeItem = val;
                                            _initPosDiamond = details.position;
                                            _currentPosDiamond = Offset(
                                                diamondContainer.xPosition!,
                                                diamondContainer.yPosition!);
                                          },
                                          onPointerUp: (details) {
                                            // _inAction = false;
                                          },
                                          child: InkWell(
                                            onTap: context
                                                        .read<Authentication>()
                                                        .getIsAnon ==
                                                    false
                                                ? () {
                                                    controller.pause();
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            child:
                                                                BuyCaratScreen(),
                                                            type:
                                                                PageTransitionType
                                                                    .fade));
                                                  }
                                                : () {
                                                    SignUpRequired(context);
                                                  },
                                            child: Image.asset(
                                              "assets/images/getDiamonds.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
            : SizedBox(),
      ],
    );
  }

  dynamic viewMaterials(BuildContext context) async {
    await showModalBottomSheet(
      backgroundColor: constantColors.navButton,
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: 50.h,
          width: 100.w,
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
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Materials for ${video!.isPaid ? 'Sale' : 'Free'}",
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
                        .doc(video!.id)
                        .collection("materials")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<PostMaterialModel> postMaterials = [];
                        snapshot.data!.docs.forEach((element) {
                          PostMaterialModel postMaterialModel =
                              PostMaterialModel.fromMap(
                                  element.data() as Map<String, dynamic>);
                          postMaterials.add(postMaterialModel);
                        });

                        List<PostMaterialModel> othersMaterials = postMaterials
                            .where(
                                (element) => element.ownerId != video!.useruid)
                            .toList();
                        List<PostMaterialModel> myItems = postMaterials
                            .where(
                                (element) => element.ownerId == video!.useruid)
                            .toList();

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: othersMaterials.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  tileColor: constantColors.bioBg,
                                  trailing: Container(
                                    height: 50,
                                    width: 80,
                                    child: InkWell(
                                      onTap: () async {
                                        bool checkExists = await Provider.of<
                                                    FirebaseOperations>(context,
                                                listen: false)
                                            .checkPostExists(
                                                postId: othersMaterials[index]
                                                    .videoId!);

                                        if (checkExists == true) {
                                          Video videoVal = await context
                                              .read<FirebaseOperations>()
                                              .getVideoPosts(
                                                  videoId:
                                                      othersMaterials[index]
                                                          .videoId!);
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: PostDetailsScreen(
                                                    video: videoVal,
                                                  ),
                                                  type:
                                                      PageTransitionType.fade));
                                        } else {
                                          Get.dialog(
                                            SimpleDialog(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                    "Post No longer Exists",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: Text(
                                                LocaleKeys.visitowner.tr(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${LocaleKeys.ownedby.tr()} ${othersMaterials[index].ownerName}",
                                    style:
                                        TextStyle(color: constantColors.bioBg),
                                  ),
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    child: ImageNetworkLoader(
                                      imageUrl: othersMaterials[index]
                                                  .layerType ==
                                              "AR"
                                          ? othersMaterials[index].imgSeq![0]
                                          : othersMaterials[index].gif,
                                    ),
                                  ),
                                  title: Text(
                                    "${othersMaterials[index].layerType} by ${othersMaterials[index].ownerName}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: myItems.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    child: ImageNetworkLoader(
                                      imageUrl: myItems[index].layerType == "AR"
                                          ? myItems[index].imgSeq![0]
                                          : myItems[index].gif,
                                    ),
                                  ),
                                  title: Text(
                                    "${myItems[index].layerType} by ${myItems[index].ownerName}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: myItems[index].usage != null
                                      ? Row(
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.arrow_forward,
                                                color: constantColors.bioBg,
                                              ),
                                              label: Text(
                                                "As ${myItems[index].usage}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                          ],
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
                  mainAxisAlignment: video!.isPaid
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    video!.isPaid
                        ? video!.discountAmount == 0
                            ? Text(
                                "${(video!.price).toStringAsFixed(2)} Carats",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              )
                            : video!.discountAmount >= 0 &&
                                    DateTime.now().isAfter(
                                        (video!.startDiscountDate).toDate()) &&
                                    DateTime.now().isBefore(
                                        (video!.endDiscountDate).toDate())
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
                                        " \$${(video!.price).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        " \$${((video!.price) * (1 - video!.discountAmount / 100)).toStringAsFixed(2)} Carats",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "${(video!.price).toStringAsFixed(2)} Carats",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  )
                        : Container(),
                    video!.isPaid
                        ? !video!.boughtBy.contains(
                                context.read<Authentication>().getUserId)
                            ? ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          constantColors.bioBg),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Get.dialog(
                                    SimpleDialog(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Consumer<CaratProvider>(
                                              builder: (context, carat, _) {
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Carats",
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .navButton,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    VerifiedMark(
                                                      height: 25,
                                                      width: 25,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      carat.getCarats
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: constantColors
                                                            .navButton,
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "Are you sure you want to spend ${((video.price) * (1 - video.discountAmount / 100)).toStringAsFixed(2)} Carats?",
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    ElevatedButton.icon(
                                                      onPressed: () async {
                                                        final double
                                                            totalPrice =
                                                            (video.price) *
                                                                (1 -
                                                                    video.discountAmount /
                                                                        100);

                                                        log("total price : $totalPrice");
                                                        if (carat.getCarats <
                                                            totalPrice) {
                                                          await Get.bottomSheet(
                                                              Container(
                                                                height: 80.h,
                                                                width: 100.w,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: constantColors
                                                                      .whiteColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Text(
                                                                      "Not Enough Carats",
                                                                      style:
                                                                          TextStyle(
                                                                        color: constantColors
                                                                            .navButton,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Text(
                                                                      "Please purchase ${totalPrice - carat.getCarats} more carat(s) to purchase the items",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color: constantColors
                                                                            .navButton,
                                                                        fontSize:
                                                                            16,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          BuyCaratScreen(
                                                                        showAppBar:
                                                                            false,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              enableDrag: true,
                                                              isDismissible:
                                                                  true,
                                                              isScrollControlled:
                                                                  true);
                                                        } else {
                                                          log("old timestamp == ${video.timestamp.toDate()}");

                                                          video.timestamp =
                                                              Timestamp.now();

                                                          log("new timestamp == ${video.timestamp.toDate()}");

                                                          log("Total price here  = $totalPrice");
                                                          log("here ${video.timestamp}");
                                                          log("amount transfered == $totalPrice");
                                                          try {
                                                            await context
                                                                .read<
                                                                    FirebaseOperations>()
                                                                .addToMyCollectionFromCart(
                                                                  auth: context
                                                                      .read<
                                                                          Authentication>(),
                                                                  videoOwnerId:
                                                                      video
                                                                          .useruid,
                                                                  amount:
                                                                      totalPrice
                                                                          .toInt(),
                                                                  videoItem:
                                                                      video,
                                                                  isFree: video
                                                                      .isFree,
                                                                  videoId:
                                                                      video.id,
                                                                );

                                                            log("success added to cart!");
                                                          } catch (e) {
                                                            log("error saving cart to my collection ${e.toString()}");
                                                          }

                                                          try {
                                                            final int
                                                                remainingCarats =
                                                                carat.getCarats -
                                                                    totalPrice
                                                                        .toInt();

                                                            log("started ${carat.getCarats} | using ${totalPrice} | remaining ${remainingCarats}");
                                                            context
                                                                .read<
                                                                    CaratProvider>()
                                                                .setCarats(
                                                                    remainingCarats);
                                                            log("cartprovider value ${context.read<CaratProvider>().getCarats}");
                                                            await context
                                                                .read<
                                                                    FirebaseOperations>()
                                                                .updateCaratsOfUser(
                                                                    userid: context
                                                                        .read<
                                                                            Authentication>()
                                                                        .getUserId,
                                                                    caratValue:
                                                                        remainingCarats);
                                                          } catch (e) {
                                                            log("error updating users carat amount");
                                                          }

                                                          Get.snackbar(
                                                            'Content Purchased!',
                                                            "Content was successfully purchased!",
                                                            overlayColor:
                                                                constantColors
                                                                    .navButton,
                                                            colorText:
                                                                constantColors
                                                                    .whiteColor,
                                                            snackPosition:
                                                                SnackPosition
                                                                    .TOP,
                                                            forwardAnimationCurve:
                                                                Curves
                                                                    .elasticInOut,
                                                            reverseAnimationCurve:
                                                                Curves.easeOut,
                                                          );

                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);

                                                          BlocProvider.of<
                                                                      FollowingPreloadBloc>(
                                                                  context,
                                                                  listen: false)
                                                              .add(FollowingPreloadEvent
                                                                  .setLoadingForFilter(
                                                                      true));

                                                          BlocProvider.of<
                                                                      FollowingPreloadBloc>(
                                                                  context,
                                                                  listen: false)
                                                              .add(FollowingPreloadEvent
                                                                  .filterBetweenFreePaid(
                                                                      HomeScreenOptions
                                                                          .Both));

                                                          // ignore: unawaited_futures
                                                          Video videoVal = await context
                                                              .read<
                                                                  FirebaseOperations>()
                                                              .getVideoPosts(
                                                                  videoId:
                                                                      video.id);
                                                          Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  child:
                                                                      PostDetailsScreen(
                                                                    video:
                                                                        videoVal,
                                                                  ),
                                                                  type: PageTransitionType
                                                                      .fade));
                                                        }
                                                      },
                                                      icon: VerifiedMark(
                                                        height: 25,
                                                        width: 25,
                                                      ),
                                                      label: Text(
                                                        "Purchase",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  );
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
                            : Text(
                                "Already Purchased Content",
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                ),
                              )
                        : ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  constantColors.bioBg),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              log("message");
                              // ignore: unawaited_futures
                              // CoolAlert.show(
                              //   context: context,
                              //   type:
                              //       CoolAlertType.loading,
                              //   text:
                              //       "Saving to your collection",
                              //   barrierDismissible: false,
                              // );
                              // await firebaseOperations
                              //     .addToMyCollection(
                              //   videoItem: videoModel,
                              //   isFree: video.isFree,
                              //   ctx: context,
                              //   videoId: video.id,
                              // );
                            },
                            // paymentController.makePayment(
                            //     amount: "10", currency: "USD"),
                            child: Text(
                              LocaleKeys.addtomymaterials.tr(),
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
  }

  dynamic freeMaterialsBottomSheet(
      BuildContext context, FirebaseOperations firebaseOperations) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          bottom: Platform.isAndroid ? true : false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: 100.w,
            height: 60.h,
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
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  video!.videoType == "video" ? "Items" : "AR View Only Items",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 100.w,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .doc(video.id)
                          .collection("materials")
                          .where("hideItem", isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<PostMaterialModel> postMaterials = [];
                          snapshot.data!.docs.forEach((element) {
                            PostMaterialModel postMaterialModel =
                                PostMaterialModel.fromMap(
                                    element.data() as Map<String, dynamic>);
                            postMaterials.add(postMaterialModel);
                          });

                          List<PostMaterialModel> othersMaterials =
                              postMaterials
                                  .where((element) =>
                                      element.ownerId != video!.useruid)
                                  .toList();
                          List<PostMaterialModel> myItems = postMaterials
                              .where((element) =>
                                  element.ownerId == video!.useruid)
                              .toList();

                          return Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: othersMaterials.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    tileColor: constantColors.bioBg,
                                    trailing: Container(
                                      height: 50,
                                      width: 80,
                                      child: InkWell(
                                        onTap: () async {
                                          bool checkExists = await Provider.of<
                                                      FirebaseOperations>(
                                                  context,
                                                  listen: false)
                                              .checkPostExists(
                                                  postId: othersMaterials[index]
                                                      .videoId!);

                                          if (checkExists == true) {
                                            Video videoVal = await context
                                                .read<FirebaseOperations>()
                                                .getVideoPosts(
                                                    videoId:
                                                        othersMaterials[index]
                                                            .videoId!);
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: PostDetailsScreen(
                                                      video: videoVal,
                                                    ),
                                                    type: PageTransitionType
                                                        .fade));
                                          } else {
                                            Get.dialog(
                                              SimpleDialog(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                      "Post No longer Exists",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Text(
                                                  LocaleKeys.visitowner.tr(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${LocaleKeys.ownedby.tr()} ${othersMaterials[index].ownerName}",
                                      style: TextStyle(
                                          color: constantColors.bioBg),
                                    ),
                                    leading: Container(
                                      height: 40,
                                      width: 40,
                                      child: ImageNetworkLoader(
                                        imageUrl: othersMaterials[index]
                                                    .layerType ==
                                                "AR"
                                            ? othersMaterials[index].imgSeq![0]
                                            : othersMaterials[index].gif,
                                      ),
                                    ),
                                    title: Text(
                                      "${othersMaterials[index].layerType} by ${othersMaterials[index].ownerName}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Visibility(
                                visible: myItems.isNotEmpty,
                                replacement: Center(
                                  child: Text(
                                    "Owner has not added any Materials for free with this video!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: constantColors.bioBg,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: myItems.length,
                                  itemBuilder: (context, index) {
                                    return ValueListenableBuilder<bool>(
                                        valueListenable:
                                            myItems[index].selected,
                                        builder: (context, selected, _) {
                                          return ListTile(
                                            leading: Container(
                                              height: 40,
                                              width: 40,
                                              child: ImageNetworkLoader(
                                                imageUrl: myItems[index]
                                                            .layerType ==
                                                        "AR"
                                                    ? myItems[index].imgSeq![0]
                                                    : myItems[index].gif,
                                              ),
                                            ),
                                            trailing: myItems[index]
                                                        .layerType !=
                                                    "Music"
                                                ? Checkbox(
                                                    value: myItems[index]
                                                        .selected
                                                        .value,
                                                    onChanged: (val) {
                                                      myItems[index]
                                                          .selected
                                                          .value = val!;

                                                      log(myItems
                                                          .where((element) =>
                                                              element.selected
                                                                  .value ==
                                                              true)
                                                          .toList()
                                                          .length
                                                          .toString());
                                                    },
                                                  )
                                                : myItems[index]
                                                        .songUrl!
                                                        .contains(
                                                            "www.youtube.com")
                                                    ? InkWell(
                                                        onTap: () async {
                                                          final url =
                                                              myItems[index]
                                                                  .songUrl!;
                                                          if (await canLaunch(
                                                              url)) {
                                                            await launch(
                                                              url,
                                                              forceSafariVC:
                                                                  false,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Text(
                                                            "Youtube",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () {
                                                          controller.pause();
                                                          Navigator.push(
                                                            context,
                                                            PageTransition(
                                                                child:
                                                                    AudioPlayerScreen(
                                                                  albumCover: video
                                                                      .userimage,
                                                                  audioUrl: myItems[
                                                                          index]
                                                                      .songUrl!,
                                                                  songTitle: myItems[
                                                                          index]
                                                                      .songTitle!,
                                                                  artistName: myItems[
                                                                          index]
                                                                      .ownerName,
                                                                ),
                                                                type: PageTransitionType
                                                                    .rightToLeft),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Text(
                                                            "Play",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                            title: Text(
                                              // !Found this here;
                                              "${myItems[index].layerType} by ${myItems[index].ownerName}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: myItems[index].usage !=
                                                    null
                                                ? Row(
                                                    children: [
                                                      TextButton.icon(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                          Icons.arrow_forward,
                                                          color: constantColors
                                                              .bioBg,
                                                        ),
                                                        label: Text(
                                                          "As ${snapshot.data!.docs[index]['usage']}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                          );
                                        });
                                  },
                                ),
                              ),
                              Divider(
                                color: constantColors.whiteColor,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
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
                                        if (myItems
                                            .where((element) =>
                                                element.selected.value == true)
                                            .toList()
                                            .isNotEmpty) {
                                          final List<String> materialIds = [];
                                          myItems
                                              .where((element) =>
                                                  element.selected.value ==
                                                  true)
                                              .toList()
                                              .forEach((element) {
                                            materialIds.add(element.id);
                                            log(element.id);
                                          });

                                          log("items added");
                                          // // ignore: unawaited_futures
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.loading,
                                            text: "Saving to your collection",
                                            barrierDismissible: false,
                                          );
                                          await firebaseOperations
                                              .addToMyCollection(
                                            videoOwnerId: video!.useruid,
                                            videoItem: video!,
                                            isFree: video!.isFree,
                                            ctx: context,
                                            videoId: video!.id,
                                            materialIds: materialIds,
                                          );
                                        } else {
                                          await Get.dialog(
                                            SimpleDialog(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                      "No items selected to add to your inventory!"),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      // paymentController.makePayment(
                                      //     amount: "10", currency: "USD"),
                                      child: Text(
                                        video!.videoType == "video"
                                            ? LocaleKeys.addtomymaterials.tr()
                                            : LocaleKeys.addtoarviewcollection
                                                .tr(),
                                        style: TextStyle(
                                          color: constantColors.navButton,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> reportVideoMenu(BuildContext context) {
    List<String> reportingReasons = [
      LocaleKeys.itsspam.tr(),
      LocaleKeys.nudityorsexualactivity.tr(),
      LocaleKeys.hatespeechorsymbols.tr(),
      LocaleKeys.ijustdontlikeit.tr(),
      LocaleKeys.bullyingorharassment.tr(),
      LocaleKeys.falseinformation.tr(),
      LocaleKeys.violenceordangerousorganizations.tr(),
      LocaleKeys.scamorfraud.tr(),
      LocaleKeys.intellectualpropertyviolation.tr(),
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
                    LocaleKeys.reportvideo.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                LocaleKeys.whyareyoureportingthispost.tr(),
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
                            LocaleKeys.videoreported.tr(),
                            LocaleKeys.thankyouforlettingusknow.tr(),
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
