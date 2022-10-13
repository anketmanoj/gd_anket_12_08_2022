// ignore_for_file: sort_constructors_first, avoid_bool_literals_in_conditional_expressions

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/stripe_payment_services/controllers/payment_controllers.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/ShareWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class VideoPostItem extends StatefulWidget {
  final Video video;

  VideoPostItem({required this.video});

  @override
  _VideoPostItemState createState() => _VideoPostItemState();
}

class _VideoPostItemState extends State<VideoPostItem> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  final ConstantColors constantColors = ConstantColors();
  bool isHeartAnimation = false;
  bool blur = false;
  late Timer timer;
  Authentication authentication = Authentication();

  @override
  void initState() {
    super.initState();

    context.read<FirebaseOperations>().updatePostView(
          videoId: widget.video.id,
          useruidVal: context.read<Authentication>().getUserId,
          videoVal: widget.video,
        );

    _videoPlayerController =
        VideoPlayerController.network(widget.video.videourl);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 2160 / 3840,
      autoInitialize: true,
      showControls: false,
      autoPlay: true,
      looping: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
    timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer sec) {
        if (widget.video.isPaid &&
            _chewieController.videoPlayerController.value.isInitialized &&
            blur == false &&
            !widget.video.boughtBy.contains(
                Provider.of<Authentication>(context, listen: false)
                    .getUserId) &&
            widget.video.useruid !=
                Provider.of<Authentication>(context, listen: false).getUserId) {
          if (_chewieController
                  .videoPlayerController.value.position.inSeconds >=
              (_chewieController
                      .videoPlayerController.value.duration.inSeconds *
                  0.4)) {
            setState(() {
              blur = true;
              _chewieController.videoPlayerController.pause();
            });
          }
        }
      },
    );
  }

//   Future<void> initPayment(
//       {required String email,
//       required String amount,
//       required BuildContext ctx}) async {
//     try {
//       // * create a payment intent on the server
//       final response = await http.post(
//         Uri.parse(
//             "https://us-central1-gdfe-ac584.cloudfunctions.net/stripePaymentIntentRequest"),
//         body: {
//           'email': email,
//           'amount': amount,
//         },
//       );

//       final jsonResponse = jsonDecode(response.body);
//       // initailize the payment sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           applePay: true,
//           googlePay: true,
//           paymentIntentClientSecret: jsonResponse['paymentIntent'],
//           merchantDisplayName: "Glamorous Diastation",
//           customerId: jsonResponse['customer'],
//           customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
//           testEnv: true,
//           merchantCountryCode: 'US',
//         ),
//       );

//       await Stripe.instance.presentPaymentSheet();
//       showTopSnackBar(
//         ctx,
//         CustomSnackBar.success(
//           message: "Payment Successful",
//         ),
//       );

//       setState(() {
//         blur = false;
//       });
// // ! Apple payment method
//       // await Stripe.instance.presentApplePay(
//       //   ApplePayPresentParams(
//       //     cartItems: [
//       //       ApplePayCartSummaryItem(
//       //         label: "test",
//       //         amount: (double.parse(amount) / 100).toStringAsFixed(0),
//       //       )
//       //     ],
//       //     currency: "USD",
//       //     country: "US",
//       //   ),
//       // );

//       CoolAlert.show(
//         context: context,
//         type: CoolAlertType.loading,
//         text: "Saving to your collection",
//         barrierDismissible: false,
//       );

//       await Provider.of<FirebaseOperations>(context, listen: false)
//           .addToMyCollection(
//         videoOwnerId: widget.video.useruid,
//         amount: int.parse((double.parse(amount) / 100).toStringAsFixed(0)),
//         videoItem: widget.video,
//         isFree: widget.video.isFree,
//         ctx: context,
//         videoId: widget.video.id,
//       );
//       // ignore: avoid_catches_without_on_clauses
//     } catch (e) {
//       print(e.toString());
//       if (e is StripeException) {
//         showTopSnackBar(
//           ctx,
//           CustomSnackBar.error(
//             message: "Payment Error ${e.error.localizedMessage}",
//           ),
//         );
//       } else {
//         showTopSnackBar(
//           ctx,
//           CustomSnackBar.error(
//             message: "Payment Error ${e.toString()}",
//           ),
//         );
//       }
//     }
//   }

//   Future<void> initApplePayment(
//       {required String email,
//       required String amount,
//       required BuildContext ctx}) async {
//     try {
//       // * create a payment intent on the server
//       final response = await http.post(
//         Uri.parse(
//             "https://us-central1-gdfe-ac584.cloudfunctions.net/stripePaymentIntentRequest"),
//         body: {
//           'email': email,
//           'amount': amount,
//         },
//       );

//       final jsonResponse = jsonDecode(response.body);
//       // initailize the payment sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           applePay: true,
//           googlePay: true,
//           paymentIntentClientSecret: jsonResponse['client_secret'],
//           merchantDisplayName: "Glamorous Diastation",
//           customerId: jsonResponse['customer'],
//           customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
//           testEnv: true,
//           merchantCountryCode: 'US',
//         ),
//       );

//       //  await Stripe.instance.apple

//       final bool appleDone = await ApplePay(amount);

//       if (appleDone == true) {
//         showTopSnackBar(
//           ctx,
//           CustomSnackBar.success(
//             message: "Payment Successful",
//           ),
//         );

//         CoolAlert.show(
//           context: context,
//           type: CoolAlertType.loading,
//           text: "Saving to your collection",
//           barrierDismissible: false,
//         );

//         await Provider.of<FirebaseOperations>(context, listen: false)
//             .addToMyCollection(
//           videoOwnerId: widget.video.useruid,
//           amount: int.parse((double.parse(amount) / 100).toStringAsFixed(0)),
//           videoItem: widget.video,
//           isFree: widget.video.isFree,
//           ctx: context,
//           videoId: widget.video.id,
//         );
//       }
//       // ignore: avoid_catches_without_on_clauses
//     } catch (e) {
//       print(e.toString());
//       if (e is StripeException) {
//         showTopSnackBar(
//           ctx,
//           CustomSnackBar.error(
//             message: "Payment Error ${e.error.localizedMessage}",
//           ),
//         );
//       } else {
//         showTopSnackBar(
//           ctx,
//           CustomSnackBar.error(
//             message: "Payment Error ${e.toString()}",
//           ),
//         );
//       }
//     }
//   }

//   Future<bool> ApplePay(String amount) async {
//     try {
//       await Stripe.instance.presentApplePay(
//         ApplePayPresentParams(
//           cartItems: [
//             ApplePayCartSummaryItem(
//               label: widget.video.videotitle,
//               amount: (double.parse(amount) / 100).toStringAsFixed(0),
//             )
//           ],
//           currency: "USD",
//           requiredBillingContactFields: [
//             ApplePayContactFieldsType.name,
//             ApplePayContactFieldsType.emailAddress,
//             ApplePayContactFieldsType.phoneNumber,
//           ],
//           country: "US",
//         ),
//       );
//       log("true value");
//       return true;
//     } catch (e) {
//       log("error === $e");
//       return false;
//     }
//   }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.put(PaymentController());
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () async {
            setState(() {
              isHeartAnimation = true;
            });
            print("isHeartAnimation: $isHeartAnimation");
            await firebaseOperations
                .likePost(
              sendToUserToken: widget.video.ownerFcmToken!,
              likerUsername: firebaseOperations.initUserName,
              postUid: widget.video.id,
              userUid: authentication.getUserId,
              context: context,
            )
                .then((value) {
              firebaseOperations.addLikeNotification(
                postId: widget.video.id,
                userUid: authentication.getUserId,
                context: context,
                videoOwnerUid: widget.video.useruid,
              );
            });
          },
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
        Positioned(
          child: Center(
            child: blur
                ? BlurryContainer(
                    blur: 10,
                    width: size.width,
                    height: size.height,
                    elevation: 0,
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
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
                                          widget.video.videoType == "video"
                                              ? "Items"
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
                                                  .doc(widget.video.id)
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
                                                                      index]
                                                                  ["ownerId"] ==
                                                              widget
                                                                  .video.useruid
                                                          ? ListTile(
                                                              leading:
                                                                  Container(
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
                                                                "${snapshot.data!.docs[index]["layerType"]} by ${widget.video.username}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            )
                                                          : ListTile(
                                                              tileColor:
                                                                  constantColors
                                                                      .bioBg,
                                                              trailing:
                                                                  Container(
                                                                height: 50,
                                                                width: 80,
                                                                child: InkWell(
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
                                                                    height: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .black,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                            LocaleKeys.visitowner.tr(),
                                                                            style:
                                                                                TextStyle(
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
                                                                "${LocaleKeys.ownedby.tr()} ${snapshot.data!.docs[index]["ownerName"]}",
                                                              ),
                                                              leading:
                                                                  Container(
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
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
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
                                            mainAxisAlignment: widget
                                                    .video.isPaid
                                                ? MainAxisAlignment.spaceBetween
                                                : MainAxisAlignment.center,
                                            children: [
                                              widget.video.isPaid
                                                  ? widget.video
                                                              .discountAmount ==
                                                          0
                                                      ? Text(
                                                          "Total: \$${widget.video.price}",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : widget.video.discountAmount >=
                                                                  0 &&
                                                              DateTime.now()
                                                                  .isAfter((widget
                                                                          .video
                                                                          .startDiscountDate)
                                                                      .toDate()) &&
                                                              DateTime.now()
                                                                  .isBefore((widget
                                                                          .video
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
                                                                  " \$${widget.video.price}",
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
                                                                  " \$${widget.video.price * (1 - widget.video.discountAmount / 100)}",
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
                                                              "Total: \$${widget.video.price}",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                  : Container(),
                                              widget.video.isPaid
                                                  ? ElevatedButton(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
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
                                                        await selectPaymentOptionsSheet(
                                                            ctx: context,
                                                            firebaseOperations:
                                                                firebaseOperations);
                                                      },
                                                      // paymentController.makePayment(
                                                      //     amount: "10", currency: "USD"),
                                                      child: Text(
                                                        "Purchase",
                                                        style: TextStyle(
                                                          color: constantColors
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
                                                            MaterialStateProperty
                                                                .all<Color>(
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
                                                          videoOwnerId: widget
                                                              .video.useruid,
                                                          videoItem:
                                                              widget.video,
                                                          isFree: widget
                                                              .video.isFree,
                                                          ctx: context,
                                                          videoId:
                                                              widget.video.id,
                                                        );
                                                      },
                                                      // paymentController.makePayment(
                                                      //     amount: "10", currency: "USD"),
                                                      child: Text(
                                                        "Add To My Inventory",
                                                        style: TextStyle(
                                                          color: constantColors
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
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: constantColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Click to buy this content to view the full video!",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: constantColors.navButton,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: isHeartAnimation ? 1 : 0,
            child: HeartAnimationwidget(
              onEnd: () {
                setState(() {
                  isHeartAnimation = false;
                });
              },
              isAnimating: isHeartAnimation,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.5),
                size: 100,
              ),
            ),
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
                    _chewieController.videoPlayerController.pause();
                    firebaseOperations.goToUserProfile(
                        userUid: widget.video.useruid, context: context);
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: Image.network(widget.video.userimage).image,
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
                                    widget.video.username,
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
                                    widget.video.username,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: widget.video.verifiedUser ?? false,
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
                        widget.video.videotitle,
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
                        widget.video.videotitle,
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
                        widget.video.caption,
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
                        widget.video.caption,
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
                        timeago.format((widget.video.timestamp).toDate()),
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
                        timeago.format((widget.video.timestamp).toDate()),
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
            childrenButtonSize: Size(size.width * 0.2, size.height * 0.08),
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
                // visible: widget.video.isPaid,
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
                                widget.video.videoType == "video"
                                    ? "Items"
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
                                        .doc(widget.video.id)
                                        .collection("materials")
                                        .where("hideItem", isEqualTo: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return snapshot.data!.docs[index]
                                                        ["ownerId"] ==
                                                    widget.video.useruid
                                                ? ListTile(
                                                    leading: Container(
                                                      height: 40,
                                                      width: 40,
                                                      child: ImageNetworkLoader(
                                                        imageUrl: snapshot.data!
                                                            .docs[index]["gif"],
                                                      ),
                                                    ),
                                                    title: Text(
                                                      "${snapshot.data!.docs[index]["layerType"]} by ${widget.video.username}",
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
                                                                  type: PageTransitionType
                                                                      .fade));
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black,
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
                                                                child: Text(
                                                                  LocaleKeys
                                                                      .visitowner
                                                                      .tr(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
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
                                                      "${LocaleKeys.ownedby.tr()} ${snapshot.data!.docs[index]["ownerName"]}",
                                                    ),
                                                    leading: Container(
                                                      height: 40,
                                                      width: 40,
                                                      child: ImageNetworkLoader(
                                                        imageUrl: snapshot.data!
                                                            .docs[index]["gif"],
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
                                  mainAxisAlignment: widget.video.isPaid
                                      ? MainAxisAlignment.spaceBetween
                                      : MainAxisAlignment.center,
                                  children: [
                                    widget.video.isPaid
                                        ? widget.video.discountAmount == 0
                                            ? Text(
                                                "Total: \$${widget.video.price}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : widget.video.discountAmount >=
                                                        0 &&
                                                    DateTime.now().isAfter((widget
                                                            .video
                                                            .startDiscountDate)
                                                        .toDate()) &&
                                                    DateTime.now().isBefore(
                                                        (widget.video
                                                                .endDiscountDate)
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
                                                        " \$${widget.video.price}",
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        " \$${widget.video.price * (1 - widget.video.discountAmount / 100)}",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    "Total: \$${widget.video.price}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                        : Container(),
                                    widget.video.isPaid
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
                                              await selectPaymentOptionsSheet(
                                                  ctx: context,
                                                  firebaseOperations:
                                                      firebaseOperations);
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
                                                text:
                                                    "Saving to your collection",
                                                barrierDismissible: false,
                                              );
                                              await firebaseOperations
                                                  .addToMyCollection(
                                                videoOwnerId:
                                                    widget.video.useruid,
                                                videoItem: widget.video,
                                                isFree: widget.video.isFree,
                                                ctx: context,
                                                videoId: widget.video.id,
                                              );
                                            },
                                            // paymentController.makePayment(
                                            //     amount: "10", currency: "USD"),
                                            child: Text(
                                              widget.video.videoType == "video"
                                                  ? LocaleKeys.addToMyInventory
                                                      .tr()
                                                  : LocaleKeys
                                                      .addtoarviewcollection
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
                          widget.video.id,
                          short: true);
                  final String message = generatedLink.toString();

                  Get.bottomSheet(
                    ShareWidget(
                      msg: message,
                      urlPath: widget.video.videourl,
                      videoOwnerName: widget.video.username,
                      canShareToSocialMedia: widget.video.boughtBy.contains(
                                  context.read<Authentication>().getUserId) &&
                              widget.video.isPaid ||
                          widget.video.useruid ==
                              context.read<Authentication>().getUserId,
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
                          messagingUid: widget.video.useruid,
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
                          messengerDocId: widget.video.useruid,
                          messengerData: {
                            'username': widget.video.username,
                            'userimage': widget.video.userimage,
                            'useremail': 'test - remove later',
                            'useruid': widget.video.useruid,
                            'time': Timestamp.now(),
                          })
                      .whenComplete(() async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.video.useruid)
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
                          .doc(widget.video.id)
                          .collection("likes")
                          .doc(authentication.getUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.exists) {
                            return IconButton(
                              onPressed: () {
                                firebaseOperations.deleteLikePost(
                                    postUid: widget.video.id,
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
                                        widget.video.ownerFcmToken!,
                                    likerUsername:
                                        firebaseOperations.initUserName,
                                    postUid: widget.video.id,
                                    userUid: authentication.getUserId,
                                    context: context,
                                  )
                                      .then((value) {
                                    firebaseOperations.addLikeNotification(
                                      postId: widget.video.id,
                                      userUid: authentication.getUserId,
                                      context: context,
                                      videoOwnerUid: widget.video.useruid,
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
                              postId: widget.video.id,
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
                            ownerFcmToken: widget.video.ownerFcmToken,
                            postOwnerId: widget.video.useruid,
                            postId: widget.video.id,
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
                        .doc(widget.video.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.data!.exists) {
                          return IconButton(
                            onPressed: () async {
                              await firebaseOperations.removeFromFavs(
                                  video: widget.video, context: context);
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
                                  video: widget.video, context: context);
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
                      image: Image.network(widget.video.userimage).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {
                  firebaseOperations.goToUserProfile(
                      userUid: widget.video.useruid, context: context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> reportVideoMenu(BuildContext context, Size size) {
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
        return SafeArea(
          bottom: Platform.isAndroid ? true : false,
          child: Container(
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
                              video: widget.video,
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    timer.cancel();

    super.dispose();
  }

  Future selectPaymentOptionsSheet(
      {required BuildContext ctx,
      required FirebaseOperations firebaseOperations}) async {
    return showModalBottomSheet(
        context: ctx,
        builder: (ctxIn) {
          return SafeArea(
            bottom: true,
            child: Container(
              // ignore: sort_child_properties_last
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.navButton,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Payment Option",
                          style: TextStyle(
                            color: constantColors.navButton,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () async {
                              // await initApplePayment(
                              //   ctx: ctxIn,
                              //   amount:
                              //       "${widget.video.price * (1 - widget.video.discountAmount / 100) * 100}",
                              //   email: firebaseOperations.initUserEmail,
                              // );
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: constantColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    color: constantColors.whiteColor,
                                  ),
                                  Text(
                                    "Apple Pay",
                                    style: TextStyle(
                                        color: constantColors.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            // await initPayment(
                            //   ctx: ctxIn,
                            //   amount:
                            //       "${widget.video.price * (1 - widget.video.discountAmount / 100) * 100}",
                            //   email: firebaseOperations.initUserEmail,
                            // );
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: constantColors.navButton,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card,
                                    color: constantColors.whiteColor),
                                Text(
                                  "Credit Card",
                                  style: TextStyle(
                                      color: constantColors.whiteColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(ctxIn).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => UsePaypal(
                                      sandboxMode: true,
                                      clientId:
                                          "AQPBczENirTxAJg6rfuzf6H6r7Me5iq0I5Du1Rq3_Arxz0GjNRqc8JtXvcjhyb6QKkClVMGPmSNhqh89",
                                      secretKey:
                                          "ECzrtj1IyGtTwcyMEnHeB8BGJHOoPckUYQztDIXK9Be-pbwJV3sTRfBNL7TCRIC1nqH-W-98j8zxocZM",
                                      returnURL:
                                          "https://samplesite.com/return",
                                      cancelURL:
                                          "https://samplesite.com/cancel",
                                      transactions: [
                                        {
                                          "amount": {
                                            "total":
                                                "${widget.video.price * (1 - widget.video.discountAmount / 100)}",
                                            "currency": "USD",
                                            "details": {
                                              "subtotal":
                                                  "${widget.video.price * (1 - widget.video.discountAmount / 100)}",
                                              "shipping": '0',
                                              "shipping_discount": 0
                                            }
                                          },
                                          "description":
                                              "Total amount for the materials and package from ${widget.video.username}",
                                          // "payment_options": {
                                          //   "allowed_payment_method":
                                          //       "INSTANT_FUNDING_SOURCE"
                                          // },
                                          "item_list": {
                                            "items": [
                                              {
                                                "name":
                                                    "${widget.video.videotitle} | ${widget.video.username}",
                                                "quantity": 1,
                                                "price":
                                                    "${widget.video.price * (1 - widget.video.discountAmount / 100)}",
                                                "currency": "USD"
                                              }
                                            ],

                                            // // shipping address is not required though
                                            // "shipping_address": {
                                            //   "recipient_name": "Jane Foster",
                                            //   "line1": "Travis County",
                                            //   "line2": "",
                                            //   "city": "Austin",
                                            //   "country_code": "US",
                                            //   "postal_code": "73301",
                                            //   "phone": "+00000000",
                                            //   "state": "Texas"
                                            // },
                                          }
                                        }
                                      ],
                                      note:
                                          "Contact us for any questions on your order.",
                                      onSuccess: (Map params) async {
                                        if (params['status'] == "success") {
                                          Get.snackbar(
                                            'Payment Successful!',
                                            'Payment via paypal was successful, the items have been added to your Collection',
                                            overlayColor:
                                                constantColors.navButton,
                                            colorText:
                                                constantColors.whiteColor,
                                            snackPosition: SnackPosition.TOP,
                                            forwardAnimationCurve:
                                                Curves.elasticInOut,
                                            reverseAnimationCurve:
                                                Curves.easeOut,
                                          );

                                          await firebaseOperations
                                              .addToMyCollection(
                                            videoOwnerId: widget.video.useruid,
                                            amount: int.parse((double.parse(
                                                        "${widget.video.price * (1 - widget.video.discountAmount / 100) * 100}") /
                                                    100)
                                                .toStringAsFixed(0)),
                                            videoItem: widget.video,
                                            isFree: widget.video.isFree,
                                            ctx: ctxIn,
                                            videoId: widget.video.id,
                                          );
                                        }
                                      },
                                      onError: (error) {
                                        showTopSnackBar(
                                          ctxIn,
                                          CustomSnackBar.error(
                                            message: "Payment Unsuccessful",
                                          ),
                                        );

                                        CoolAlert.show(
                                          context: ctxIn,
                                          type: CoolAlertType.error,
                                          text:
                                              "Error using your paypal account to make the payment",
                                          barrierDismissible: false,
                                        );
                                      },
                                      onCancel: (params) {
                                        showTopSnackBar(
                                          ctxIn,
                                          CustomSnackBar.info(
                                            message: "Payment Cancelled",
                                          ),
                                        );

                                        CoolAlert.show(
                                          context: ctxIn,
                                          type: CoolAlertType.info,
                                          text: "Payment has been cancelled",
                                          barrierDismissible: false,
                                        );
                                      }),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: constantColors.navButton,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.paypal,
                                    color: constantColors.whiteColor,
                                  ),
                                  Text(
                                    "Paypal",
                                    style: TextStyle(
                                        color: constantColors.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              height: 40.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: constantColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
  }
}
