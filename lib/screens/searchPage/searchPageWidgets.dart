// ignore_for_file: unawaited_futures

import 'dart:collection';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/OtherUserProfile/otherUserProfile.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class UserSearch extends StatelessWidget {
  final String userSearchVal;
  final ConstantColors constantColors = ConstantColors();
  final bool goToChat;

  UserSearch({Key? key, required this.userSearchVal, this.goToChat = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return userSearchVal.isEmpty
        ? NoSearchText(
            constantColors: constantColors,
            size: size,
            goToChat: goToChat,
          )
        : FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .where('usersearchindex',
                    arrayContains: userSearchVal
                        .toLowerCase()) // User array contains any for recommended
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data!.docs.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var userData = snapshot.data!.docs[index];

                      UserModel userModel = UserModel.fromMap(
                          userData.data()! as Map<String, dynamic>);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          onTap: () async {
                            goToChat == false
                                ? Navigator.push(
                                    context,
                                    PageTransition(
                                        child: OtherUserProfile(
                                          userModel: userModel,
                                        ),
                                        type: PageTransitionType.fade))
                                : await Provider.of<FirebaseOperations>(context,
                                        listen: false)
                                    .messageUser(
                                        messagingUid: userModel.useruid,
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
                                          'useruid':
                                              Provider.of<Authentication>(
                                                      context,
                                                      listen: false)
                                                  .getUserId,
                                          'time': Timestamp.now(),
                                        },
                                        messengerUid:
                                            Provider.of<Authentication>(context,
                                                    listen: false)
                                                .getUserId,
                                        messengerDocId: userModel.useruid,
                                        messengerData: {
                                          'username': userModel.username,
                                          'userimage': userModel.userimage,
                                          'useremail': 'test - remove later',
                                          'useruid': userModel.useruid,
                                          'time': Timestamp.now(),
                                        })
                                    .whenComplete(() async {
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(userModel.useruid)
                                        .get()
                                        .then((value) {
                                      if (value.exists) {
                                        try {
                                          UserModel user =
                                              UserModel.fromMap(value.data()!);
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
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                                height: 50,
                                width: 50,
                                child: ImageNetworkLoader(
                                    imageUrl: userData['userimage'])),
                          ),
                          title: Text(
                            userData['username'],
                            style: TextStyle(color: constantColors.navButton),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: Lottie.asset(
                          "assets/animations/empty.json",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: Text(
                            "No users found",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: constantColors.navButton),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            },
          );
  }
}

class VideoSearch extends StatefulWidget {
  final String videoSearchVal;

  VideoSearch({Key? key, required this.videoSearchVal}) : super(key: key);

  @override
  State<VideoSearch> createState() => _VideoSearchState();
}

class _VideoSearchState extends State<VideoSearch> {
  final ConstantColors constantColors = ConstantColors();
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  double progress = 0;
  final urlController = TextEditingController();
  String url = "";

  // ignore: type_annotate_public_apis, always_declare_return_types
  ViewPaidVideoWeb(BuildContext context, Video video, String videoUrl) async {
    // ignore: unawaited_futures
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return Container(
          height: 95.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: constantColors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 0, 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: constantColors.bioBg,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InAppWebView(
                  key: webViewKey,
                  onUpdateVisitedHistory: (controller, uri, _) async {
                    if (uri!.toString().contains("success")) {
                      await Provider.of<FirebaseOperations>(context,
                              listen: false)
                          .addToCart(
                        useruid: context.read<Authentication>().getUserId,
                        videoItem: video,
                        isFree: video.isFree,
                        ctx: context,
                        videoId: video.id,
                      );

                      // log("amount transfered == ${(double.parse("${video.price * (1 - video.discountAmount / 100) * 100}") / 100).toStringAsFixed(0)}");

                    } else if (uri.toString().contains("cancel")) {
                      Navigator.pop(context);
                      Get.snackbar(
                        'Video Cart Error',
                        'Error adding video to cart',
                        overlayColor: constantColors.navButton,
                        colorText: constantColors.whiteColor,
                        snackPosition: SnackPosition.TOP,
                        forwardAnimationCurve: Curves.elasticInOut,
                        reverseAnimationCurve: Curves.easeOut,
                      );
                    }
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(videoUrl),
                  ),
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialOptions: options,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunch(videoUrl)) {
                        // Launch the App
                        await launch(
                          videoUrl,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {},
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {}
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return widget.videoSearchVal.isEmpty
        ? NoSearchText(constantColors: constantColors, size: size)
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .where('searchindexList',
                    arrayContains: widget.videoSearchVal.toLowerCase())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data!.docs.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var videoSnap = snapshot.data!.docs[index];
                      Video video = Video.fromJson(
                          videoSnap.data()! as Map<String, dynamic>);

                      return InkWell(
                        onTap: video.isPaid == true
                            ? () {
                                if (video.isPaid == true &&
                                        video.boughtBy.contains(context
                                            .read<Authentication>()
                                            .getUserId) ||
                                    video.useruid ==
                                        Provider.of<Authentication>(context,
                                                listen: false)
                                            .getUserId) {
                                  log("paid already");
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: PostDetailsScreen(
                                            videoId: video.id,
                                          ),
                                          type: PageTransitionType.fade));
                                } else {
                                  final String videoUrl =
                                      "https://gdfe-ac584.web.app/#/video/${video.id}/${Provider.of<Authentication>(context, listen: false).getUserId}";
                                  // "https://gdfe-ac584.web.app/#/video/0ReK4oZIhGdbuYxBiUG5J/sjhbjhs";
                                  CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.info,
                                    title: "Premium Content",
                                    text:
                                        "You cannot unlock this content within the app; please unlock the content on the Glamorous Diastation website and you'll be able to view it on the Glamorous Diastation app or in the web browser",
                                    confirmBtnText: "Unlock Video",
                                    cancelBtnText: "Nevermind",
                                    confirmBtnColor: constantColors.navButton,
                                    showCancelBtn: true,
                                    onCancelBtnTap: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirmBtnTap: () => ViewPaidVideoWeb(
                                        context, video, videoUrl),
                                    confirmBtnTextStyle: TextStyle(
                                      fontSize: 14,
                                      color: constantColors.whiteColor,
                                    ),
                                    cancelBtnTextStyle: TextStyle(
                                      fontSize: 14,
                                    ),
                                  );
                                }
                              }
                            : () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: PostDetailsScreen(
                                          videoId: video.id,
                                        ),
                                        type: PageTransitionType.fade));
                              },
                        child: video.isFree
                            ? GridTile(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: ImageNetworkLoader(
                                          imageUrl: video.thumbnailurl)),
                                ),
                              )
                            : GridTile(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                      height: 50,
                                      width: 50,
                                      child: ImageNetworkLoader(
                                          imageUrl: video.thumbnailurl,
                                          hide: true)),
                                ),
                              ),
                      );
                    },
                  ),
                );
              } else {
                return Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: Lottie.asset(
                          "assets/animations/empty.json",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: Text(
                            "No videos found",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: constantColors.navButton),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            },
          );
  }
}

class NoSearchText extends StatelessWidget {
  const NoSearchText({
    Key? key,
    required this.constantColors,
    required this.size,
    this.goToChat = false,
  }) : super(key: key);

  final ConstantColors constantColors;
  final Size size;
  final bool goToChat;

  @override
  Widget build(BuildContext context) {
    return goToChat == false
        ? Container(
            decoration: BoxDecoration(
              color: constantColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.3,
                  width: size.width,
                  child: Lottie.asset("assets/animations/searching.json"),
                ),
                Text(
                  "Use the search bar above to get what you desire",
                  style: TextStyle(color: constantColors.navButton),
                ),
              ],
            ),
          )
        : FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .orderBy("username", descending: false)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data!.docs.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var userData = snapshot.data!.docs[index];

                      UserModel userModel = UserModel.fromMap(
                          userData.data()! as Map<String, dynamic>);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          onTap: () async {
                            goToChat == false
                                ? Navigator.push(
                                    context,
                                    PageTransition(
                                        child: OtherUserProfile(
                                          userModel: userModel,
                                        ),
                                        type: PageTransitionType.fade))
                                : await Provider.of<FirebaseOperations>(context,
                                        listen: false)
                                    .messageUser(
                                        messagingUid: userModel.useruid,
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
                                          'useruid':
                                              Provider.of<Authentication>(
                                                      context,
                                                      listen: false)
                                                  .getUserId,
                                          'time': Timestamp.now(),
                                        },
                                        messengerUid:
                                            Provider.of<Authentication>(context,
                                                    listen: false)
                                                .getUserId,
                                        messengerDocId: userModel.useruid,
                                        messengerData: {
                                          'username': userModel.username,
                                          'userimage': userModel.userimage,
                                          'useremail': 'test - remove later',
                                          'useruid': userModel.useruid,
                                          'time': Timestamp.now(),
                                        })
                                    .whenComplete(() async {
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(userModel.useruid)
                                        .get()
                                        .then((value) {
                                      if (value.exists) {
                                        try {
                                          UserModel user =
                                              UserModel.fromMap(value.data()!);
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
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              height: 50,
                              width: 50,
                              child: ImageNetworkLoader(
                                  imageUrl: userData['userimage']),
                            ),
                          ),
                          title: Text(
                            userData['username'],
                            style: TextStyle(color: constantColors.navButton),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: constantColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: Lottie.asset(
                          "assets/animations/empty.json",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: Text(
                            "No users found",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: constantColors.navButton),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            },
          );
  }
}
