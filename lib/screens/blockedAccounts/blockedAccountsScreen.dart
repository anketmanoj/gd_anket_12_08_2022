import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class BlockedAccountScreen extends StatelessWidget {
  BlockedAccountScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();
  final FirebaseOperations firebaseOperations = FirebaseOperations();

  @override
  Widget build(BuildContext context) {
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(text: "Block Accounts", context: context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(auth.getUserId)
            .collection("blockedAccounts")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<UserModel> blockedAccounts = snapshot.data!.docs
                .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
                .toList();

            return blockedAccounts.length != 0
                ? Container(
                    height: 90.h,
                    width: 100.w,
                    child: ListView.builder(
                      itemCount: blockedAccounts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(blockedAccounts[index].username),
                          trailing: Container(
                            height: (40 / 100.h * 100).h,
                            width: (100 / 100.w * 100).w,
                            child: SubmitButton(
                              text: "Unblock",
                              function: () async {
                                await firebaseOperations.unblockUser(
                                    userModel: blockedAccounts[index],
                                    ctx: context);

                                Get.snackbar(
                                  'Unblocked ${blockedAccounts[index].username}',
                                  "They will be able to message you, find your profile and interact with your posts on Glamorous Diastation now",
                                  overlayColor: constantColors.navButton,
                                  colorText: constantColors.whiteColor,
                                  snackPosition: SnackPosition.TOP,
                                  forwardAnimationCurve: Curves.elasticInOut,
                                  reverseAnimationCurve: Curves.easeOut,
                                );
                              },
                            ),
                          ),
                          leading: SizedBox(
                            height: 50,
                            width: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: blockedAccounts[index].userimage,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text("No blocked accounts"),
                  );
          }

          return Text("Contact Developer");
        },
      ),
    );
  }
}
