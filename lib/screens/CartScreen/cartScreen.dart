import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CartScreen extends StatelessWidget {
  CartScreen({Key? key, required this.useruid}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();
  final String useruid;
  final ValueNotifier<double> totalPrice = ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "Cart", context: context),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(useruid)
                .collection("cart")
                .snapshots(),
            builder: (context, snapshot) {
              totalPrice.value = 0;
              snapshot.data!.docs.forEach((element) {
                totalPrice.value = totalPrice.value +
                    (element['price'] * (1 - element['discountamount'] / 100));
              });

              log("total price here == ${totalPrice.value}");
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          child: ImageNetworkLoader(
                            imageUrl: snapshot.data!.docs[index]['thumbnailurl']
                                .toString(),
                          ),
                        ),
                        title: Text(
                          "@${snapshot.data!.docs[index]['username']}",
                        ),
                        subtitle: Text(
                          snapshot.data!.docs[index]['videotitle'].toString(),
                        ),
                        trailing: Text(
                          "\$${(snapshot.data!.docs[index]['price'] * (1 - snapshot.data!.docs[index]['discountamount'] / 100)).toStringAsFixed(2)}",
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(useruid)
                            .collection("cart")
                            .doc(snapshot.data!.docs[index].id)
                            .collection("materials")
                            .snapshots(),
                        builder: (context, snaps) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snaps.data!.docs.length,
                              itemBuilder: (ctx, val) {
                                return ListTile(
                                  leading: Container(
                                    height: 30,
                                    width: 30,
                                    child: ImageNetworkLoader(
                                      imageUrl: snaps.data!.docs[val]['gif']
                                          .toString(),
                                    ),
                                  ),
                                  title: Text(
                                    snaps.data!.docs[val]['layerType']
                                        .toString(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }),
      ),
      bottomNavigationBar: ValueListenableBuilder<double>(
          valueListenable: totalPrice,
          builder: (context, val, _) {
            return Container(
              height: 15.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: constantColors.navButton,
              ),
              child: Row(
                children: [
                  Text(
                    "Total ${val}",
                    style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
