import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowLikesPage extends StatelessWidget {
  const ShowLikesPage({Key? key, required this.postId}) : super(key: key);

  final String postId;

  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors = ConstantColors();
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Likes", context: context),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(postId)
                    .collection("likes")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot documentSnapshot) {
                        return ListTile(
                          leading: InkWell(
                            onTap: () {
                              if (documentSnapshot['useruid'] !=
                                  Provider.of<Authentication>(context,
                                          listen: false)
                                      .getUserId) {
                                // Navigator.pushReplacement(
                                //     context,
                                //     PageTransition(
                                //         child: AltProfile(
                                //           userUid:
                                //               documentSnapshot['useruid'],
                                //         ),
                                //         type:
                                //             PageTransitionType.bottomToTop));
                              }
                            },
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: ImageNetworkLoader(
                                  imageUrl: documentSnapshot['userimage'],
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            documentSnapshot['username'],
                            style: TextStyle(
                              color: constantColors.blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            documentSnapshot['useremail'],
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Provider.of<Authentication>(context,
                                          listen: false)
                                      .getUserId ==
                                  documentSnapshot['useruid']
                              ? const SizedBox(
                                  height: 0,
                                  width: 0,
                                )
                              : MaterialButton(
                                  onPressed: () {},
                                  color: constantColors.blueColor,
                                  child: Text(LocaleKeys.follow.tr(),
                                      style: TextStyle(
                                        color: constantColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      )),
                                ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
