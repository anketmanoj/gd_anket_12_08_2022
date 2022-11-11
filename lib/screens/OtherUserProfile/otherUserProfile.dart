import 'dart:collection';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/homeScreenProvider.dart';
import 'package:diamon_rose_app/providers/social_media_links_provider.dart';
import 'package:diamon_rose_app/screens/ForAnonUsers/AnonUserSignUprequired.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/NotifyUserModels.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/OptionsWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:diamon_rose_app/widgets/readMoreWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

class OtherUserProfile extends StatefulWidget {
  const OtherUserProfile(
      {Key? key, required this.userModel, this.fromLink = false})
      : super(key: key);
  final UserModel userModel;
  final bool fromLink;

  @override
  State<OtherUserProfile> createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final ConstantColors constantColors = ConstantColors();
  bool freeClicked = true;
  bool paidClicked = false;

  final GlobalKey webViewKey = GlobalKey();

  Future showLinksBottomSheet(BuildContext context) {
    final socialMedias =
        Provider.of<SocialMediaLinksProvider>(context, listen: false);

    return showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.userModel.useruid)
                  .collection("socialMedia")
                  .doc("links")
                  .snapshots(),
              builder: (context, linkSnap) {
                if (linkSnap.hasData) {
                  final links = linkSnap.data!;

                  return SafeArea(
                    bottom: true,
                    child: Container(
                      height: 30.h,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 150),
                            child: Divider(
                              thickness: 4,
                              color: constantColors.black.withOpacity(0.5),
                            ),
                          ),
                          Visibility(
                            visible: links['url'] != "" ? true : false,
                            child: ListTile(
                                leading: Icon(FontAwesomeIcons.globe,
                                    color: Colors.blue),
                                title: Text('Website'),
                                onTap: () async {
                                  var url =
                                      links['url'].toString().contains("http")
                                          ? '${links['url']}'
                                          : 'https://${links['url']}';

                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    throw 'There was a problem to open the url: $url';
                                  }
                                }),
                          ),
                          Visibility(
                            visible: links['instagramurl'] != "" ? true : false,
                            child: ListTile(
                              leading: GradientIcon(
                                FontAwesomeIcons.instagram,
                                30.0,
                                LinearGradient(
                                  colors: <Color>[
                                    Colors.yellow,
                                    Colors.red,
                                    Colors.blue,
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                              ),
                              title: Text('Instagram'),
                              onTap: () async {
                                var url =
                                    'https://www.instagram.com/${links['instagramurl']}/';

                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    universalLinksOnly: true,
                                  );
                                } else {
                                  throw 'There was a problem to open the url: $url';
                                }
                              },
                            ),
                          ),
                          Visibility(
                            visible: links['twitterurl'] != "" ? true : false,
                            child: ListTile(
                              leading: Icon(
                                FontAwesomeIcons.twitter,
                                color: Colors.blue,
                              ),
                              title: Text('Twitter'),
                              onTap: () async {
                                var url =
                                    'https://twitter.com/${links['twitterurl']}/';

                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    universalLinksOnly: true,
                                  );
                                } else {
                                  throw 'There was a problem to open the url: $url';
                                }
                              },
                            ),
                          ),
                          Visibility(
                            visible: links['youtubeurl'] != "" ? true : false,
                            child: ListTile(
                              leading: Icon(
                                FontAwesomeIcons.youtube,
                                color: Colors.red,
                              ),
                              title: Text('Youtube'),
                              onTap: () async {
                                var url =
                                    'https://www.youtube.com/c/${links['youtubeurl']}';

                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    universalLinksOnly: true,
                                  );
                                } else {
                                  throw 'There was a problem to open the url: $url';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(
                    height: 20.h,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              });
        });
  }

  double progress = 0;
  final urlController = TextEditingController();
  String url = "";

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final FirebaseOperations userProvider =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: constantColors.bioBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 35.h,
              child: TopProfileStack(
                  fromLink: widget.fromLink!,
                  size: size,
                  userModel: widget.userModel,
                  constantColors: constantColors),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.userModel.userrealname!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: InkWell(
                                        onTap: () {
                                          showLinksBottomSheet(context);
                                        },
                                        child: Icon(
                                          FontAwesomeIcons.link,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ReadMoreText(
                                widget.userModel.userbio!.length == '0'
                                    ? ''
                                    : widget.userModel.userbio!,
                                trimLines: 2,
                                colorClickableText: constantColors.navButton,
                                trimMode: TrimMode.Line,
                                moreStyle: TextStyle(
                                  color: constantColors.mainColor,
                                ),
                                lessStyle: TextStyle(
                                  color: constantColors.mainColor,
                                ),
                                trimCollapsedText: 'Show more',
                                trimExpandedText: ' Show less',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: context.read<Authentication>().getIsAnon == false
                            ? Visibility(
                                visible: widget.userModel.useruid !=
                                    context.read<Authentication>().getUserId,
                                child: Column(
                                  children: [
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(widget.userModel.useruid)
                                          .collection("followers")
                                          .doc(auth.getUserId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.data!.exists) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 0),
                                            child: InkWell(
                                              onTap: () async {
                                                await Provider.of<
                                                            FirebaseOperations>(
                                                        context,
                                                        listen: false)
                                                    .unfollowUser(
                                                  followingUid:
                                                      widget.userModel.useruid,
                                                  followingDocId:
                                                      auth.getUserId,
                                                  followerUid: Provider.of<
                                                              Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                                  followerDocId:
                                                      widget.userModel.useruid,
                                                )
                                                    .whenComplete(() {
                                                  unfollowedNotification(
                                                      context: context,
                                                      name: widget
                                                          .userModel.username);
                                                });
                                              },
                                              child: Container(
                                                height: 35,
                                                width: double.maxFinite,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: Image.asset(
                                                              "assets/images/follow_Bg.jpg")
                                                          .image,
                                                      fit: BoxFit.cover),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  LocaleKeys.unfollow.tr(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 0),
                                            child: InkWell(
                                              onTap: () async {
                                                await Provider.of<
                                                            FirebaseOperations>(
                                                        context,
                                                        listen: false)
                                                    .followUser(
                                                  otherUserToken:
                                                      widget.userModel.token,
                                                  followingUserName:
                                                      userProvider.initUserName,
                                                  followingUid:
                                                      widget.userModel.useruid,
                                                  followingDocId:
                                                      auth.getUserId,
                                                  followingData: {
                                                    'username': userProvider
                                                        .initUserName,
                                                    'userimage': userProvider
                                                        .initUserImage,
                                                    'useremail': userProvider
                                                        .initUserEmail,
                                                    'useruid': auth.getUserId,
                                                    'time': Timestamp.now(),
                                                  },
                                                  followerUid: Provider.of<
                                                              Authentication>(
                                                          context,
                                                          listen: false)
                                                      .getUserId,
                                                  followerDocId:
                                                      widget.userModel.useruid,
                                                  followerData: {
                                                    'username': widget
                                                        .userModel.username,
                                                    'userimage': widget
                                                        .userModel.userimage,
                                                    'useremail': widget
                                                        .userModel.useremail,
                                                    'useruid': widget
                                                        .userModel.useruid,
                                                    'time': Timestamp.now(),
                                                  },
                                                )
                                                    .whenComplete(() async {
                                                  try {
                                                    List<String>
                                                        currentFollowingList =
                                                        SharedPreferencesHelper
                                                            .getListString(
                                                                "followersList");
                                                    currentFollowingList.add(
                                                        "${widget.userModel.useruid}");
                                                    SharedPreferencesHelper
                                                        .setListString(
                                                            "followersList",
                                                            currentFollowingList);
                                                    await Provider.of<
                                                                FirebaseOperations>(
                                                            context,
                                                            listen: false)
                                                        .addFollowNotification(
                                                      userUid: Provider.of<
                                                                  Authentication>(
                                                              context,
                                                              listen: false)
                                                          .getUserId,
                                                      otherUserId: widget
                                                          .userModel.useruid,
                                                      context: context,
                                                    );
                                                  } catch (e) {
                                                    print("ERROR ====> $e");
                                                  }
                                                });
                                              },
                                              child: Container(
                                                height: 35,
                                                width: double.maxFinite,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: Image.asset(
                                                              "assets/images/follow_Bg.jpg")
                                                          .image,
                                                      fit: BoxFit.cover),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  LocaleKeys.follow.tr(),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await Provider.of<FirebaseOperations>(
                                                context,
                                                listen: false)
                                            .messageUser(
                                                messagingUid:
                                                    widget.userModel.useruid,
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
                                                  'useruid': Provider.of<
                                                              Authentication>(
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
                                                messengerDocId:
                                                    widget.userModel.useruid,
                                                messengerData: {
                                                  'username':
                                                      widget.userModel.username,
                                                  'userimage': widget
                                                      .userModel.userimage,
                                                  'useremail':
                                                      'test - remove later',
                                                  'useruid':
                                                      widget.userModel.useruid,
                                                  'time': Timestamp.now(),
                                                })
                                            .whenComplete(() async {
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(
                                                widget.userModel.useruid,
                                              )
                                              .get()
                                              .then((value) {
                                            if (value.exists) {
                                              try {
                                                UserModel user =
                                                    UserModel.fromMap(
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
                                      },
                                      child: Container(
                                        height: 35,
                                        width: double.maxFinite,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: Image.asset(
                                                      "assets/images/follow_Bg.jpg")
                                                  .image,
                                              fit: BoxFit.cover),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          "Message",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  SignUpRequired(context);
                                },
                                child: Container(
                                  height: 35,
                                  width: double.maxFinite,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: Image.asset(
                                                "assets/images/follow_Bg.jpg")
                                            .image,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    LocaleKeys.follow.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w.toDouble()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // show followers in column
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.userModel.useruid)
                                .collection("followers")
                                .snapshots(),
                            builder: (context, followers) {
                              if (followers.hasData) {
                                return InkWell(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                        isDismissible: true,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: size.height * 0.9,
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 150),
                                                      child: Divider(
                                                        thickness: 4,
                                                        color: constantColors
                                                            .navButton,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: size.height * 0.8,
                                                  child: ListView.builder(
                                                    itemCount: followers
                                                        .data!.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                            followers.data!
                                                                    .docs[index]
                                                                ["userimage"],
                                                          ),
                                                        ),
                                                        title: Text(followers
                                                                .data!
                                                                .docs[index]
                                                            ['username']),
                                                        onTap: () {
                                                          userProvider.goToUserProfile(
                                                              userUid: followers
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['useruid'],
                                                              context: context);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  height: 50,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Close"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: UserStats(
                                    text: "${followers.data!.docs.length}",
                                    label: LocaleKeys.followers.tr(),
                                  ),
                                );
                              } else {
                                return UserStats(
                                  text: "0",
                                  label: LocaleKeys.followers.tr(),
                                );
                              }
                            }),
                        Vdivider(),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(widget.userModel.useruid)
                                .collection("following")
                                .snapshots(),
                            builder: (context, following) {
                              if (following.hasData) {
                                return InkWell(
                                  onTap: () async {
                                    await showModalBottomSheet(
                                        isDismissible: true,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: size.height * 0.9,
                                            width: size.width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 150),
                                                      child: Divider(
                                                        thickness: 4,
                                                        color: constantColors
                                                            .navButton,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: size.height * 0.8,
                                                  child: ListView.builder(
                                                    itemCount: following
                                                        .data!.docs.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                            following.data!
                                                                    .docs[index]
                                                                ["userimage"],
                                                          ),
                                                        ),
                                                        title: Text(following
                                                                .data!
                                                                .docs[index]
                                                            ['username']),
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                  FirebaseOperations>()
                                                              .goToUserProfile(
                                                                  userUid: following
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'useruid'],
                                                                  context:
                                                                      context);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  height: 50,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Close"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: UserStats(
                                    text: "${following.data!.docs.length}",
                                    label: LocaleKeys.following.tr(),
                                  ),
                                );
                              } else {
                                return UserStats(
                                  text: "0",
                                  label: LocaleKeys.following.tr(),
                                );
                              }
                            }),
                        Vdivider(),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("posts")
                                .where("useruid",
                                    isEqualTo: widget.userModel.useruid)
                                .snapshots(),
                            builder: (context, posts) {
                              if (posts.hasData) {
                                return UserStats(
                                  text: "${posts.data!.docs.length}",
                                  label: LocaleKeys.posts.tr(),
                                );
                              } else {
                                return UserStats(
                                  text: "0",
                                  label: LocaleKeys.posts.tr(),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    child: FilterChip(
                      showCheckmark: false,
                      backgroundColor: Colors.black,
                      label: Container(
                        alignment: Alignment.center,
                        width: size.width * 0.4,
                        child: Text(
                          "Free",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                          ),
                        ),
                      ),
                      selected: freeClicked,
                      onSelected: (bool value) {
                        setState(() {
                          freeClicked = value;
                          paidClicked = !value;
                        });
                      },
                      pressElevation: 15,
                      selectedColor: constantColors.mainColor,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    child: FilterChip(
                      backgroundColor: Colors.black,
                      showCheckmark: false,
                      label: Container(
                        alignment: Alignment.center,
                        width: size.width * 0.4,
                        child: Text(
                          "Premium",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                          ),
                        ),
                      ),
                      selected: paidClicked,
                      onSelected: (bool value) {
                        setState(() {
                          paidClicked = value;
                          freeClicked = !value;
                        });
                      },
                      pressElevation: 15,
                      selectedColor: constantColors.mainColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: constantColors.whiteColor,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .where("useruid", isEqualTo: widget.userModel.useruid)
                      .where("isfree", isEqualTo: freeClicked)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      if (snapshot.data!.docs.isNotEmpty) {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            Video video = Video.fromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>);
                            return InkWell(
                              onTap: context.read<Authentication>().getIsAnon ==
                                      false
                                  ? () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: PostDetailsScreen(
                                            videoId: video.id,
                                          ),
                                        ),
                                      );
                                    }
                                  : () {
                                      SignUpRequired(context);
                                    },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.grey,
                                      child: context
                                                  .read<Authentication>()
                                                  .getIsAnon ==
                                              false
                                          ? ImageNetworkLoader(
                                              imageUrl: video.thumbnailurl,
                                              hide: video.isFree ||
                                                      video.boughtBy.contains(
                                                          context
                                                              .read<
                                                                  Authentication>()
                                                              .getUserId) ||
                                                      context
                                                              .read<
                                                                  Authentication>()
                                                              .getUserId ==
                                                          "dRnvDRXqrPgZmDfYMSGUJlx0Gbo2"
                                                  ? false
                                                  : true)
                                          : ImageNetworkLoader(
                                              imageUrl: video.thumbnailurl,
                                              hide: true),
                                    ),
                                    Visibility(
                                      visible: video.isFree,
                                      child: Positioned(
                                        bottom: 5,
                                        left: 10,
                                        child: Container(
                                          width: size.width,
                                          height: 40,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.play_arrow_outlined,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              Stack(
                                                children: [
                                                  Text(
                                                    video.views.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      foreground: Paint()
                                                        ..style =
                                                            PaintingStyle.stroke
                                                        ..strokeWidth = 2
                                                        ..color = Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    video.views.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                        );
                      } else {
                        return Container(
                          height: 30.h,
                          child: Center(
                            child: Text(
                              LocaleKeys.noPostYet.tr(),
                              style: TextStyle(
                                color: constantColors.mainColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  }),
            ),
          ],
        ),
      ),

      // CustomScrollView(
      //   slivers: [
      //     SliverAppBar(
      //       leading: Padding(
      //         padding: const EdgeInsets.all(5.0),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: constantColors.black.withOpacity(0.1),
      //             borderRadius: BorderRadius.circular(50),
      //           ),
      //           child: IconButton(
      //               onPressed: () {
      //                 Get.back();
      //                 if (widget.fromLink == true) {
      //                   Get.to(() => FeedPage(
      //                         pageIndexValue: 0,
      //                       ));
      //                 }
      //               },
      //               icon: Icon(
      //                 Icons.arrow_back_ios,
      //               )),
      //         ),
      //       ),
      //       automaticallyImplyLeading: true,
      //       backgroundColor: constantColors.bioBg,
      //       expandedHeight: 30.h,
      //       flexibleSpace: FlexibleSpaceBar(
      //         background: TopProfileStack(
      //             size: size,
      //             userModel: widget.userModel,
      //             constantColors: constantColors),
      //       ),
      //     ),
      //     SliverToBoxAdapter(
      //       child: Container(
      //         height: 27.h,
      //         width: size.width,
      //         decoration: BoxDecoration(
      //           color: constantColors.bioBg,
      //           borderRadius: BorderRadius.only(
      //             topRight: Radius.circular(80),
      //           ),
      //         ),
      //         child: Padding(
      //           padding: const EdgeInsets.only(
      //             top: 10,
      //             left: 10,
      //             right: 10,
      //           ),
      //           child: Column(
      //             children: [
      //               Padding(
      //                 padding: const EdgeInsets.only(bottom: 3),
      //                 child: Row(
      //                   children: [
      //                     Text(
      //                       widget.userModel.userrealname!,
      //                       style: TextStyle(
      //                         fontSize: 16,
      //                         color: Colors.black,
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(left: 10),
      //                       child: InkWell(
      //                         onTap: () {
      //                           showLinksBottomSheet(context);
      //                         },
      //                         child: Icon(
      //                           FontAwesomeIcons.link,
      //                           size: 15,
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               Row(
      //                 children: [
      //                   Expanded(
      //                     child: Container(
      //                       height: 70,
      //                       child: Text(
      //                         widget.userModel.userbio!.length == '0'
      //                             ? ''
      //                             : widget.userModel.userbio!,
      //                         softWrap: true,
      //                         style: TextStyle(
      //                           fontSize: 12,
      //                           color: Colors.black,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   Visibility(
      //                     visible: widget.userModel.useruid !=
      //                         context.read<Authentication>().getUserId,
      //                     child: StreamBuilder<DocumentSnapshot>(
      //                         stream: FirebaseFirestore.instance
      //                             .collection("users")
      //                             .doc(widget.userModel.useruid)
      //                             .collection("followers")
      //                             .doc(auth.getUserId)
      //                             .snapshots(),
      //                         builder: (context, snapshot) {
      //                           if (snapshot.connectionState ==
      //                               ConnectionState.waiting) {
      //                             return Center(
      //                               child: CircularProgressIndicator(),
      //                             );
      //                           }
      //                           if (snapshot.data!.exists) {
      //                             return Padding(
      //                               padding: const EdgeInsets.only(right: 20),
      //                               child: InkWell(
      //                                 onTap: () async {
      //                                   await Provider.of<FirebaseOperations>(
      //                                           context,
      //                                           listen: false)
      //                                       .unfollowUser(
      //                                     followingUid:
      //                                         widget.userModel.useruid,
      //                                     followingDocId: auth.getUserId,
      //                                     followerUid:
      //                                         Provider.of<Authentication>(
      //                                                 context,
      //                                                 listen: false)
      //                                             .getUserId,
      //                                     followerDocId:
      //                                         widget.userModel.useruid,
      //                                   )
      //                                       .whenComplete(() {
      //                                     unfollowedNotification(
      //                                         context: context,
      //                                         name: widget.userModel.username);
      //                                   });
      //                                 },
      //                                 child: Container(
      //                                   height: 35,
      //                                   decoration: BoxDecoration(
      //                                     image: DecorationImage(
      //                                         image: Image.asset(
      //                                                 "assets/images/follow_Bg.jpg")
      //                                             .image,
      //                                         fit: BoxFit.cover),
      //                                     borderRadius:
      //                                         BorderRadius.circular(30),
      //                                   ),
      //                                   child: Row(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.center,
      //                                     children: [
      //                                       Icon(
      //                                         Icons.remove,
      //                                         color: Colors.white,
      //                                       ),
      //                                       Text(
      //                                         LocaleKeys.unfollow.tr(),
      //                                         style: TextStyle(
      //                                           fontSize: 16,
      //                                           color: Colors.white,
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //                             );
      //                           } else {
      //                             return Padding(
      //                               padding: const EdgeInsets.only(right: 20),
      //                               child: InkWell(
      //                                 onTap: () async {
      //                                   await Provider.of<FirebaseOperations>(
      //                                           context,
      //                                           listen: false)
      //                                       .followUser(
      //                                     otherUserToken:
      //                                         widget.userModel.token,
      //                                     followingUserName:
      //                                         userProvider.initUserName,
      //                                     followingUid:
      //                                         widget.userModel.useruid,
      //                                     followingDocId: auth.getUserId,
      //                                     followingData: {
      //                                       'username':
      //                                           userProvider.initUserName,
      //                                       'userimage':
      //                                           userProvider.initUserImage,
      //                                       'useremail':
      //                                           userProvider.initUserEmail,
      //                                       'useruid': auth.getUserId,
      //                                       'time': Timestamp.now(),
      //                                     },
      //                                     followerUid:
      //                                         Provider.of<Authentication>(
      //                                                 context,
      //                                                 listen: false)
      //                                             .getUserId,
      //                                     followerDocId:
      //                                         widget.userModel.useruid,
      //                                     followerData: {
      //                                       'username':
      //                                           widget.userModel.username,
      //                                       'userimage':
      //                                           widget.userModel.userimage,
      //                                       'useremail':
      //                                           widget.userModel.useremail,
      //                                       'useruid': widget.userModel.useruid,
      //                                       'time': Timestamp.now(),
      //                                     },
      //                                   )
      //                                       .whenComplete(() async {
      //                                     try {
      //                                       List<String> currentFollowingList =
      //                                           SharedPreferencesHelper
      //                                               .getListString(
      //                                                   "followersList");
      //                                       currentFollowingList.add(
      //                                           "${widget.userModel.useruid}");
      //                                       SharedPreferencesHelper
      //                                           .setListString("followersList",
      //                                               currentFollowingList);
      //                                       await Provider.of<
      //                                                   FirebaseOperations>(
      //                                               context,
      //                                               listen: false)
      //                                           .addFollowNotification(
      //                                         userUid:
      //                                             Provider.of<Authentication>(
      //                                                     context,
      //                                                     listen: false)
      //                                                 .getUserId,
      //                                         otherUserId:
      //                                             widget.userModel.useruid,
      //                                         context: context,
      //                                       );
      //                                     } catch (e) {
      //                                       print("ERROR ====> $e");
      //                                     }
      //                                   });
      //                                 },
      //                                 child: Container(
      //                                   height: 35,
      //                                   width: 100,
      //                                   decoration: BoxDecoration(
      //                                     image: DecorationImage(
      //                                         image: Image.asset(
      //                                                 "assets/images/follow_Bg.jpg")
      //                                             .image,
      //                                         fit: BoxFit.cover),
      //                                     borderRadius:
      //                                         BorderRadius.circular(30),
      //                                   ),
      //                                   child: Row(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.center,
      //                                     children: [
      //                                       Icon(
      //                                         Icons.add,
      //                                         color: Colors.white,
      //                                       ),
      //                                       Text(
      //                                         LocaleKeys.follow.tr(),
      //                                         style: TextStyle(
      //                                           fontSize: 16,
      //                                           color: Colors.white,
      //                                         ),
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //                             );
      //                           }
      //                         }),
      //                   ),
      //                 ],
      //               ),
      //               Padding(
      //                 padding: const EdgeInsets.only(top: 10),
      //                 child: Container(
      //                   width: size.width * 0.7,
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                     children: [
      //                       // show followers in column
      //                       StreamBuilder<QuerySnapshot>(
      //                           stream: FirebaseFirestore.instance
      //                               .collection("users")
      //                               .doc(widget.userModel.useruid)
      //                               .collection("followers")
      //                               .snapshots(),
      //                           builder: (context, followers) {
      //                             if (followers.hasData) {
      //                               return InkWell(
      //                                 onTap: () async {
      //                                   await showModalBottomSheet(
      //                                       isDismissible: true,
      //                                       isScrollControlled: true,
      //                                       context: context,
      //                                       builder: (context) {
      //                                         return Container(
      //                                           height: size.height * 0.9,
      //                                           width: size.width,
      //                                           decoration: BoxDecoration(
      //                                             color: Colors.white,
      //                                             borderRadius:
      //                                                 BorderRadius.only(
      //                                               topLeft:
      //                                                   Radius.circular(20),
      //                                               topRight:
      //                                                   Radius.circular(20),
      //                                             ),
      //                                           ),
      //                                           child: Column(
      //                                             children: [
      //                                               Column(
      //                                                 children: [
      //                                                   Padding(
      //                                                     padding:
      //                                                         const EdgeInsets
      //                                                                 .symmetric(
      //                                                             horizontal:
      //                                                                 150),
      //                                                     child: Divider(
      //                                                       thickness: 4,
      //                                                       color:
      //                                                           constantColors
      //                                                               .navButton,
      //                                                     ),
      //                                                   ),
      //                                                 ],
      //                                               ),
      //                                               Container(
      //                                                 height: size.height * 0.8,
      //                                                 child: ListView.builder(
      //                                                   itemCount: followers
      //                                                       .data!.docs.length,
      //                                                   itemBuilder:
      //                                                       (context, index) {
      //                                                     return ListTile(
      //                                                       leading:
      //                                                           CircleAvatar(
      //                                                         backgroundImage:
      //                                                             CachedNetworkImageProvider(
      //                                                           followers.data!
      //                                                                       .docs[
      //                                                                   index][
      //                                                               "userimage"],
      //                                                         ),
      //                                                       ),
      //                                                       title: Text(followers
      //                                                               .data!
      //                                                               .docs[index]
      //                                                           ['username']),
      //                                                       onTap: () {
      //                                                         userProvider.goToUserProfile(
      //                                                             userUid: followers
      //                                                                     .data!
      //                                                                     .docs[index]
      //                                                                 [
      //                                                                 'useruid'],
      //                                                             context:
      //                                                                 context);
      //                                                       },
      //                                                     );
      //                                                   },
      //                                                 ),
      //                                               ),
      //                                               Container(
      //                                                 height: 50,
      //                                                 child: TextButton(
      //                                                   onPressed: () {
      //                                                     Navigator.pop(
      //                                                         context);
      //                                                   },
      //                                                   child: Text("Close"),
      //                                                 ),
      //                                               )
      //                                             ],
      //                                           ),
      //                                         );
      //                                       });
      //                                 },
      //                                 child: UserStats(
      //                                   text: "${followers.data!.docs.length}",
      //                                   label: LocaleKeys.followers.tr(),
      //                                 ),
      //                               );
      //                             } else {
      //                               return UserStats(
      //                                 text: "0",
      //                                 label: LocaleKeys.followers.tr(),
      //                               );
      //                             }
      //                           }),
      //                       Vdivider(),
      //                       StreamBuilder<QuerySnapshot>(
      //                           stream: FirebaseFirestore.instance
      //                               .collection("users")
      //                               .doc(widget.userModel.useruid)
      //                               .collection("following")
      //                               .snapshots(),
      //                           builder: (context, following) {
      //                             if (following.hasData) {
      //                               return InkWell(
      //                                 onTap: () async {
      //                                   await showModalBottomSheet(
      //                                       isDismissible: true,
      //                                       isScrollControlled: true,
      //                                       context: context,
      //                                       builder: (context) {
      //                                         return Container(
      //                                           height: size.height * 0.9,
      //                                           width: size.width,
      //                                           decoration: BoxDecoration(
      //                                             color: Colors.white,
      //                                             borderRadius:
      //                                                 BorderRadius.only(
      //                                               topLeft:
      //                                                   Radius.circular(20),
      //                                               topRight:
      //                                                   Radius.circular(20),
      //                                             ),
      //                                           ),
      //                                           child: Column(
      //                                             children: [
      //                                               Column(
      //                                                 children: [
      //                                                   Padding(
      //                                                     padding:
      //                                                         const EdgeInsets
      //                                                                 .symmetric(
      //                                                             horizontal:
      //                                                                 150),
      //                                                     child: Divider(
      //                                                       thickness: 4,
      //                                                       color:
      //                                                           constantColors
      //                                                               .navButton,
      //                                                     ),
      //                                                   ),
      //                                                 ],
      //                                               ),
      //                                               Container(
      //                                                 height: size.height * 0.8,
      //                                                 child: ListView.builder(
      //                                                   itemCount: following
      //                                                       .data!.docs.length,
      //                                                   itemBuilder:
      //                                                       (context, index) {
      //                                                     return ListTile(
      //                                                       leading:
      //                                                           CircleAvatar(
      //                                                         backgroundImage:
      //                                                             CachedNetworkImageProvider(
      //                                                           following.data!
      //                                                                       .docs[
      //                                                                   index][
      //                                                               "userimage"],
      //                                                         ),
      //                                                       ),
      //                                                       title: Text(following
      //                                                               .data!
      //                                                               .docs[index]
      //                                                           ['username']),
      //                                                       onTap: () {
      //                                                         context.read<FirebaseOperations>().goToUserProfile(
      //                                                             userUid: following
      //                                                                     .data!
      //                                                                     .docs[index]
      //                                                                 [
      //                                                                 'useruid'],
      //                                                             context:
      //                                                                 context);
      //                                                       },
      //                                                     );
      //                                                   },
      //                                                 ),
      //                                               ),
      //                                               Container(
      //                                                 height: 50,
      //                                                 child: TextButton(
      //                                                   onPressed: () {
      //                                                     Navigator.pop(
      //                                                         context);
      //                                                   },
      //                                                   child: Text("Close"),
      //                                                 ),
      //                                               )
      //                                             ],
      //                                           ),
      //                                         );
      //                                       });
      //                                 },
      //                                 child: UserStats(
      //                                   text: "${following.data!.docs.length}",
      //                                   label: LocaleKeys.following.tr(),
      //                                 ),
      //                               );
      //                             } else {
      //                               return UserStats(
      //                                 text: "0",
      //                                 label: LocaleKeys.following.tr(),
      //                               );
      //                             }
      //                           }),
      //                       Vdivider(),
      //                       StreamBuilder<QuerySnapshot>(
      //                           stream: FirebaseFirestore.instance
      //                               .collection("posts")
      //                               .where("useruid",
      //                                   isEqualTo: widget.userModel.useruid)
      //                               .snapshots(),
      //                           builder: (context, posts) {
      //                             if (posts.hasData) {
      //                               return UserStats(
      //                                 text: "${posts.data!.docs.length}",
      //                                 label: LocaleKeys.posts.tr(),
      //                               );
      //                             } else {
      //                               return UserStats(
      //                                 text: "0",
      //                                 label: LocaleKeys.posts.tr(),
      //                               );
      //                             }
      //                           }),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //     SliverToBoxAdapter(
      //       child: Container(
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.only(
      //             topLeft: Radius.circular(30),
      //             topRight: Radius.circular(30),
      //           ),
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //             Container(
      //               alignment: Alignment.topCenter,
      //               child: FilterChip(
      //                 showCheckmark: false,
      //                 backgroundColor: Colors.black,
      //                 label: Container(
      //                   alignment: Alignment.center,
      //                   width: size.width * 0.4,
      //                   child: Text(
      //                     "Free",
      //                     style: TextStyle(
      //                       color: constantColors.whiteColor,
      //                     ),
      //                   ),
      //                 ),
      //                 selected: freeClicked,
      //                 onSelected: (bool value) {
      //                   setState(() {
      //                     freeClicked = value;
      //                     paidClicked = !value;
      //                   });
      //                 },
      //                 pressElevation: 15,
      //                 selectedColor: constantColors.mainColor,
      //               ),
      //             ),
      //             Container(
      //               alignment: Alignment.topCenter,
      //               child: FilterChip(
      //                 backgroundColor: Colors.black,
      //                 showCheckmark: false,
      //                 label: Container(
      //                   alignment: Alignment.center,
      //                   width: size.width * 0.4,
      //                   child: Text(
      //                     "Premium",
      //                     style: TextStyle(
      //                       color: constantColors.whiteColor,
      //                     ),
      //                   ),
      //                 ),
      //                 selected: paidClicked,
      //                 onSelected: (bool value) {
      //                   setState(() {
      //                     paidClicked = value;
      //                     freeClicked = !value;
      //                   });
      //                 },
      //                 pressElevation: 15,
      //                 selectedColor: constantColors.mainColor,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //     StreamBuilder<QuerySnapshot>(
      //         stream: FirebaseFirestore.instance
      //             .collection("posts")
      //             .where("useruid", isEqualTo: widget.userModel.useruid)
      //             .where("isfree", isEqualTo: freeClicked)
      //             .orderBy("timestamp", descending: true)
      //             .snapshots(),
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return SliverPadding(
      //               padding: EdgeInsets.all(4),
      //               sliver: SliverToBoxAdapter(
      //                 child: Center(
      //                   child: CircularProgressIndicator(),
      //                 ),
      //               ),
      //             );
      //           }
      //           return SliverPadding(
      //             padding: const EdgeInsets.all(4),
      //             sliver: SliverGrid(
      //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //                 crossAxisCount: 2,
      //                 crossAxisSpacing: 5,
      //                 mainAxisSpacing: 5,
      //               ),
      //               delegate: SliverChildBuilderDelegate(
      //                 (BuildContext context, int index) {
      //                   if (index.toInt() < snapshot.data!.docs.length) {
      //                     Video video = Video.fromJson(
      //                         snapshot.data!.docs[index].data()
      //                             as Map<String, dynamic>);

      //                     log(video.thumbnailurl);
      //                     return InkWell(
      //                       onTap: () {
      //                         // if (video.isFree == true) {
      //                         //   log("free");
      //                         Navigator.push(
      //                           context,
      //                           PageTransition(
      //                             type: PageTransitionType.rightToLeft,
      //                             child: PostDetailsScreen(
      //                               videoId: video.id,
      //                             ),
      //                           ),
      //                         );
      //                         // } else if (video.isPaid == true &&
      //                         //         video.boughtBy.contains(auth.getUserId) ||
      //                         //     video.useruid ==
      //                         //         Provider.of<Authentication>(context,
      //                         //                 listen: false)
      //                         //             .getUserId) {
      //                         //   log("paid already");
      //                         //   Navigator.push(
      //                         //     context,
      //                         //     PageTransition(
      //                         //       type: PageTransitionType.rightToLeft,
      //                         //       child: PostDetailsScreen(
      //                         //         videoId: video.id,
      //                         //       ),
      //                         //     ),
      //                         //   );
      //                         // } else {
      //                         //   final String videoUrl =
      //                         //       "https://gdfe-ac584.web.app/#/video/${video.id}/${Provider.of<Authentication>(context, listen: false).getUserId}";
      //                         //   // "http://192.168.1.6:8080/#/video/${video.id}/${Provider.of<Authentication>(context, listen: false).getUserId}";
      //                         //   // "https://gdfe-ac584.web.app/#/video/0ReK4oZIhGdbuYxBiUG5J/sjhbjhs";

      //                         //   ViewPaidVideoWeb(context, video, videoUrl);
      //                         //   // CoolAlert.show(
      //                         //   //   context: context,
      //                         //   //   type: CoolAlertType.info,
      //                         //   //   title: "Premium Content",
      //                         //   //   text:
      //                         //   //       "You cannot unlock this content within the app; please unlock the content on the Glamorous Diastation website and you'll be able to view it on the Glamorous Diastation app or in the web browser",
      //                         //   //   confirmBtnText: "Unlock Video",
      //                         //   //   cancelBtnText: "Nevermind",
      //                         //   //   confirmBtnColor: constantColors.navButton,
      //                         //   //   showCancelBtn: true,
      //                         //   //   onCancelBtnTap: () {
      //                         //   //     Navigator.pop(context);
      //                         //   //   },
      //                         //   //   onConfirmBtnTap: () => ViewPaidVideoWeb(
      //                         //   //       context, video, videoUrl),
      //                         //   //   confirmBtnTextStyle: TextStyle(
      //                         //   //     fontSize: 14,
      //                         //   //     color: constantColors.whiteColor,
      //                         //   //   ),
      //                         //   //   cancelBtnTextStyle: TextStyle(
      //                         //   //     fontSize: 14,
      //                         //   //   ),
      //                         //   // );
      //                         // }
      //                       },
      //                       child: ClipRRect(
      //                         borderRadius: BorderRadius.circular(30),
      //                         child: Stack(
      //                           children: [
      //                             Container(
      //                               color: Colors.grey,
      //                               child: ImageNetworkLoader(
      //                                   imageUrl: video.thumbnailurl,
      //                                   hide: video.isFree ||
      //                                           video.boughtBy.contains(context
      //                                               .read<Authentication>()
      //                                               .getUserId) ||
      //                                           context
      //                                                   .read<Authentication>()
      //                                                   .getUserId ==
      //                                               "dRnvDRXqrPgZmDfYMSGUJlx0Gbo2"
      //                                       ? false
      //                                       : true),
      //                             ),
      //                             Visibility(
      //                               visible: video.isFree,
      //                               child: Positioned(
      //                                 bottom: 5,
      //                                 left: 10,
      //                                 child: Container(
      //                                   width: size.width,
      //                                   height: 40,
      //                                   child: Row(
      //                                     children: [
      //                                       Icon(
      //                                         Icons.play_arrow_outlined,
      //                                         size: 16,
      //                                         color: Colors.white,
      //                                       ),
      //                                       Stack(
      //                                         children: [
      //                                           Text(
      //                                             video.views.toString(),
      //                                             style: TextStyle(
      //                                               fontSize: 12,
      //                                               foreground: Paint()
      //                                                 ..style =
      //                                                     PaintingStyle.stroke
      //                                                 ..strokeWidth = 2
      //                                                 ..color = Colors.black,
      //                                             ),
      //                                           ),
      //                                           Text(
      //                                             video.views.toString(),
      //                                             style: TextStyle(
      //                                               fontSize: 12,
      //                                               color: Colors.white,
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     );
      //                   }
      //                 },
      //               ),
      //             ),
      //           );
      //         }),
      //   ],
      // ),
    );
  }

  // ignore: type_annotate_public_apis, always_declare_return_types

  unfollowedNotification(
      {required BuildContext context, required String name}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.darkColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Text(
                    "Unfollowed $name",
                    style: TextStyle(
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopProfileStack extends StatefulWidget {
  const TopProfileStack({
    Key? key,
    required this.size,
    required this.userModel,
    required this.constantColors,
    required this.fromLink,
  }) : super(key: key);

  final Size size;
  final UserModel userModel;
  final ConstantColors constantColors;
  final bool fromLink;

  @override
  State<TopProfileStack> createState() => _TopProfileStackState();
}

class _TopProfileStackState extends State<TopProfileStack> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Authentication>(context, listen: false);
    return Stack(
      children: [
        Container(
          height: widget.size.height * 0.6,
          width: widget.size.width,
          child: ImageNetworkLoader(
            imageUrl: widget.userModel.usercover!,
          ),
        ),
        Positioned(
          top: 5.h,
          left: 5.w,
          child: Container(
            decoration: BoxDecoration(
              color: constantColors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {
                Get.back();
                if (widget.fromLink == true) {
                  Get.to(() => FeedPage(
                        pageIndexValue: 0,
                      ));
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: constantColors.whiteColor,
              ),
            ),
          ),
        ),
        if (context.read<Authentication>().getIsAnon == false)
          Visibility(
            visible: widget.userModel.useruid !=
                context.read<Authentication>().getUserId,
            child: Positioned(
              top: 5.h,
              right: 5.w,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: constantColors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () {
                        otherUserOptionsMenu(context);
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (context.read<Authentication>().getIsAnon == false)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.userModel.useruid)
                              .collection("notifyUsers")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.data!.docs.isEmpty) {
                              return InkWell(
                                onTap: () async {
                                  NotifyUsers notifyUser = NotifyUsers(
                                      personalUserId: auth.getUserId,
                                      token: context
                                          .read<FirebaseOperations>()
                                          .fcmToken);
                                  await context
                                      .read<FirebaseOperations>()
                                      .addUserToNotifierList(
                                          accountOwnerId:
                                              widget.userModel.useruid,
                                          notifyUsers: notifyUser);
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        constantColors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.notifications_on_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            } else if (snapshot.data!.docs.any(
                                (element) => element.id == auth.getUserId)) {
                              return InkWell(
                                onTap: () async {
                                  await context
                                      .read<FirebaseOperations>()
                                      .removeUserFromNotifierList(
                                          accountOwnerId:
                                              widget.userModel.useruid,
                                          personlUserid: context
                                              .read<Authentication>()
                                              .getUserId);
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        constantColors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.notifications_off_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            return InkWell(
                              onTap: () async {
                                // log("what");
                                final NotifyUsers notifyUser = NotifyUsers(
                                    personalUserId: auth.getUserId,
                                    token: context
                                        .read<FirebaseOperations>()
                                        .fcmToken);
                                await context
                                    .read<FirebaseOperations>()
                                    .addUserToNotifierList(
                                        accountOwnerId:
                                            widget.userModel.useruid,
                                        notifyUsers: notifyUser);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: constantColors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.notifications_on_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            );
                          }),
                    ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 1.h,
          left: 10,
          right: 20,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: constantColors.navButton,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 5,
                      right: 5,
                      bottom: 5,
                      child: Container(
                        height: 80,
                        width: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: ImageNetworkLoader(
                            imageUrl: widget.userModel.userimage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      children: <Widget>[
                        // Stroked text as border.
                        Text(
                          widget.userModel.username,
                          style: TextStyle(
                            fontSize: 20,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Colors.black,
                          ),
                        ),
                        // Solid text as fill.
                        Text(
                          widget.userModel.username,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            decorationColor: constantColors.mainColor,
                            decorationThickness: 3,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.userModel.isverified!,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: VerifiedMark(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> reportAccountMenu(BuildContext context) {
    List<String> reportingReasons = [
      "It's posting content that shouldn't be on Glamorous Diastation",
      "It's pretending to be someone else",
      "It may be under the age of 13",
    ];
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: 55.h,
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
                    "Report Account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                "Why are you reporting this Account?",
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
                  height: 30.h,
                  width: 100.w,
                  child: ListView.builder(
                    itemCount: reportingReasons.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await FirebaseOperations().reportUser(
                            userModel: widget.userModel,
                            ctx: context,
                            reason: reportingReasons[index],
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Get.snackbar(
                            'Account Reported',
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

  Future<dynamic> blockAccountMenu(
      {required BuildContext context, required UserModel userModel}) {
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: 30.h,
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
                    "Block ${userModel.username}?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                "They won't be able to message you or find your profile or interact with your posts on Glamorous Diastation. They won't be notified that you blocked them.",
                style: TextStyle(
                  color: constantColors.bioBg,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: (20 / 100.h * 100).h,
              ),
              SubmitButton(
                text: "Block",
                function: () async {
                  await FirebaseOperations()
                      .blockUser(userModel: userModel, ctx: context);
                  Get.snackbar(
                    'Account Blocked',
                    "They won't be able to message you or find your profile or interact with your posts on Glamorous Diastation.",
                    overlayColor: constantColors.navButton,
                    colorText: constantColors.whiteColor,
                    snackPosition: SnackPosition.TOP,
                    forwardAnimationCurve: Curves.elasticInOut,
                    reverseAnimationCurve: Curves.easeOut,
                  );

                  // ignore: unawaited_futures
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: FeedPage(), type: PageTransitionType.fade));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> otherUserOptionsMenu(BuildContext context) {
    final List<String> optionsList = [
      LocaleKeys.reportUser.tr(),
      LocaleKeys.block.tr(),
      LocaleKeys.share.tr(),
    ];
    final List<void Function()> functionsList = [
      () {
        reportAccountMenu(context);
      },
      () {
        blockAccountMenu(context: context, userModel: widget.userModel);
      },
      () async {
        final generatedLink =
            await DynamicLinkService.createUserProfileDynamicLink(
                widget.userModel.useruid,
                short: true);
        final String message = generatedLink.toString();

        Share.share(
          '${LocaleKeys.checkout.tr()} @${widget.userModel.username}\n\n$generatedLink',
        );
      }
    ];
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(15),
          height: 30.h,
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
        );
      },
    );
  }
}

class Vdivider extends StatelessWidget {
  const Vdivider({
    Key? key,
    this.dividerColor = Colors.grey,
  }) : super(key: key);

  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 2,
      color: dividerColor,
    );
  }
}

class UserStats extends StatelessWidget {
  const UserStats({
    Key? key,
    required this.text,
    required this.label,
  }) : super(key: key);

  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
