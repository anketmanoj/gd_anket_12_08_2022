import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
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
import 'package:diamon_rose_app/screens/blockedAccounts/blockedAccountsScreen.dart';
import 'package:diamon_rose_app/screens/closeAccount/closeAccountScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/adminUserModels.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dbService.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final Authentication _auth =
        Provider.of<Authentication>(context, listen: false);
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
                    Navigator.push(
                      context,
                      PageTransition(
                          child: CartScreen(
                              useruid:
                                  context.read<Authentication>().getUserId),
                          type: PageTransitionType.rightToLeft),
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
                        return ListTile(
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
}
