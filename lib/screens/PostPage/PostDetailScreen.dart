// ignore_for_file: cascade_invocations, unawaited_futures

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/PostPage/editPreviewVideo.dart';
import 'package:diamon_rose_app/screens/PostPage/postMaterialModel.dart';
import 'package:diamon_rose_app/screens/ProfilePage/buyCaratScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/OptionsWidget.dart';
import 'package:diamon_rose_app/widgets/ShareWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:diamon_rose_app/widgets/readMoreWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:screen_capture_event/screen_capture_event.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsScreen extends StatefulWidget {
  final String videoId;

  PostDetailsScreen({required this.videoId});

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  final ConstantColors constantColors = ConstantColors();

  Video? video;
  bool loading = true;

  final ScreenCaptureEvent screenListener = ScreenCaptureEvent();

  // get firebase video from video id
  Future<Video> getVideo() async {
    return await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.videoId)
        .get()
        .then((value) {
      return Video.fromJson(value.data()!);
    });
    // return video;
  }

  @override
  void initState() {
    log("this right");
    getVideo().then((value) {
      setState(() {
        _videoPlayerController = VideoPlayerController.network(value.videourl);
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          showControls: false,
          aspectRatio: 9 / 16,
          autoPlay: false,
          looping: true,
          autoInitialize: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
        video = value;
        loading = false;
      });

      if (value.useruid != context.read<Authentication>().getUserId) {
        context.read<FirebaseOperations>().updatePostView(
              videoId: value.id,
              useruidVal: context.read<Authentication>().getUserId,
              videoVal: value,
            );
      }
    });
    log("detecting screenshory now");
    screenListener.addScreenRecordListener((recorded) {
      ///Recorded was your record status (bool)
      if (video!.isPaid) {
        showScreenrecordWarningMsg();
      }
    });

    screenListener.addScreenShotListener((filePath) {
      ///filePath only available for Android
      if (video!.isPaid) {
        showScreenshotWarningMsg();
      }
    });
    screenListener.watch();

    super.initState();
  }

  Future<dynamic> otherUserOptionsMenu(
      {required BuildContext context, required Video video}) {
    final List<String> optionsList = [
      LocaleKeys.deletepost.tr(),
      LocaleKeys.editpost.tr(),
    ];
    final List<void Function()> functionsList = [
      () {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.info,
            title: "Delete Video?",
            text: "Are you sure you want to delete this video?",
            showCancelBtn: true,
            onConfirmBtnTap: () async {
              await context
                  .read<FirebaseOperations>()
                  .deleteVideoPost(videoid: widget.videoId)
                  .then((value) {
                Get.back();
                Get.back();
                Get.back();
              });
            });
      },
      () {
        Get.to(EditPreviewVideoScreen(
          videoFile: video,
        ));
      },
    ];
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SafeArea(
          bottom: Platform.isAndroid ? true : false,
          child: Container(
            padding: EdgeInsets.all(15),
            height: 25.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: constantColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Container(
              child: ListView.builder(
                itemCount: optionsList.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Options(
                    tapped: functionsList[index],
                    text: optionsList[index],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (video != null)
      return (video!.isPaid &&
              !video!.boughtBy
                  .contains(context.read<Authentication>().getUserId) &&
              video!.useruid != context.read<Authentication>().getUserId)
          ? paidVideoNotBought(context)
          : VideoBoughtAndViewable(context);
    else
      return Center(
        child: CircularProgressIndicator(),
      );
  }

  Widget VideoBoughtAndViewable(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isAndroid ? true : false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: VisibilityDetector(
          key: Key(
              '${video!.videotitle} + ${video!.caption} + ${DateTime.now()}'),
          onVisibilityChanged: (visibilityInfo) {
            var visiblePercentage = visibilityInfo.visibleFraction * 100;
            if (visiblePercentage == 100) {
              log("${video!.videotitle} played");
              _videoPlayerController.play();
            } else {
              log("${video!.videotitle} paused");
              _videoPlayerController.pause();
            }
          },
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _videoPlayerController.value.isPlaying
                      ? _videoPlayerController.pause()
                      : _videoPlayerController.play();
                },
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
              Visibility(
                visible: video!.isPaid &&
                    !video!.boughtBy
                        .contains(context.read<Authentication>().getUserId) &&
                    video!.useruid != context.read<Authentication>().getUserId,
                child: Positioned(
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
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
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
              ),
              // back button
              Positioned(
                top: 10.h,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Visibility(
                visible: video!.useruid ==
                        Provider.of<Authentication>(context, listen: false)
                            .getUserId ||
                    adminUserId
                        .contains(context.read<Authentication>().getUserId),
                child: Positioned(
                  top: 10.h,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      //  ! options here
                      setState(() {
                        _videoPlayerController.value.isPlaying
                            ? _videoPlayerController.pause()
                            : null;
                      });

                      otherUserOptionsMenu(context: context, video: video!);
                    },
                  ),
                ),
              ),
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
                              context,
                            )
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
                            await DynamicLinkService.createDynamicLink(
                                video!.id,
                                short: true);
                        final String message = generatedLink.toString();

                        bool canShareVal = false;

                        if (video!.isPaid) {
                          if (video!.boughtBy.contains(
                              context.read<Authentication>().getUserId)) {
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
                        await Provider.of<FirebaseOperations>(context,
                                listen: false)
                            .messageUser(
                                messagingUid: video!.useruid,
                                messagingDocId: Provider.of<Authentication>(
                                        context,
                                        listen: false)
                                    .getUserId,
                                messagingData: {
                                  'username': Provider.of<FirebaseOperations>(
                                          context,
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
                                              sendToUserToken:
                                                  video!.ownerFcmToken!,
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
                              .doc(Provider.of<Authentication>(context,
                                      listen: false)
                                  .getUserId)
                              .collection("favorites")
                              .doc(video!.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                        .addToFavs(
                                            video: video!, context: context);
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
                            image: Image.network(video!.userimage).image,
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
          ),
        ),
      ),
    );
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
          top: 10.h,
          left: 10,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Visibility(
          visible: video!.useruid ==
                  Provider.of<Authentication>(context, listen: false)
                      .getUserId ||
              adminUserId.contains(context.read<Authentication>().getUserId),
          child: Positioned(
            top: 10.h,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                //  ! options here
                setState(() {
                  _videoPlayerController.value.isPlaying
                      ? _videoPlayerController.pause()
                      : null;
                });

                otherUserOptionsMenu(context: context, video: video!);
              },
            ),
          ),
        ),
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
                        context,
                      )
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
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: Image.network(video!.userimage).image,
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
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  child: PostDetailsScreen(
                                                    videoId:
                                                        othersMaterials[index]
                                                            .videoId!,
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
                                                  "Are you sure you want to spend ${((video!.price) * (1 - video!.discountAmount / 100)).toStringAsFixed(2)} Carats?",
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
                                                            (video!.price) *
                                                                (1 -
                                                                    video!.discountAmount /
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
                                                          log("old timestamp == ${video!.timestamp.toDate()}");

                                                          video!.timestamp =
                                                              Timestamp.now();

                                                          log("new timestamp == ${video!.timestamp.toDate()}");

                                                          log("Total price here  = $totalPrice");
                                                          log("here ${video!.timestamp}");
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
                                                                      video!
                                                                          .useruid,
                                                                  amount:
                                                                      totalPrice
                                                                          .toInt(),
                                                                  videoItem:
                                                                      video!,
                                                                  isFree: video!
                                                                      .isFree,
                                                                  videoId:
                                                                      video!.id,
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
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      super
                                                                          .widget));
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
                              // await  context.read<FirebaseOperations>()
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
    BuildContext context,
  ) async {
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
                          .doc(video!.id)
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
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: PostDetailsScreen(
                                                      videoId:
                                                          othersMaterials[index]
                                                              .videoId!,
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
                                            trailing: Checkbox(
                                              value:
                                                  myItems[index].selected.value,
                                              onChanged: (val) {
                                                myItems[index].selected.value =
                                                    val!;

                                                log(myItems
                                                    .where((element) =>
                                                        element
                                                            .selected.value ==
                                                        true)
                                                    .toList()
                                                    .length
                                                    .toString());
                                              },
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
                                          });
                                          // // ignore: unawaited_futures
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.loading,
                                            text: "Saving to your collection",
                                            barrierDismissible: false,
                                          );
                                          await context
                                              .read<FirebaseOperations>()
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

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    screenListener.dispose();

    super.dispose();
  }
}
