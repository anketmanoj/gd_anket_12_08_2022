import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedPageHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  Widget bottomNavBar(
      BuildContext context, int index, PageController pageController) {
    return SizedBox(
      height: 70,
      child: CustomNavigationBar(
        scaleCurve: Curves.easeInOut,
        currentIndex: index,
        selectedColor: constantColors.navButton,
        unSelectedColor: constantColors.whiteColor,
        strokeColor: constantColors.transperant,
        scaleFactor: 0.3,
        iconSize: 35,
        onTap: (val) {
          pageController.jumpToPage(
            val,
          );
          notifyListeners();
        },
        backgroundColor: const Color(0xff040307),
        items: [
          CustomNavigationBarItem(icon: const Icon(EvaIcons.homeOutline)),
          CustomNavigationBarItem(icon: const Icon(EvaIcons.search)),
          CustomNavigationBarItem(
            icon: Container(),
          ),
          CustomNavigationBarItem(
              icon: Stack(
            children: [
              Container(
                child: Icon(EvaIcons.messageSquare),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(Provider.of<Authentication>(context, listen: false)
                          .getUserId)
                      .collection("notifications")
                      .where("seen", isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    if (snapshot.data!.docs.length == 0) {
                      return Container();
                    }

                    return Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 17,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data!.docs.length.toString(),
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
            ],
          )),
          CustomNavigationBarItem(icon: const Icon(EvaIcons.person)),
        ],
      ),
    );
  }
}
