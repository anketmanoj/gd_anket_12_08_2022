import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/editPreviewVideo.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/OptionsWidget.dart';
import 'package:diamon_rose_app/widgets/ShareWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
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

  // get firebase video from video id
  Future<Video> getVideo() async {
    return await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.videoId)
        .get()
        .then((value) {
      setState(() {
        video = Video.fromJson(value.data()! as Map<String, dynamic>);
      });
      return video!;
    });
    // return video;
  }

  // Future<void> initPayment(
  //     {required String email,
  //     required String amount,
  //     required BuildContext ctx}) async {
  //   try {
  //     // * create a payment intent on the server
  //     final response = await http.post(
  //       Uri.parse(
  //           "https://us-central1-gdfe-ac584.cloudfunctions.net/stripePaymentIntentRequest"),
  //       body: {
  //         'email': email,
  //         'amount': amount,
  //       },
  //     );

  //     final jsonResponse = jsonDecode(response.body);
  //     // initailize the payment sheet
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         applePay: true,
  //         googlePay: true,
  //         paymentIntentClientSecret: jsonResponse['paymentIntent'],
  //         merchantDisplayName: "Glamorous Diastation",
  //         customerId: jsonResponse['customer'],
  //         customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
  //         testEnv: true,
  //         merchantCountryCode: 'US',
  //       ),
  //     );

  //     await Stripe.instance.presentPaymentSheet();
  //     showTopSnackBar(
  //       ctx,
  //       CustomSnackBar.success(
  //         message: "Payment Successful",
  //       ),
  //     );

  //     CoolAlert.show(
  //       context: context,
  //       type: CoolAlertType.loading,
  //       text: "Saving to your collection",
  //       barrierDismissible: false,
  //     );
  //     await Provider.of<FirebaseOperations>(context, listen: false)
  //         .addToMyCollection(
  //       videoOwnerId: video!.useruid,
  //       amount: int.parse((double.parse(amount) / 100).toStringAsFixed(0)),
  //       videoItem: video!,
  //       isFree: video!.isFree,
  //       ctx: context,
  //       videoId: video!.id,
  //     );
  //     // ignore: avoid_catches_without_on_clauses
  //   } catch (e) {
  //     print(e.toString());
  //     if (e is StripeException) {
  //       showTopSnackBar(
  //         ctx,
  //         CustomSnackBar.error(
  //           message: "Payment Error ${e.error.localizedMessage}",
  //         ),
  //       );
  //     } else {
  //       showTopSnackBar(
  //         ctx,
  //         CustomSnackBar.error(
  //           message: "Payment Error ${e.toString()}",
  //         ),
  //       );
  //     }
  //   }
  // }

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
          autoPlay: true,
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
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);

    Future<dynamic> otherUserOptionsMenu(
        {required BuildContext context, required Video video}) {
      final List<String> optionsList = [
        "Delete Post",
        "Edit Post",
      ];
      final List<void Function()> functionsList = [
        () {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.info,
              title: "Delete Video?",
              text: "Are you sure you want to delete this video?",
              onConfirmBtnTap: () async {
                await firebaseOperations
                    .deleteVideoPost(videoid: widget.videoId)
                    .then((value) {
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

    return VisibilityDetector(
      key: Key('${video!.videotitle} + ${video!.caption}'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage == 0) {
          log("${video!.videotitle} paused");
          _videoPlayerController.pause();
        } else {
          log("${video!.videotitle} played");
          _videoPlayerController.play();
        }
      },
      child: SafeArea(
        top: false,
        bottom: Platform.isAndroid ? true : false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: loading == false
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _videoPlayerController.value.isPlaying
                              ? _videoPlayerController.pause()
                              : _videoPlayerController.play();
                        });
                      },
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                    // back button
                    Positioned(
                      top: size.height * 0.1,
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
                              .getUserId,
                      child: Positioned(
                        top: size.height * 0.1,
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

                            otherUserOptionsMenu(
                                context: context, video: video!);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
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
                                firebaseOperations.goToUserProfile(
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
                                        image: Image.network(video!.userimage)
                                            .image,
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
                                                    ..style =
                                                        PaintingStyle.stroke
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
                                            visible:
                                                video!.verifiedUser ?? false,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
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
                                  // Stroked text as border.
                                  Text(
                                    video!.caption,
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
                                    video!.caption,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
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
                        childrenButtonSize:
                            Size(size.width * 0.2, size.height * 0.09),
                        childPadding: EdgeInsets.all(10),
                        overlayOpacity: 0,
                        // animatedIcon: AnimatedIcons.menu_close,
                        spacing: size.height * 0.002,
                        animatedIcon: AnimatedIcons.menu_close,
                        closeManually: false,
                        children: [
                          SpeedDialChild(
                            visible: video!.isPaid == false,
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
                                  return SafeArea(
                                    bottom: Platform.isAndroid ? true : false,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
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
                                            "Items",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            height: size.height * 0.3,
                                            width: size.width,
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("posts")
                                                    .doc(video!.id)
                                                    .collection("materials")
                                                    .where("hideItem",
                                                        isEqualTo: false)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return ListView.builder(
                                                      itemCount: snapshot
                                                          .data!.docs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return snapshot.data!
                                                                            .docs[
                                                                        index][
                                                                    "ownerId"] ==
                                                                video!.useruid
                                                            ? ListTile(
                                                                leading: Container(
                                                                    height: 40,
                                                                    width: 40,
                                                                    child: ImageNetworkLoader(
                                                                        imageUrl: snapshot
                                                                            .data!
                                                                            .docs[index]["gif"])),
                                                                title: Text(
                                                                  "${snapshot.data!.docs[index]["layerType"]} by ${video!.username}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                trailing: (snapshot.data!.docs[index].data() as Map<
                                                                            String,
                                                                            dynamic>)
                                                                        .containsKey(
                                                                            "usage")
                                                                    ? Text(
                                                                        "${snapshot.data!.docs[index]["usage"]}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      )
                                                                    : null,
                                                              )
                                                            : ListTile(
                                                                tileColor:
                                                                    constantColors
                                                                        .bioBg,
                                                                trailing:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 80,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          PageTransition(
                                                                              child: PostDetailsScreen(
                                                                                videoId: snapshot.data!.docs[index]["videoId"],
                                                                              ),
                                                                              type: PageTransitionType.fade));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              "Visit Owner",
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
                                                                  "Owned by ${snapshot.data!.docs[index]["ownerName"]}",
                                                                ),
                                                                leading:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  child: ImageNetworkLoader(
                                                                      imageUrl: snapshot
                                                                          .data!
                                                                          .docs[index]["gif"]),
                                                                ),
                                                                title: Text(
                                                                  "${snapshot.data!.docs[index]["layerType"]} by ${snapshot.data!.docs[index]["ownerName"]}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
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
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment: video!.isPaid
                                                  ? MainAxisAlignment
                                                      .spaceBetween
                                                  : MainAxisAlignment.center,
                                              children: [
                                                video!.isPaid
                                                    ? video!.discountAmount == 0
                                                        ? Text(
                                                            "Total: \$${video!.price}",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        : video!.discountAmount >=
                                                                    0 &&
                                                                DateTime.now()
                                                                    .isAfter((video!
                                                                            .startDiscountDate)
                                                                        .toDate()) &&
                                                                DateTime.now()
                                                                    .isBefore((video!
                                                                            .endDiscountDate)
                                                                        .toDate())
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    "Total: ",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    " \$${video!.price}",
                                                                    style:
                                                                        TextStyle(
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    " \$${video!.price * (1 - video!.discountAmount / 100)}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                "Total: \$${video!.price}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                    : Container(),
                                                video!.isPaid
                                                    ? ElevatedButton(
                                                        style: ButtonStyle(
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                          backgroundColor:
                                                              MaterialStateProperty.all<
                                                                      Color>(
                                                                  constantColors
                                                                      .bioBg),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          // await initPayment(
                                                          //   ctx: context,
                                                          //   amount:
                                                          //       "${video!.price * (1 - video!.discountAmount / 100) * 100}",
                                                          //   email:
                                                          //       firebaseOperations
                                                          //           .initUserEmail,
                                                          // );
                                                        },
                                                        // paymentController.makePayment(
                                                        //     amount: "10", currency: "USD"),
                                                        child: Text(
                                                          "Purchase",
                                                          style: TextStyle(
                                                            color:
                                                                constantColors
                                                                    .navButton,
                                                          ),
                                                        ),
                                                      )
                                                    : ElevatedButton(
                                                        style: ButtonStyle(
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                          backgroundColor:
                                                              MaterialStateProperty.all<
                                                                      Color>(
                                                                  constantColors
                                                                      .bioBg),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          // ignore: unawaited_futures
                                                          CoolAlert.show(
                                                            context: context,
                                                            type: CoolAlertType
                                                                .loading,
                                                            text:
                                                                "Saving to your collection",
                                                            barrierDismissible:
                                                                false,
                                                          );
                                                          await firebaseOperations
                                                              .addToMyCollection(
                                                            videoOwnerId:
                                                                video!.useruid,
                                                            videoItem: video!,
                                                            isFree:
                                                                video!.isFree,
                                                            ctx: context,
                                                            videoId: video!.id,
                                                          );
                                                        },
                                                        // paymentController.makePayment(
                                                        //     amount: "10", currency: "USD"),
                                                        child: Text(
                                                          "Add To My Inventory",
                                                          style: TextStyle(
                                                            color:
                                                                constantColors
                                                                    .navButton,
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
                                      video!.id,
                                      short: true);
                              final String message = generatedLink.toString();

                              Get.bottomSheet(
                                ShareWidget(
                                    msg: message, urlPath: video!.videourl),
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
                                      messagingDocId:
                                          Provider.of<Authentication>(context,
                                                  listen: false)
                                              .getUserId,
                                      messagingData: {
                                        'username':
                                            Provider.of<FirebaseOperations>(
                                                    context,
                                                    listen: false)
                                                .getInitUserName,
                                        'userimage':
                                            Provider.of<FirebaseOperations>(
                                                    context,
                                                    listen: false)
                                                .getInitUserImage,
                                        'useremail':
                                            Provider.of<FirebaseOperations>(
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
                                      .doc(authentication.getUserId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data!.exists) {
                                        return IconButton(
                                          onPressed: () {
                                            firebaseOperations.deleteLikePost(
                                                postUid: video!.id,
                                                userUid:
                                                    authentication.getUserId,
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
                                                    video!.ownerFcmToken!,
                                                likerUsername:
                                                    firebaseOperations
                                                        .initUserName,
                                                postUid: video!.id,
                                                userUid:
                                                    authentication.getUserId,
                                                context: context,
                                              )
                                                  .then((value) {
                                                firebaseOperations
                                                    .addLikeNotification(
                                                  postId: video!.id,
                                                  userUid:
                                                      authentication.getUserId,
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
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    if (snapshot.data!.exists) {
                                      return IconButton(
                                        onPressed: () async {
                                          await firebaseOperations
                                              .removeFromFavs(
                                                  video: video!,
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
                                          await firebaseOperations.addToFavs(
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
                              firebaseOperations.goToUserProfile(
                                  userUid: video!.useruid, context: context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();

    super.dispose();
  }
}
