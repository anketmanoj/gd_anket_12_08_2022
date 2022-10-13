import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ShowCommentsPage extends StatefulWidget {
  ShowCommentsPage(
      {Key? key, required this.postId, this.postOwnerId, this.ownerFcmToken})
      : super(key: key);
  final String postId;
  final String? postOwnerId;
  final String? ownerFcmToken;

  @override
  State<ShowCommentsPage> createState() => _ShowCommentsPageState();
}

class _ShowCommentsPageState extends State<ShowCommentsPage> {
  ConstantColors constantColors = ConstantColors();
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Comments", context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(widget.postId)
                    .collection("comments")
                    .snapshots(),
                builder: (context, comments) {
                  if (comments.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: size.height * 0.65,
                      width: size.width,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Container(
                      height: size.height * 0.65,
                      width: size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ListView(
                          children: comments.data!.docs
                              .map((DocumentSnapshot commentDocSnap) {
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.135,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: InkWell(
                                          onTap: () {
                                            if (commentDocSnap['useruid'] !=
                                                Provider.of<Authentication>(
                                                        context,
                                                        listen: false)
                                                    .getUserId) {
                                              // Navigator.pushReplacement(
                                              //     context,
                                              //     PageTransition(
                                              //         child: AltProfile(
                                              //           userUid: commentDocSnap[
                                              //               'useruid'],
                                              //         ),
                                              //         type: PageTransitionType
                                              //             .bottomToTop));
                                            }
                                          },
                                          child: Container(
                                            // color: constantColors.darkColor,
                                            height: 30,
                                            width: 30,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: ImageNetworkLoader(
                                                imageUrl:
                                                    commentDocSnap['userimage'],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  commentDocSnap['username'],
                                                  style: TextStyle(
                                                    color: constantColors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: authentication.getUserId ==
                                            commentDocSnap['useruid'],
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await firebaseOperations
                                                    .deleteComment(
                                                  commentId: commentDocSnap.id,
                                                  postId: widget.postId,
                                                  context: context,
                                                );
                                              },
                                              icon: Icon(
                                                  FontAwesomeIcons.trashAlt,
                                                  size: 14,
                                                  color:
                                                      constantColors.redColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color: constantColors.blueColor,
                                            size: 14,
                                          ),
                                          onPressed: () {},
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                          child: Text(
                                            commentDocSnap['comment'],
                                            style: TextStyle(
                                              color: constantColors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        StreamBuilder<DocumentSnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection("posts")
                                                .doc(widget.postId)
                                                .collection("comments")
                                                .doc(commentDocSnap.id)
                                                .collection("likes")
                                                .doc(authentication.getUserId)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data!.exists) {
                                                    return IconButton(
                                                      onPressed: () {
                                                        firebaseOperations
                                                            .unLikeComment(
                                                          userUid:
                                                              authentication
                                                                  .getUserId,
                                                          commentId:
                                                              commentDocSnap.id,
                                                          postId: widget.postId,
                                                          context: context,
                                                        );
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
                                                              .likeComment(
                                                            userUid:
                                                                authentication
                                                                    .getUserId,
                                                            commentId:
                                                                commentDocSnap
                                                                    .id,
                                                            postId:
                                                                widget.postId,
                                                            context: context,
                                                          );
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
                                              }
                                            })
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: constantColors.darkColor
                                        .withOpacity(0.2),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                }),
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: size.height * 0.15,
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProfileUserDetails(
                      controller: _commentController,
                      labelText: LocaleKeys.Comment.tr(),
                      onSubmit: (val) {},
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: ImageNetworkLoader(
                              imageUrl: firebaseOperations.initUserImage,
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await firebaseOperations
                              .addComment(
                            videoOwnerId: widget.postOwnerId!,
                            ownerFcmToken: widget.ownerFcmToken!,
                            userUid: authentication.getUserId,
                            postId: widget.postId,
                            comment: _commentController.text,
                            context: context,
                          )
                              .then((value) {
                            if (authentication.getUserId !=
                                widget.postOwnerId) {
                              firebaseOperations.addCommentNotification(
                                videoOwnerUid: widget.postOwnerId!,
                                postId: widget.postId,
                                userUid: authentication.getUserId,
                                context: context,
                              );
                            }
                          });
                          _commentController.clear();
                        },
                        icon: Icon(
                          Icons.send,
                          color: _commentController.text.length > 0
                              ? constantColors.blueColor
                              : constantColors.greyColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
