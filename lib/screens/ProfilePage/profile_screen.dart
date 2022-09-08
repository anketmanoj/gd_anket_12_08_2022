import 'dart:developer';

// import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/image_utils_provider.dart';
import 'package:diamon_rose_app/providers/social_media_links_provider.dart';
import 'package:diamon_rose_app/screens/ArViewCollection/arViewCollectionScreen.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ProfileCoverImageSelector.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ProfileImageSelector.dart';
import 'package:diamon_rose_app/screens/ProfilePage/profile_Menu_screen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ConstantColors constantColors = ConstantColors();
  bool freeClicked = true;
  bool paidClicked = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    if (Provider.of<FirebaseOperations>(context, listen: false)
            .getInitUserName ==
        "") {
      // ignore: unawaited_futures

      await Provider.of<FirebaseOperations>(context, listen: false)
          .initUserData(context)
          .whenComplete(() async {
        await Provider.of<FirebaseOperations>(context, listen: false)
            .initSocialMediaLinks(
          context: context,
          uid: Provider.of<Authentication>(context, listen: false).getUserId,
        );

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider =
        Provider.of<FirebaseOperations>(context, listen: false);

    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);

    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);

    final Size size = MediaQuery.of(context).size;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: constantColors.bioBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 30.h,
            backgroundColor: constantColors.bioBg,
            flexibleSpace: FlexibleSpaceBar(
              background: TopProfileStack(
                  size: size,
                  userProvider: userProvider,
                  constantColors: constantColors),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: size.height * 0.23,
              width: size.width,
              decoration: BoxDecoration(
                color: constantColors.bioBg,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.8,
                          height: 70,
                          child: Text(
                            userProvider.userbio.length == '0'
                                ? 'Add a bio'
                                : userProvider.userbio,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showLinksBottomSheet(context);
                          },
                          icon: Icon(FontAwesomeIcons.link),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: size.width * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // show followers in column
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(auth.getUserId)
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    150),
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
                                                                          .docs[
                                                                      index]
                                                                  ["userimage"],
                                                            ),
                                                          ),
                                                          title: Text(followers
                                                                  .data!
                                                                  .docs[index]
                                                              ['username']),
                                                          onTap: () {
                                                            firebaseOperations.goToUserProfile(
                                                                userUid: followers
                                                                        .data!
                                                                        .docs[index]
                                                                    ['useruid'],
                                                                context:
                                                                    context);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 50,
                                                    child: FlatButton(
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
                                      label: "Followers",
                                    ),
                                  );
                                } else {
                                  return UserStats(
                                    text: "0",
                                    label: "Followers",
                                  );
                                }
                              }),
                          Vdivider(),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(auth.getUserId)
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    150),
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
                                                                          .docs[
                                                                      index]
                                                                  ["userimage"],
                                                            ),
                                                          ),
                                                          title: Text(following
                                                                  .data!
                                                                  .docs[index]
                                                              ['username']),
                                                          onTap: () {
                                                            firebaseOperations.goToUserProfile(
                                                                userUid: following
                                                                        .data!
                                                                        .docs[index]
                                                                    ['useruid'],
                                                                context:
                                                                    context);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 50,
                                                    child: FlatButton(
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
                                      label: "Following",
                                    ),
                                  );
                                } else {
                                  return UserStats(
                                    text: "0",
                                    label: "Following",
                                  );
                                }
                              }),
                          Vdivider(),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("posts")
                                  .where("useruid", isEqualTo: auth.getUserId)
                                  .snapshots(),
                              builder: (context, posts) {
                                if (posts.hasData) {
                                  return UserStats(
                                    text: "${posts.data!.docs.length}",
                                    label: "Posts",
                                  );
                                } else {
                                  return UserStats(
                                    text: "0",
                                    label: "Posts",
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
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
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .where("useruid", isEqualTo: auth.getUserId)
                  .where("isfree", isEqualTo: freeClicked)
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Container(
                      height: size.height * 0.53,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else {
                  if (snapshot.data!.docs.length > 0) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(4),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index.toInt() < snapshot.data!.docs.length) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: PostDetailsScreen(
                                        videoId: snapshot.data!.docs[index].id,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    color: Colors.grey,
                                    child: ImageNetworkLoader(
                                        imageUrl: snapshot.data!.docs[index]
                                            ["thumbnailurl"]),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: Text(
                            "No Posts yet",
                            style: TextStyle(
                              color: constantColors.mainColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }
              }),
        ],
      ),
    );
  }

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
                  .doc(Provider.of<Authentication>(context, listen: false)
                      .getUserId)
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
                                  var url = 'https://${links['url']}';

                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      universalLinksOnly: true,
                                    );
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
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? Colors.yellow,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class MidProfileStack extends StatelessWidget {
  const MidProfileStack({
    Key? key,
    required this.size,
    required this.constantColors,
    required this.userProvider,
  }) : super(key: key);

  final Size size;
  final ConstantColors constantColors;
  final FirebaseOperations userProvider;

  @override
  Widget build(BuildContext context) {
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    return Positioned(
      top: 34.h,
      child: Container(
        height: size.height * 0.25,
        width: size.width,
        decoration: BoxDecoration(
          color: constantColors.bioBg,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(80),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.8,
                    height: 70,
                    child: Text(
                      userProvider.userbio.length == '0'
                          ? 'Add a bio'
                          : userProvider.userbio,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showLinksBottomSheet(context);
                    },
                    icon: Icon(FontAwesomeIcons.link),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: size.width * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // show followers in column
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(auth.getUserId)
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
                                                itemCount:
                                                    followers.data!.docs.length,
                                                itemBuilder: (context, index) {
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
                                                            .data!.docs[index]
                                                        ['username']),
                                                    onTap: () {
                                                      firebaseOperations
                                                          .goToUserProfile(
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
                                              child: FlatButton(
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
                                label: "Followers",
                              ),
                            );
                          } else {
                            return UserStats(
                              text: "0",
                              label: "Followers",
                            );
                          }
                        }),
                    Vdivider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(auth.getUserId)
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
                                                itemCount:
                                                    following.data!.docs.length,
                                                itemBuilder: (context, index) {
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
                                                            .data!.docs[index]
                                                        ['username']),
                                                    onTap: () {
                                                      firebaseOperations
                                                          .goToUserProfile(
                                                              userUid: following
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
                                              child: FlatButton(
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
                                label: "Following",
                              ),
                            );
                          } else {
                            return UserStats(
                              text: "0",
                              label: "Following",
                            );
                          }
                        }),
                    Vdivider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("posts")
                            .where("useruid", isEqualTo: auth.getUserId)
                            .snapshots(),
                        builder: (context, posts) {
                          if (posts.hasData) {
                            return UserStats(
                              text: "${posts.data!.docs.length}",
                              label: "Posts",
                            );
                          } else {
                            return UserStats(
                              text: "0",
                              label: "Posts",
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  .doc(Provider.of<Authentication>(context, listen: false)
                      .getUserId)
                  .collection("socialMedia")
                  .doc("links")
                  .snapshots(),
              builder: (context, linkSnap) {
                if (linkSnap.hasData) {
                  final links = linkSnap.data!;

                  return SafeArea(
                    bottom: true,
                    child: Container(
                      height: size.height * 0.3,
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
                                  var url = 'https://${links['url']}';

                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      universalLinksOnly: true,
                                    );
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
                    height: size.height * 0.2,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              });
        });
  }
}

class Vdivider extends StatelessWidget {
  const Vdivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 2,
      color: Colors.grey,
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

class TopProfileStack extends StatefulWidget {
  const TopProfileStack({
    Key? key,
    required this.size,
    required this.userProvider,
    required this.constantColors,
  }) : super(key: key);

  final Size size;
  final FirebaseOperations userProvider;
  final ConstantColors constantColors;

  @override
  State<TopProfileStack> createState() => _TopProfileStackState();
}

class _TopProfileStackState extends State<TopProfileStack> {
  final GlobalKey webViewKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Icon(Icons.error));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: widget.size.height,
              width: widget.size.width,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                width: 100.w,
                decoration: BoxDecoration(
                  color: constantColors.bioBg,
                ),
                child:
                    ImageNetworkLoader(imageUrl: snapshot.data!['usercover']),
              ),
              Positioned(
                top: widget.size.height * 0.07,
                right: widget.size.width * 0.05,
                child: Container(
                  decoration: BoxDecoration(
                    color: constantColors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: ProfileMenuScreen(),
                              type: PageTransitionType.rightToLeft));
                      // log("opening");
                      // final Authentication auth =
                      //     context.read<Authentication>();
                      // final FirebaseOperations firebaseOperations =
                      //     context.read<FirebaseOperations>();
                      // final String menuUrl =
                      //     // "https://www.google.com";
                      //     "https://gdfe-ac584.firebaseapp.com/#/menu/${auth.getUserId}/${auth.emailAuth.toString()}";
                      // // "http://192.168.1.9:8080/#/menu/${auth.getUserId}/${auth.emailAuth.toString()}";
                      // log(menuUrl);
                      // ViewMenuWebApp(context, menuUrl, auth, firebaseOperations,
                      //     webViewKey);
                    },
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
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
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ProfileImageSelector(
                                      title: "Profile Picture"),
                                  type: PageTransitionType.rightToLeft));
                          // await selectAvatarOptionsSheet(context);
                          // setState(() {});
                        },
                        child: Stack(
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
                                  child: Container(
                                    child: ImageNetworkLoader(
                                        imageUrl: snapshot.data!['userimage']),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: <Widget>[
                                  // Stroked text as border.
                                  Text(
                                    widget.userProvider.initUserName,
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
                                    widget.userProvider.initUserName,
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
                                visible: widget.userProvider.getIsVerified,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: VerifiedMark(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: constantColors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                          child: ArViewcollectionScreen(),
                                          type: PageTransitionType.rightToLeft),
                                    );

                                    // await selectBackgroundOptionsSheet(context);
                                    // setState(() {});
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.solidFileVideo,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: constantColors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ProfileCoverImageSelector(
                                                title: "Cover Image"),
                                            type: PageTransitionType
                                                .rightToLeft));

                                    // await selectBackgroundOptionsSheet(context);
                                    // setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // MidProfileStack(
              //     size: widget.size,
              //     constantColors: widget.constantColors,
              //     userProvider: widget.userProvider),
            ],
          );
        });
  }

  Future selectAvatarOptionsSheet(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
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
                      color: widget.constantColors.whiteColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Profile Picture",
                          style: TextStyle(
                            color: widget.constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          color: widget.constantColors.navButton,
                          child: Text(
                            'Gallery',
                            style: TextStyle(
                              color: widget.constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickUserAvatar(context, ImageSource.gallery)
                                .whenComplete(() {
                              Provider.of<ImageUtils>(context, listen: false)
                                  .showUserAvatar(context);
                            });
                          }),
                      MaterialButton(
                          color: widget.constantColors.navButton,
                          child: Text(
                            'Camera',
                            style: TextStyle(
                              color: widget.constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickUserAvatar(context, ImageSource.camera)
                                .whenComplete(() {
                              Provider.of<ImageUtils>(context, listen: false)
                                  .showUserAvatar(context);
                            });
                          }),
                    ],
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: widget.constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
  }

  Future selectBackgroundOptionsSheet(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
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
                      color: widget.constantColors.whiteColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Select Cover Image",
                          style: TextStyle(
                            color: widget.constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          color: widget.constantColors.navButton,
                          child: Text(
                            'Gallery',
                            style: TextStyle(
                              color: widget.constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickUserCover(context, ImageSource.gallery)
                                .whenComplete(() {
                              print("done");
                              Provider.of<ImageUtils>(context, listen: false)
                                  .showUserCover(context);
                            });
                          }),
                      MaterialButton(
                          color: widget.constantColors.navButton,
                          child: Text(
                            'Camera',
                            style: TextStyle(
                              color: widget.constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickUserCover(context, ImageSource.camera)
                                .whenComplete(() {
                              Provider.of<ImageUtils>(context, listen: false)
                                  .showUserCover(context);
                            });
                          }),
                    ],
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: widget.constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
  }
}

List<Widget> _listview(int count) {
  final List<Widget> listItems = [];

  for (int i = 0; i < count; i++) {
    listItems.add(
      Container(
        //NOTE: workaround to prevent antialiasing according to: https://github.com/flutter/flutter/issues/25009
        decoration: BoxDecoration(
          color: Colors.white, //the color of the main container
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: new Text(
            'Item ${i.toString()}',
            style: new TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  return listItems;
}

class SliverWidget extends SingleChildRenderObjectWidget {
  SliverWidget({required Widget child, Key? key})
      : super(child: child, key: key);
  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    return RenderSliverWidget();
  }
}

class RenderSliverWidget extends RenderSliverToBoxAdapter {
  RenderSliverWidget({
    RenderBox? child,
  }) : super(child: child);

  @override
  void performResize() {}

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(
        constraints.asBoxConstraints(/* crossAxisExtent: double.infinity */),
        parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    assert(childExtent != null);
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: 100,
      paintOrigin: constraints.scrollOffset,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}
