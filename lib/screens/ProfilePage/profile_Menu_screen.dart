// ignore_for_file: unawaited_futures

import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/screens/Admin/adminDeleteUsers.dart';
import 'package:diamon_rose_app/screens/Admin/adminMassNotification.dart';
import 'package:diamon_rose_app/screens/Admin/adminUserPromoCodes.dart';
import 'package:diamon_rose_app/screens/Admin/adminUserRegistration.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/AdminArOptions.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/adminSendUserNotification.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/selectUser.dart';
import 'package:diamon_rose_app/screens/Admin/admin_user_archive.dart';
import 'package:diamon_rose_app/screens/Admin/set_user_data_admin.dart';
import 'package:diamon_rose_app/screens/Admin/upload_video_screen.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/screens/ArViewCollection/arViewCollectionScreen.dart';
import 'package:diamon_rose_app/screens/CartScreen/cartScreen.dart';
import 'package:diamon_rose_app/screens/FilterOptions/HomescreenFilterOptions.dart';
import 'package:diamon_rose_app/screens/GiphyTest/giphyTest.dart';
import 'package:diamon_rose_app/screens/HelpScreen/helpScreen.dart';
import 'package:diamon_rose_app/screens/MonitisationPage/monitisationScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/PostRecommendation.dart';
import 'package:diamon_rose_app/screens/ProfilePage/arViewTest.dart';
import 'package:diamon_rose_app/screens/ProfilePage/buyCaratScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/changeLanguageScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/parallaxTest.dart';
import 'package:diamon_rose_app/screens/ProfilePage/payoutHomeScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/profile_archive_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/profile_favorites_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/shoppingCartScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/social_media_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_email_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_password_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_profile_screen.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/screens/audioPlayer/audioPlayerScreen.dart';
import 'package:diamon_rose_app/screens/blockedAccounts/blockedAccountsScreen.dart';
import 'package:diamon_rose_app/screens/closeAccount/closeAccountScreen.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage_helpers.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageWidgets.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/demo.dart';
import 'package:diamon_rose_app/screens/youtubeSearchApi/trackList.dart';
import 'package:diamon_rose_app/screens/youtubeTest/youtubeTest.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/adminUserModels.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/dbService.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/fcm_notification_Service.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileMenuScreen extends StatefulWidget {
  ProfileMenuScreen({Key? key}) : super(key: key);

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final ConstantColors _constantColors = ConstantColors();
  bool openList = false;
  bool accountInfo = false;
  bool profileDrop = false;
  bool adminDrop = false;
  bool subscriptionDrop = false;
  final GlobalKey webViewKey = GlobalKey();

  final FCMNotificationService _fcmNotificationService =
      FCMNotificationService();

  final urlController = TextEditingController();
  String url = "";
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final Authentication _auth =
        Provider.of<Authentication>(context, listen: false);
    final FirebaseOperations _firebaseOperation =
        Provider.of<FirebaseOperations>(context, listen: false);
    final CaratProvider _caratProvider =
        Provider.of<CaratProvider>(context, listen: false);

    return SafeArea(
      top: false,
      bottom: Platform.isIOS ? false : true,
      child: Scaffold(
        backgroundColor: constantColors.black,
        appBar: AppBar(
          backgroundColor: constantColors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.menu.tr(),
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 35,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.to(
                        () => BuyCaratScreen(),
                      ),
                      child: Row(
                        children: [
                          VerifiedMark(
                            height: 25,
                            width: 25,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Consumer<CaratProvider>(builder: (context, carat, _) {
                            return Text(
                              carat.getCarats.toString(),
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    setState(() {
                      profileDrop = !profileDrop;
                    });
                  },
                  leadingIcon: Icons.person,
                  trailingIcon: profileDrop
                      ? Icons.arrow_downward_outlined
                      : Icons.arrow_forward_ios,
                  text: LocaleKeys.profile.tr(),
                ),
                Visibility(
                  visible: profileDrop,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.userEdit,
                        size: 20,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: UpdateProfileScreen(),
                              type: PageTransitionType.rightToLeft),
                        );
                      },
                      title: Text(
                        LocaleKeys.updateuserdetails.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: profileDrop,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.link,
                        color: Colors.white,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: SocialMediaLinks(),
                              type: PageTransitionType.rightToLeft),
                        );
                      },
                      title: Text(
                        LocaleKeys.addsocialmedialinks.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: BuyCaratScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: FontAwesomeIcons.diamond,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.buyCarats.tr(),
                ),
                Visibility(
                  visible: _auth.emailAuth,
                  child: ListTileOption(
                    constantColors: constantColors,
                    onTap: () {
                      setState(() {
                        accountInfo = !accountInfo;
                      });
                    },
                    leadingIcon: FontAwesomeIcons.idCard,
                    trailingIcon: accountInfo
                        ? Icons.arrow_downward_outlined
                        : Icons.arrow_forward_ios,
                    text: LocaleKeys.accountinformation.tr(),
                  ),
                ),
                Visibility(
                  visible: accountInfo,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.envelope,
                        size: 20,
                        color: Colors.white,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: UpdateEmailScreen(),
                              type: PageTransitionType.rightToLeft),
                        );
                      },
                      title: Text(
                        LocaleKeys.updateemail.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: accountInfo,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.userLock,
                        color: Colors.white,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: UpdatePasswordScreen(),
                              type: PageTransitionType.rightToLeft),
                        );
                      },
                      title: Text(
                        LocaleKeys.updatepassword.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ArViewcollectionScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: FontAwesomeIcons.solidFileVideo,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.arViewCollection.tr(),
                ),

                // Visibility(
                //   visible: openList,
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 40),
                //     child: ListTile(
                //       leading: Icon(
                //         FontAwesomeIcons.solidFileVideo,
                //         color: Colors.white,
                //         size: 20,
                //       ),
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           PageTransition(
                //               child: ArViewerPage(),
                //               type: PageTransitionType.rightToLeft),
                //         );
                //       },
                //       title: Text(
                //         "AR Collections",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 14,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: openList,
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 40),
                //     child: ListTile(
                //       leading: Icon(
                //         FontAwesomeIcons.toolbox,
                //         color: Colors.white,
                //         size: 20,
                //       ),
                //       onTap: () {
                //         // TODO: Navigate to my drafts
                //       },
                //       title: Text(
                //         "My Drafts",
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 14,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: PostRecommendationScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.recommend_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.postrecommendations.tr(),
                ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     await FirebaseFirestore.instance
                //         .collection("posts")
                //         .doc("nNQySqcKvLD5HW4HPuTeg")
                //         .update({"price": 0.0, "totalBilled": 0});
                //   },
                //   leadingIcon: Icons.recommend_outlined,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: LocaleKeys.postrecommendations.tr(),
                // ),

                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     // ! For materails inside post
                //     // await FirebaseFirestore.instance
                //     //     .collection("posts")
                //     //     .get()
                //     //     .then((value) => value.docs.forEach((element) async {
                //     //           await FirebaseFirestore.instance
                //     //               .collection("posts")
                //     //               .doc(element.id)
                //     //               .collection("materials")
                //     //               .get()
                //     //               .then((matvalue) => matvalue.docs
                //     //                       .forEach((materialElement) async {
                //     //                     await FirebaseFirestore.instance
                //     //                         .collection("posts")
                //     //                         .doc(element.id)
                //     //                         .collection("materials")
                //     //                         .doc(materialElement.id)
                //     //                         .update({"hideItem": false});
                //     //                   }));
                //     //         }));

                //     // ! For materails inside mycollection of user
                //     // await FirebaseFirestore.instance
                //     //     .collection("users")
                //     //     .get()
                //     //     .then((value) => value.docs.forEach((element) async {
                //     //           await FirebaseFirestore.instance
                //     //               .collection("users")
                //     //               .doc(element.id)
                //     //               .collection("MyCollection")
                //     //               .get()
                //     //               .then((collectionVal) => collectionVal.docs
                //     //                       .forEach((colElement) async {
                //     //                     await FirebaseFirestore.instance
                //     //                         .collection("users")
                //     //                         .doc(element.id)
                //     //                         .collection("MyCollection")
                //     //                         .doc(colElement.id)
                //     //                         .get()
                //     //                         .then((materialItem) async {
                //     //                       if (materialItem
                //     //                           .data()!
                //     //                           .containsKey("layerType")) {
                //     //                         log("here");
                //     //                         await FirebaseFirestore.instance
                //     //                             .collection("users")
                //     //                             .doc(element.id)
                //     //                             .collection("MyCollection")
                //     //                             .doc(colElement.id)
                //     //                             .update({"hideItem": false});
                //     //                       }
                //     //                     });
                //     //                   }));
                //     //         }));

                //     log("Done updating users collection as well now");
                //   },
                //   leadingIcon: Icons.recommend_outlined,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Post This",
                // ),

                // Consumer<CaratProvider>(builder: (context, carats, _) {
                //   return ListTileOption(
                //     constantColors: constantColors,
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         PageTransition(
                //             child: CartScreenCarats(
                //               useruid: _auth.getUserId,
                //               caratValue: carats.getCarats,
                //             ),
                //             type: PageTransitionType.rightToLeft),
                //       );
                //       // final String cartUrl =
                //       //     "https://gdfe-ac584.firebaseapp.com/#/cartcarats/${_auth.getUserId}/${carats.getCarats}";
                //       // // "https://gdfe-ac584.firebaseapp.com/#/cart/${_auth.getUserId}";

                //       // log(cartUrl);

                //       // ViewPaidVideoWeb(context, cartUrl, _auth,
                //       //     _firebaseOperation, carats.getCarats, _caratProvider);

                //       // CoolAlert.show(
                //       //   context: context,
                //       //   type: CoolAlertType.info,
                //       //   title: "Use Carats ",
                //       //   text:
                //       //       "Some content cannot be acquired by the application. You must configure your acquisition with our web service. It has nothing to do with Apple and Apple is not responsible.",
                //       //   confirmBtnText: "Show Diamonds",
                //       //   cancelBtnText: "Nevermind",
                //       //   confirmBtnColor: constantColors.navButton,
                //       //   showCancelBtn: false,
                //       //   onCancelBtnTap: () {
                //       //     Navigator.pop(context);
                //       //   },
                //       //   onConfirmBtnTap: () => ViewPaidVideoWeb(
                //       //       context, cartUrl, _auth, _firebaseOperation),
                //       //   confirmBtnTextStyle: TextStyle(
                //       //     fontSize: 14,
                //       //     color: constantColors.whiteColor,
                //       //   ),
                //       //   cancelBtnTextStyle: TextStyle(
                //       //     fontSize: 14,
                //       //   ),
                //       // );
                //     },
                //     leadingIcon: Icons.shopping_cart_checkout,
                //     trailingIcon: Icons.arrow_forward_ios,
                //     text: LocaleKeys.shoppingcart.tr(),
                //   );
                // }),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: PurchaseHistoryScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.history,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.purchaseHistory.tr(),
                ),

                // ! use tp update others dates!
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     await FirebaseFirestore.instance
                //         .collection("users")
                //         .get()
                //         .then((usersVal) async {
                //       for (QueryDocumentSnapshot<
                //           Map<String, dynamic>> userElement in usersVal.docs) {
                //         await FirebaseFirestore.instance
                //             .collection("users")
                //             .doc(userElement.id)
                //             .collection("graphData")
                //             .get()
                //             .then((value) async {
                //           for (var element in value.docs) {
                //             if (!element.data().containsKey("timestamp")) {
                //               log("user == ${userElement['username']} element == ${element['month']}");
                //               var rng = math.Random();
                //               int day = 1;
                //               log(element['month'].toString());

                //               log("day == ${1}");
                //               var date = DateTime(2022, element['month'], day);
                //               Timestamp timestampVal = Timestamp.fromDate(date);
                //               log("timestampVal == $timestampVal");

                //               await FirebaseFirestore.instance
                //                   .collection("users")
                //                   .doc(userElement.id)
                //                   .collection("graphData")
                //                   .doc(element.id)
                //                   .update({"timestamp": timestampVal});
                //               log("done updating for ${userElement['username']}");
                //             }
                //           }
                //         });
                //       }
                //     });
                //   },
                //   leadingIcon: Icons.history,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Fix Montisation timestamp",
                // ),

                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     List<Video> videoList = [];
                //     await FirebaseFirestore.instance
                //         .collection("posts")
                //         .where("useruid",
                //             isEqualTo: "ydSAU5MWxOazcOEhAqeUUwbirtU2")
                //         .where("thumbnailurl", isEqualTo: null)
                //         .limit(1)
                //         .get()
                //         .then((value) => value.docs.forEach((element) {
                //               final Video videoEl =
                //                   Video.fromJson(element.data());
                //               videoList.add(videoEl);
                //             }));

                //     log("length = ${videoList.length}");

                //     for (Video element in videoList) {
                //       if (element.thumbnailurl != "") {
                //         log("starting");
                //         // log(element.data()['videourl']);
                //         late File coverthumbnail;
                //         //     .read<FFmpegProvider>()
                //         //     .bgMaterialThumbnailCreator(
                //         //         vidFilePath:
                //         //             element.data()['videourl']);
                //         final Directory appDocumentDir =
                //             await getApplicationDocumentsDirectory();
                //         final String rawDocumentPath = appDocumentDir.path;
                //         final String outputPath =
                //             "${rawDocumentPath}/bgThumbnail.gif";

                //         await Future.delayed(Duration(minutes: 1), () async {
                //           log("starting ffmpeg");
                //           await FFmpegKit.execute(
                //                   "-y -i ${element.videourl} -to 00:00:02 -vf scale=-2:480 -preset ultrafast -r 20/1 ${outputPath}")
                //               .then((value) async {
                //             coverthumbnail = File(outputPath);

                //             log("Here == ${coverthumbnail.path}");

                //             log("done bg gif");

                //             String? coverthumbnailURl = await AwsAnketS3.uploadFile(
                //                 accessKey: "AKIATF76MVYR34JAVB7H",
                //                 secretKey:
                //                     "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",
                //                 bucket: "anketvideobucket",
                //                 file: coverthumbnail,
                //                 filename:
                //                     "${Timestamp.now().millisecondsSinceEpoch}_bgThumbnailGif.gif",
                //                 region: "us-east-1",
                //                 destDir:
                //                     "${Timestamp.now().millisecondsSinceEpoch}");

                //             log("coverthumbnailURl = ${coverthumbnailURl}");

                //             await FirebaseFirestore.instance
                //                 .collection("posts")
                //                 .doc(element.id)
                //                 .update({
                //               "thumbnailurl": coverthumbnailURl,
                //             });

                //             log("updated || post == ${element.id}");
                //           });
                //         });
                //       }
                //     }
                //   },
                //   leadingIcon: Icons.history,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Fix past thumbnails",
                // ),

                // ! fix all enddiscountDate error
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     await FirebaseFirestore.instance
                //         .collection("users")
                //         .get()
                //         .then((value) {
                //       value.docs.forEach((element) async {
                //         await FirebaseFirestore.instance
                //             .collection("users")
                //             .doc(element.id)
                //             .collection("MyCollection")
                //             .get()
                //             .then((collectionVal) {
                //           collectionVal.docs.forEach((collectionElement) async {
                //             await FirebaseFirestore.instance
                //                 .collection("users")
                //                 .doc(element.id)
                //                 .collection("MyCollection")
                //                 .doc(collectionElement.id)
                //                 .get()
                //                 .then((colDoc) async {
                //               if (!colDoc.data()!.containsKey("videoType")) {
                //                 log(colDoc.data().toString());

                //                 if (colDoc.data()!.containsKey("videotitle")) {
                //                   await FirebaseFirestore.instance
                //                     .collection("users")
                //                     .doc(element.id)
                //                     .collection("MyCollection")
                //                     .doc(collectionElement.id)
                //                     .update({
                //                   "videoType": colDoc['enddiscountDate'],
                //                 });
                //                 }
                //               }
                //             });
                //           });
                //         });
                //       });
                //     });

                //     log("done");
                //   },
                //   leadingIcon: Icons.history,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Fix all",
                // ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: MonitizationScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: FontAwesomeIcons.dollarSign,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.monitisation.tr(),
                ),

                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //           child: TransformDemo(),
                //           type: PageTransitionType.rightToLeft),
                //     );
                //   },
                //   leadingIcon: FontAwesomeIcons.dollarSign,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Demo",
                // ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //           child: GiphyTest(
                //             title: "Giphy",
                //           ),
                //           type: PageTransitionType.rightToLeft),
                //     );
                //   },
                //   leadingIcon: FontAwesomeIcons.dollarSign,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "giphy",
                // ),
                // ! fix all usage error
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     await FirebaseFirestore.instance
                //         .collection("posts")
                //         .get()
                //         .then((value) => value.docs.forEach((element) async {
                //               await FirebaseFirestore.instance
                //                   .collection("posts")
                //                   .doc(element.id)
                //                   .collection("materials")
                //                   .get()
                //                   .then((materials) =>
                //                       materials.docs.forEach((layer) async {
                //                         if (!layer
                //                             .data()
                //                             .containsKey("usage")) {
                //                           log(layer.data()['usage']);
                //                           // await FirebaseFirestore.instance
                //                           //     .collection("posts")
                //                           //     .doc(element.id)
                //                           //     .collection("materials")
                //                           //     .doc(layer.id)
                //                           //     .update({
                //                           //   "usage": "",
                //                           // });
                //                         }
                //                       }));
                //             }));
                //   },
                //   leadingIcon: FontAwesomeIcons.untappd,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Fix usage value",
                // ),

                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: FavoritesPage(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.star_border_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.favorites.tr(),
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ArchiveScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.archive_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: "Archived Posts",
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: BlockedAccountScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.block_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.blockedaccounts.tr(),
                ),

                Divider(
                  color: Colors.white,
                ),
                Consumer<MainPageHelpers>(builder: (context, hideShow, _) {
                  return ListTile(
                    onTap: () {
                      hideShow.setHideTutorial(
                          !SharedPreferencesHelper.getBool("hideTutorial"));

                      log("hide from shared == ${SharedPreferencesHelper.getBool("hideTutorial")}");

                      if (SharedPreferencesHelper.getBool("hideTutorial") ==
                          false) {
                        SharedPreferencesHelper.setDxValue("dxVal", 0);
                        SharedPreferencesHelper.setDyValue("dyVal", 0);
                      }
                    },
                    title: Text(
                      SharedPreferencesHelper.getBool("hideTutorial")
                          ? LocaleKeys.hideTutorial.tr()
                          : LocaleKeys.showTutorial.tr(),
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 16,
                      ),
                    ),
                    leading: Icon(
                      hideShow.getHideTutorial
                          ? Icons.visibility_off
                          : Icons.remove_red_eye_outlined,
                      color: constantColors.whiteColor,
                    ),
                    trailing: Switch(
                      value: hideShow.getHideTutorial,
                      onChanged: (val) {
                        hideShow.setHideTutorial(
                            !SharedPreferencesHelper.getBool("hideTutorial"));

                        if (SharedPreferencesHelper.getBool("hideTutorial") ==
                            false) {
                          SharedPreferencesHelper.setDxValue("dxVal", 0);
                          SharedPreferencesHelper.setDyValue("dyVal", 0);
                        }
                      },
                    ),
                  );
                }),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: HelpScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.help_outline,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.help.tr(),
                ),

                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: ChangeLanguageScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  leadingIcon: Icons.language_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.changeLanguage.tr(),
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {},
                  leadingIcon: Icons.language_outlined,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: "Audio test",
                ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () {
                //     // Navigator.push(
                //     //     context,
                //     //     PageRouteBuilder(
                //     //         pageBuilder:
                //     //             (context, animation, secondaryAnimation) =>
                //     //                 TrackList(songQuery: ""),
                //     //         transitionsBuilder: (context, animation,
                //     //             secondaryAnimation, child) {
                //     //           const begin = Offset(1.0, 0.0);
                //     //           const end = Offset.zero;
                //     //           const curve = Curves.fastLinearToSlowEaseIn;

                //     //           var tween = Tween(begin: begin, end: end)
                //     //               .chain(CurveTween(curve: curve));

                //     //           return SlideTransition(
                //     //             position: animation.drive(tween),
                //     //             child: child,
                //     //           );
                //     //         }));

                //     Get.bottomSheet(
                //         Container(
                //           height: 80.h,
                //           color: constantColors.whiteColor,
                //           child: TrackList(songQuery: ""),
                //         ),
                //         isDismissible: true,
                //         isScrollControlled: true,
                //         enableDrag: true);
                //   },
                //   leadingIcon: Icons.language_outlined,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Youtube Search test",
                // ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () async {
                    final generatedLink =
                        await DynamicLinkService.createUserProfileDynamicLink(
                            context.read<Authentication>().getUserId,
                            short: true);
                    final String message = generatedLink.toString();

                    Share.share(
                      '${LocaleKeys.checkout.tr()} @${context.read<FirebaseOperations>().initUserName}\n\n$generatedLink',
                    );
                  },
                  leadingIcon: Icons.person_search,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: LocaleKeys.shareyourprofile.tr(),
                ),

                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    final String login =
                        SharedPreferencesHelper.getString("login");
                    switch (login) {
                      case "email":
                        Navigator.push(
                          context,
                          PageTransition(
                              child: CloseAccountScreen(),
                              type: PageTransitionType.rightToLeft),
                        );
                        break;
                      case "apple":
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.info,
                          title: "${LocaleKeys.deleteaccount.tr()}?",
                          text:
                              "Are you sure you want to delete your account?\n\nThis action is permanent.",
                          showCancelBtn: true,
                          onCancelBtnTap: () => Navigator.pop(context),
                          onConfirmBtnTap: () async {
                            await DatabaseService(
                                    uid: Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                .deleteuser();

                            await FirebaseAuth.instance.currentUser!.delete();

                            // ignore: unawaited_futures
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  child: MainPage(),
                                  type: PageTransitionType.topToBottom),
                            );
                          },
                        );
                        break;
                      case "gmail":
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.info,
                          title: "${LocaleKeys.deleteaccount.tr()}?",
                          text:
                              "Are you sure you want to delete your account?\n\nThis action is permanent.",
                          showCancelBtn: true,
                          onCancelBtnTap: () => Navigator.pop(context),
                          onConfirmBtnTap: () async {
                            await DatabaseService(
                                    uid: Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                .deleteuser();

                            await FirebaseAuth.instance.currentUser!.delete();

                            // ignore: unawaited_futures
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  child: MainPage(),
                                  type: PageTransitionType.topToBottom),
                            );
                          },
                        );
                        break;
                      case "facebook":
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.info,
                          title: "${LocaleKeys.deleteaccount.tr()}?",
                          text:
                              "Are you sure you want to delete your account?\n\nThis action is permanent.",
                          showCancelBtn: true,
                          onCancelBtnTap: () => Navigator.pop(context),
                          onConfirmBtnTap: () async {
                            await DatabaseService(
                                    uid: Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                .deleteuser();

                            await FirebaseAuth.instance.currentUser!.delete();

                            // ignore: unawaited_futures
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  child: MainPage(),
                                  type: PageTransitionType.topToBottom),
                            );
                          },
                        );
                        break;
                    }
                  },
                  leadingIcon: Icons.close_rounded,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: "${LocaleKeys.deleteaccount.tr()}",
                ),
                Visibility(
                  visible: adminUserId
                      .contains(context.read<Authentication>().getUserId),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            adminDrop = !adminDrop;
                          });
                        },
                        title: Text(
                          "Admin Controls",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 16,
                          ),
                        ),
                        leading: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.yellow,
                        ),
                        trailing: Icon(
                          adminDrop == false
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_downward,
                          color: Colors.yellow,
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminUserArchive(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            "Admin User Archive",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: UploadVideoScreen(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            LocaleKeys.adminupload.tr(),
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminSendUserNotification(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            "Admin Notify User",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminUserPromoScreen(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            LocaleKeys.adminUserPromocodes.tr(),
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminRegisterUser(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            "Admin Register Users",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      // Visibility(
                      //   visible: adminDrop,
                      //   child: ListTile(
                      //     onTap: () {
                      //       Navigator.push(
                      //         context,
                      //         PageTransition(
                      //           child: AdminDeleteUsers(),
                      //           type: PageTransitionType.fade,
                      //         ),
                      //       );
                      //     },
                      //     title: Text(
                      //       "Admin Delete Users",
                      //       style: TextStyle(
                      //         color: Colors.yellow,
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //     leading: Icon(
                      //       Icons.admin_panel_settings,
                      //       color: Colors.yellow,
                      //     ),
                      //   ),
                      // ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminMassNotificationScreen(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            "Admin Mass Notification",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: SelectUserVideoEditor(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            LocaleKeys.adminVideoEditor.tr(),
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: PayoutScreen(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            "Payout Requests",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: AdminArOptions(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            LocaleKeys.adminAROptions.tr(),
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: adminDrop,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: UserDataAdminControl(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          title: Text(
                            LocaleKeys.adminUserControl.tr(),
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                            ),
                          ),
                          leading: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    logOutDialog(context);
                  },
                  title: Text(
                    LocaleKeys.logout.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dynamic logOutDialog(BuildContext context) {
    return CoolAlert.show(
      context: context,
      backgroundColor: constantColors.darkColor,
      type: CoolAlertType.info,
      showCancelBtn: true,
      title: LocaleKeys.areyousureyouwanttologout.tr(),
      confirmBtnText: LocaleKeys.logout.tr(),
      onConfirmBtnTap: () {
        SharedPreferencesHelper.setListString("followersList", [""]);
        Provider.of<Authentication>(context, listen: false).facebookLogOut();
        Provider.of<Authentication>(context, listen: false).signOutWithGoogle();
        Provider.of<Authentication>(context, listen: false)
            .logOutViaEmail()
            .whenComplete(() {
          Navigator.pushReplacement(
            context,
            PageTransition(
                child: MainPage(), type: PageTransitionType.topToBottom),
          );
        });
      },
      confirmBtnTextStyle: TextStyle(
        color: constantColors.whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      cancelBtnText: "No",
      cancelBtnTextStyle: TextStyle(
        color: constantColors.redColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        decoration: TextDecoration.underline,
        decorationColor: constantColors.redColor,
      ),
      onCancelBtnTap: () => Navigator.pop(context),
    );
  }

  // ignore: type_annotate_public_apis, always_declare_return_types
  // ViewPaidVideoWeb(
  //     BuildContext context,
  //     String cartUrl,
  //     Authentication auth,
  //     FirebaseOperations firebaseOperations,
  //     int carats,
  //     CaratProvider caratProvider) async {
  //   // ignore: unawaited_futures
  //   showModalBottomSheet(
  //     context: context,
  //     isDismissible: false,
  //     isScrollControlled: true,
  //     enableDrag: false,
  //     builder: (context) {
  //       return SafeArea(
  //         bottom: Platform.isAndroid ? true : false,
  //         child: Container(
  //           height: 95.h,
  //           width: 100.w,
  //           decoration: BoxDecoration(
  //             color: constantColors.black,
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(20),
  //               topRight: Radius.circular(20),
  //             ),
  //           ),
  //           child: Column(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(15, 20, 0, 10),
  //                 child: Row(
  //                   children: [
  //                     InkWell(
  //                       onTap: Get.back,
  //                       child: Text(
  //                         LocaleKeys.done.tr(),
  //                         style: TextStyle(
  //                           color: constantColors.bioBg,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: InAppWebView(
  //                   key: webViewKey,
  //                   onUpdateVisitedHistory: (controller, uri, _) async {
  //                     if (uri!.toString().contains("success")) {
  //                       log("success!");
  //                       // Payment succesful, now iterate through each video and AddtoMycollection
  //                       double totalPrice = 0;
  //                       await FirebaseFirestore.instance
  //                           .collection("users")
  //                           .doc(auth.getUserId)
  //                           .collection("cart")
  //                           .get()
  //                           .then((cartDocs) {
  //                         cartDocs.docs.forEach((cartVideos) async {
  //                           final Video videoModel =
  //                               Video.fromJson(cartVideos.data());

  //                           log("old timestamp == ${videoModel.timestamp.toDate()}");

  //                           videoModel.timestamp = Timestamp.now();

  //                           log("new timestamp == ${videoModel.timestamp.toDate()}");

  //                           totalPrice += cartVideos['price'] *
  //                               (1 - cartVideos['discountamount'] / 100);
  //                           log("Total price  = $totalPrice");
  //                           log("here ${videoModel.timestamp}");
  //                           log("amount transfered == ${(double.parse("${cartVideos['price'] * (1 - cartVideos['discountamount'] / 100) * 100}") / 100).toStringAsFixed(0)}");
  //                           try {
  //                             await firebaseOperations
  //                                 .addToMyCollectionFromCart(
  //                               auth: auth,
  //                               videoOwnerId: videoModel.useruid,
  //                               amount: int.parse((double.parse(
  //                                           "${videoModel.price * (1 - videoModel.discountAmount / 100) * 100}") /
  //                                       100)
  //                                   .toStringAsFixed(0)),
  //                               videoItem: videoModel,
  //                               isFree: videoModel.isFree,
  //                               videoId: videoModel.id,
  //                             );

  //                             log("success added to cart!");
  //                           } catch (e) {
  //                             log("error saving cart to my collection ${e.toString()}");
  //                           }

  //                           try {
  //                             final int remainingCarats =
  //                                 carats - totalPrice.toInt();

  //                             log("started ${carats} | using ${totalPrice} | remaining ${remainingCarats}");
  //                             caratProvider.setCarats(remainingCarats);
  //                             log("cartprovider value ${caratProvider.getCarats}");
  //                             await firebaseOperations.updateCaratsOfUser(
  //                                 userid: auth.getUserId,
  //                                 caratValue: remainingCarats);
  //                           } catch (e) {
  //                             log("error updating users carat amount");
  //                           }

  //                           try {
  //                             await FirebaseFirestore.instance
  //                                 .collection("users")
  //                                 .doc(auth.getUserId)
  //                                 .collection("cart")
  //                                 .doc(cartVideos.id)
  //                                 .delete();

  //                             log("deleted");
  //                           } catch (e) {
  //                             log("error deleting cart  ${e.toString()}");
  //                           }
  //                         });
  //                       }).whenComplete(() {
  //                         log("done");
  //                         // Get.back();
  //                         Get.back();
  //                       });
  //                       Get.snackbar(
  //                         'Purchase Sucessful 🎉',
  //                         'All video purchased have been added to your purchase history',
  //                         overlayColor: constantColors.navButton,
  //                         colorText: constantColors.whiteColor,
  //                         snackPosition: SnackPosition.TOP,
  //                         forwardAnimationCurve: Curves.elasticInOut,
  //                         reverseAnimationCurve: Curves.easeOut,
  //                       );

  //                       // ignore: unawaited_futures, cascade_invocations
  //                       Get.dialog(
  //                         SimpleDialog(
  //                           backgroundColor: constantColors.whiteColor,
  //                           title: Text(
  //                             "Your purchase was successfully completed.",
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               color: constantColors.black,
  //                             ),
  //                           ),
  //                           children: [
  //                             Padding(
  //                               padding: const EdgeInsets.all(10),
  //                               child: Text(
  //                                 "You can enjoy the purchased contents from your purchase history. Please enjoy!",
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(color: constantColors.black),
  //                               ),
  //                             ),
  //                             Padding(
  //                               padding: EdgeInsets.all(10),
  //                               child: Row(
  //                                 children: [
  //                                   Expanded(
  //                                     child: ElevatedButton(
  //                                       style: ButtonStyle(
  //                                         foregroundColor:
  //                                             MaterialStateProperty.all<Color>(
  //                                                 Colors.white),
  //                                         backgroundColor:
  //                                             MaterialStateProperty.all<Color>(
  //                                                 constantColors.navButton),
  //                                         shape: MaterialStateProperty.all<
  //                                             RoundedRectangleBorder>(
  //                                           RoundedRectangleBorder(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(20),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       onPressed: () => Get.back(),
  //                                       child: Text(
  //                                         LocaleKeys.understood.tr(),
  //                                         style: TextStyle(fontSize: 12),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 10,
  //                                   ),
  //                                   Expanded(
  //                                     child: ElevatedButton(
  //                                       style: ButtonStyle(
  //                                         foregroundColor:
  //                                             MaterialStateProperty.all<Color>(
  //                                                 Colors.white),
  //                                         backgroundColor:
  //                                             MaterialStateProperty.all<Color>(
  //                                                 constantColors.navButton),
  //                                         shape: MaterialStateProperty.all<
  //                                             RoundedRectangleBorder>(
  //                                           RoundedRectangleBorder(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(20),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       onPressed: () {
  //                                         Get.back();
  //                                         Get.to(PurchaseHistoryScreen());
  //                                       },
  //                                       child: Text(
  //                                         "View Items",
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         barrierDismissible: false,
  //                       );

  //                       //  await Provider.of<FirebaseOperations>(context,
  //                       //           listen: false)
  //                       //       .addToMyCollection(
  //                       //     videoOwnerId: video.useruid,
  //                       //     amount: int.parse((double.parse(
  //                       //                 "${video.price * (1 - video.discountAmount / 100) * 100}") /
  //                       //             100)
  //                       //         .toStringAsFixed(0)),
  //                       //     videoItem: video,
  //                       //     isFree: video.isFree,
  //                       //     ctx: context,
  //                       //     videoId: video.id,
  //                       //   );

  //                       // log("amount transfered == ${(double.parse("${video.price * (1 - video.discountAmount / 100) * 100}") / 100).toStringAsFixed(0)}");

  //                     } else if (uri.toString().contains("cancel")) {
  //                       Get.back();
  //                       Get.back();
  //                       Get.snackbar(
  //                         'Video Cart Error',
  //                         'Error adding video to cart',
  //                         overlayColor: constantColors.navButton,
  //                         colorText: constantColors.whiteColor,
  //                         snackPosition: SnackPosition.TOP,
  //                         forwardAnimationCurve: Curves.elasticInOut,
  //                         reverseAnimationCurve: Curves.easeOut,
  //                       );
  //                     } else if (uri.toString().contains("applePay")) {
  //                       log(uri.toString() + "this");
  //                       final String totalPrice =
  //                           uri.toString().split("/").last;
  //                       Get.back();
  //                       Get.back();
  //                       log("price == $totalPrice");
  //                       Get.bottomSheet(ApplePayWidget(
  //                         totalPrice: totalPrice,
  //                       ));
  //                     }
  //                   },
  //                   initialUrlRequest: URLRequest(
  //                     url: Uri.parse(cartUrl),
  //                   ),
  //                   initialUserScripts: UnmodifiableListView<UserScript>([]),
  //                   initialOptions: options,
  //                   onWebViewCreated: (controller) {
  //                     webViewController = controller;
  //                   },
  //                   onLoadStart: (controller, url) {
  //                     setState(() {
  //                       urlController.text = this.url;
  //                     });
  //                   },
  //                   androidOnPermissionRequest:
  //                       (controller, origin, resources) async {
  //                     return PermissionRequestResponse(
  //                         resources: resources,
  //                         action: PermissionRequestResponseAction.GRANT);
  //                   },
  //                   shouldOverrideUrlLoading:
  //                       (controller, navigationAction) async {
  //                     var uri = navigationAction.request.url!;

  //                     if (![
  //                       "http",
  //                       "https",
  //                       "file",
  //                       "chrome",
  //                       "data",
  //                       "javascript",
  //                       "about"
  //                     ].contains(uri.scheme)) {
  //                       if (await canLaunch(cartUrl)) {
  //                         // Launch the App
  //                         await launch(
  //                           cartUrl,
  //                         );
  //                         // and cancel the request
  //                         return NavigationActionPolicy.CANCEL;
  //                       }
  //                     }

  //                     return NavigationActionPolicy.ALLOW;
  //                   },
  //                   onLoadStop: (controller, url) async {
  //                     setState(() {
  //                       this.url = url.toString();
  //                       urlController.text = this.url;
  //                     });
  //                   },
  //                   onLoadError: (controller, url, code, message) {},
  //                   onProgressChanged: (controller, progress) {
  //                     if (progress == 100) {}
  //                     setState(() {
  //                       this.progress = progress / 100;
  //                       urlController.text = this.url;
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
