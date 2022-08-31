// ignore_for_file: unawaited_futures

import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/Admin/set_user_data_admin.dart';
import 'package:diamon_rose_app/screens/Admin/upload_video_screen.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/screens/ArViewCollection/arViewCollectionScreen.dart';
import 'package:diamon_rose_app/screens/CartScreen/cartScreen.dart';
import 'package:diamon_rose_app/screens/HelpScreen/helpScreen.dart';
import 'package:diamon_rose_app/screens/MonitisationPage/monitisationScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/PostRecommendation.dart';
import 'package:diamon_rose_app/screens/ProfilePage/profile_favorites_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/social_media_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_email_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_password_screen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/update_profile_screen.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/screens/blockedAccounts/blockedAccountsScreen.dart';
import 'package:diamon_rose_app/screens/closeAccount/closeAccountScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/adminUserModels.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dbService.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/apple_pay.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pay/pay.dart';
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
  bool subscriptionDrop = false;
  final GlobalKey webViewKey = GlobalKey();

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult);
  }

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
  final urlController = TextEditingController();
  String url = "";
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final Authentication _auth =
        Provider.of<Authentication>(context, listen: false);
    final FirebaseOperations _firebaseOperation =
        Provider.of<FirebaseOperations>(context, listen: false);

    final ApplePayButton applePayButton = ApplePayButton(
      paymentConfigurationAsset: 'default_payment_profile_apple.json',
      paymentItems: [
        PaymentItem(
            amount: "10.00",
            label: "This is the label",
            type: PaymentItemType.total),
      ],
      onPaymentResult: onApplePayResult,
    );
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
                Text(
                  "Menu",
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 35,
                  ),
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
                  text: "Profile",
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
                        "Update User Details",
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
                        "Add Social Media Links",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
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
                    text: "Account Information",
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
                        "Update Email",
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
                        "Update Password",
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
                  text: "AR View Collection",
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
                  text: "Post Recommendations",
                ),

                ListTileOption(
                  constantColors: constantColors,
                  onTap: () {
                    final String cartUrl =
                        // "http://192.168.1.8:8080/#/cart/${_auth.getUserId}";
                        "https://gdfe-ac584.firebaseapp.com/#/cart/${_auth.getUserId}";

                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.info,
                      title: "Shoping Cart",
                      text:
                          "You cannot unlock content within the app; please unlock the content from the shopping cart on the Glamorous Diastation website and you'll be able to view it on the Glamorous Diastation app or in the web browser. Click on 'Show Cart' to view your cart on the web",
                      confirmBtnText: "Show Cart",
                      cancelBtnText: "Nevermind",
                      confirmBtnColor: constantColors.navButton,
                      showCancelBtn: true,
                      onCancelBtnTap: () {
                        Navigator.pop(context);
                      },
                      onConfirmBtnTap: () => ViewPaidVideoWeb(
                          context, cartUrl, _auth, _firebaseOperation),
                      confirmBtnTextStyle: TextStyle(
                        fontSize: 14,
                        color: constantColors.whiteColor,
                      ),
                      cancelBtnTextStyle: TextStyle(
                        fontSize: 14,
                      ),
                    );
                  },
                  leadingIcon: EvaIcons.shoppingCartOutline,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: "Cart",
                ),
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
                  text: "Purchase Histroy",
                ),

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
                  text: "Monitisation",
                ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () {
                //     List<String> imgSequence = [];

                //     for (int i = 1; i <= 94; i++) {
                //       imgSequence.add(
                //           "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659177382200_ImgSeq$i.png");
                //     }

                //     Get.to(() => ArPreviewSetting(
                //           gifUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659177382200output.gif",
                //           ownerName: Provider.of<FirebaseOperations>(context,
                //                   listen: false)
                //               .initUserName,
                //           audioFlag: 0,
                //           alphaUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659177382200_alpha.mp4",
                //           audioUrl: "No Audio",
                //           imgSeqList: imgSequence,
                //           arIdVal: "1659177382200",
                //           inputUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659177382200videoFile.mp4",
                //           userUid: Provider.of<Authentication>(context,
                //                   listen: false)
                //               .getUserId,
                //           endDuration: Duration(seconds: 15),
                //         ));
                //   },
                //   leadingIcon: Icons.temple_buddhist,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Test No Audio",
                // ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () {
                //     List<String> imgSequence = [];

                //     for (int i = 1; i <= 94; i++) {
                //       imgSequence.add(
                //           "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659257713778_ImgSeq$i.png");
                //     }

                //     Get.to(() => ArPreviewSetting(
                //           gifUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659257713778output.gif",
                //           ownerName: Provider.of<FirebaseOperations>(context,
                //                   listen: false)
                //               .initUserName,
                //           audioFlag: 0,
                //           alphaUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659257713778_alpha.mp4",
                //           audioUrl: "No Audio",
                //           imgSeqList: imgSequence,
                //           arIdVal: "1659257713778",
                //           inputUrl:
                //               "https://anketvideobucket.s3.amazonaws.com/LZF1TxU9TabQ3hhbUXZH6uC22dH3/1659257713778videoFile.mp4",
                //           userUid: Provider.of<Authentication>(context,
                //                   listen: false)
                //               .getUserId,
                //           endDuration: Duration(seconds: 15),
                //         ));
                //   },
                //   leadingIcon: Icons.temple_buddhist,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "Test With Audio",
                // ),
                // ListTileOption(
                //   constantColors: constantColors,
                //   onTap: () async {
                //     await FirebaseFirestore.instance
                //         .collection("posts")
                //         .doc("BG9ciuEuxNSC5NeAfSUxP")
                //         .update({
                //       "discountamount": 0.0,
                //       "price": 1.0,
                //     });
                //   },
                //   leadingIcon: FontAwesomeIcons.history,
                //   trailingIcon: Icons.arrow_forward_ios,
                //   text: "test all Materials",
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
                  text: "Favorites",
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
                  text: "Blocked Accounts",
                ),

                Divider(
                  color: Colors.white,
                ),
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
                  text: "Help",
                ),
                ListTileOption(
                  constantColors: constantColors,
                  onTap: () async {
                    final generatedLink =
                        await DynamicLinkService.createUserProfileDynamicLink(
                            context.read<Authentication>().getUserId,
                            short: true);
                    final String message = generatedLink.toString();

                    Share.share(
                      'check out @${context.read<FirebaseOperations>().initUserName}\n\n$generatedLink',
                    );
                  },
                  leadingIcon: Icons.person_search,
                  trailingIcon: Icons.arrow_forward_ios,
                  text: "Share your profile",
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
                          title: "Delete Account?",
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
                          title: "Delete Account?",
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
                          title: "Delete Account?",
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
                  text: "Delete Account",
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("admin")
                        .doc("adminUsers")
                        .snapshots(),
                    builder: (context, snapshot) {
                      AdminList adminList = AdminList.fromMap(
                          snapshot.data!.data() as Map<String, dynamic>);

                      if (adminList.adminList
                          .contains(context.read<Authentication>().getUserId)) {
                        return Column(
                          children: [
                            ListTile(
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
                                "Admin Upload",
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
                            ListTile(
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
                                "Admin User Control",
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
                          ],
                        );
                      }
                      return SizedBox();
                    }),
                ListTile(
                  onTap: () {
                    logOutDialog(context);
                  },
                  title: Text(
                    "Log out",
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
      title: "Are you sure you want to log out?",
      confirmBtnText: "Log Out",
      onConfirmBtnTap: () {
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
  ViewPaidVideoWeb(BuildContext context, String cartUrl, Authentication auth,
      FirebaseOperations firebaseOperations) async {
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
                      log("success!");
                      // Payment succesful, now iterate through each video and AddtoMycollection

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(auth.getUserId)
                          .collection("cart")
                          .get()
                          .then((cartDocs) {
                        cartDocs.docs.forEach((cartVideos) async {
                          final Video videoModel =
                              Video.fromJson(cartVideos.data());

                          log("here ${videoModel.timestamp}");
                          log("amount transfered == ${(double.parse("${cartVideos['price'] * (1 - cartVideos['discountamount'] / 100) * 100}") / 100).toStringAsFixed(0)}");
                          try {
                            await firebaseOperations.addToMyCollectionFromCart(
                              auth: auth,
                              videoOwnerId: videoModel.useruid,
                              amount: int.parse((double.parse(
                                          "${videoModel.price * (1 - videoModel.discountAmount / 100) * 100}") /
                                      100)
                                  .toStringAsFixed(0)),
                              videoItem: videoModel,
                              isFree: videoModel.isFree,
                              videoId: videoModel.id,
                            );

                            log("success added to cart!");
                          } catch (e) {
                            log("error saving cart to my collection ${e.toString()}");
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(auth.getUserId)
                                .collection("cart")
                                .doc(cartVideos.id)
                                .delete();

                            log("deleted");
                          } catch (e) {
                            log("error deleting cart  ${e.toString()}");
                          }
                        });
                      }).whenComplete(() {
                        log("done");
                        Get.back();
                        Get.back();
                      });
                      Get.snackbar(
                        'Purchase Sucessful 🎉',
                        'All video purchased have been added to your purchase history',
                        overlayColor: constantColors.navButton,
                        colorText: constantColors.whiteColor,
                        snackPosition: SnackPosition.TOP,
                        forwardAnimationCurve: Curves.elasticInOut,
                        reverseAnimationCurve: Curves.easeOut,
                      );

                      // ignore: unawaited_futures, cascade_invocations
                      Get.dialog(
                        SimpleDialog(
                          backgroundColor: constantColors.whiteColor,
                          title: Text(
                            "Your purchase was successfully completed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: constantColors.black,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "You can enjoy the purchased contents from your purchase history. Please enjoy!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: constantColors.black),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                constantColors.navButton),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        "Understood!",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                constantColors.navButton),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.back();
                                        Get.to(PurchaseHistoryScreen());
                                      },
                                      child: Text(
                                        "View Items",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        barrierDismissible: false,
                      );

                      //  await Provider.of<FirebaseOperations>(context,
                      //           listen: false)
                      //       .addToMyCollection(
                      //     videoOwnerId: video.useruid,
                      //     amount: int.parse((double.parse(
                      //                 "${video.price * (1 - video.discountAmount / 100) * 100}") /
                      //             100)
                      //         .toStringAsFixed(0)),
                      //     videoItem: video,
                      //     isFree: video.isFree,
                      //     ctx: context,
                      //     videoId: video.id,
                      //   );

                      // log("amount transfered == ${(double.parse("${video.price * (1 - video.discountAmount / 100) * 100}") / 100).toStringAsFixed(0)}");

                    } else if (uri.toString().contains("cancel")) {
                      Get.back();
                      Get.back();
                      Get.snackbar(
                        'Video Cart Error',
                        'Error adding video to cart',
                        overlayColor: constantColors.navButton,
                        colorText: constantColors.whiteColor,
                        snackPosition: SnackPosition.TOP,
                        forwardAnimationCurve: Curves.elasticInOut,
                        reverseAnimationCurve: Curves.easeOut,
                      );
                    } else if (uri.toString().contains("applePay")) {
                      log(uri.toString() + "this");
                      final String totalPrice = uri.toString().split("/").last;
                      Get.back();
                      Get.back();
                      log("price == $totalPrice");
                      Get.bottomSheet(ApplePayWidget(
                        totalPrice: totalPrice,
                      ));
                    }
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(cartUrl),
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
                      if (await canLaunch(cartUrl)) {
                        // Launch the App
                        await launch(
                          cartUrl,
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
}
