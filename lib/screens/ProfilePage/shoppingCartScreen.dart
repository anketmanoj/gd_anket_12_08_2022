import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:provider/provider.dart';

class CartScreenCarats extends StatefulWidget {
  CartScreenCarats({Key? key, required this.useruid, required this.caratValue})
      : super(key: key);
  final String useruid;
  final int caratValue;

  @override
  State<CartScreenCarats> createState() => _CartScreenCaratsState();
}

class _CartScreenCaratsState extends State<CartScreenCarats> {
  final ConstantColors constantColors = ConstantColors();

  double totalPrice = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.useruid.trim())
          .collection("cart")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          setState(() {
            totalPrice +=
                element['price'] * (1 - element['discountamount'] / 100);
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("useruid == ${widget.useruid}");
    final FirebaseOperations firebaseOperations =
        context.read<FirebaseOperations>();
    final Authentication auth = context.read<Authentication>();
    final CaratProvider caratProvider = context.read<CaratProvider>();
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      extendBodyBehindAppBar: false,
      appBar: AppBarWidget(text: "Shopping Cart", context: context),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.useruid.trim())
                  .collection("cart")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("No Items in Cart"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No Items in Cart"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Video videoModel = Video.fromJson(snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>);
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.info,
                              animType: CoolAlertAnimType.slideInRight,
                              title: "Remove ${videoModel.videotitle}",
                              text:
                                  "Are you sure you want to remove this content from your cart?",
                              showCancelBtn: true,
                              onConfirmBtnTap: () async {
                                Navigator.pop(context);
                                setState(() {
                                  totalPrice -= snapshot.data!.docs[index]
                                          ['price'] *
                                      (1 -
                                          snapshot.data!.docs[index]
                                                  ['discountamount'] /
                                              100);
                                });
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(widget.useruid.trim())
                                    .collection("cart")
                                    .doc(snapshot.data!.docs[index].id)
                                    .delete();
                              },
                            );
                          },
                          leading: Container(
                            height: 50,
                            width: 50,
                            child: ImageNetworkLoader(
                              imageUrl: videoModel.thumbnailurl,
                            ),
                          ),
                          title: Text(
                            "@${videoModel.username}",
                          ),
                          subtitle: Text(
                            videoModel.videotitle,
                          ),
                          trailing: Text(
                            "${((videoModel.price) * (1 - videoModel.discountAmount / 100)).toStringAsFixed(2)} Carats",
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.useruid)
                              .collection("cart")
                              .doc(snapshot.data!.docs[index].id)
                              .collection("materials")
                              .snapshots(),
                          builder: (context, snaps) {
                            if (snaps.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
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
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: constantColors.navButton,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${(totalPrice).toStringAsFixed(2)} Carats",
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor:
                    MaterialStateProperty.all<Color>(constantColors.bioBg),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () async {
                if (widget.caratValue < totalPrice) {
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.error,
                      title: "Not Enough Carats",
                      text:
                          "Please purchase ${totalPrice - widget.caratValue} more carat(s) to purchase the items");
                } else {
                  log("success!");
                  // Payment succesful, now iterate through each video and AddtoMycollection
                  double totalPrice = 0;
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(auth.getUserId)
                      .collection("cart")
                      .get()
                      .then((cartDocs) {
                    cartDocs.docs.forEach((cartVideos) async {
                      final Video videoModel =
                          Video.fromJson(cartVideos.data());

                      log("old timestamp == ${videoModel.timestamp.toDate()}");

                      videoModel.timestamp = Timestamp.now();

                      log("new timestamp == ${videoModel.timestamp.toDate()}");

                      totalPrice += cartVideos['price'] *
                          (1 - cartVideos['discountamount'] / 100);
                      log("Total price  = $totalPrice");
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
                        final int remainingCarats =
                            widget.caratValue - totalPrice.toInt();

                        log("started ${widget.caratValue} | using ${totalPrice} | remaining ${remainingCarats}");
                        caratProvider.setCarats(remainingCarats);
                        log("cartprovider value ${caratProvider.getCarats}");
                        await firebaseOperations.updateCaratsOfUser(
                            userid: auth.getUserId,
                            caratValue: remainingCarats);
                      } catch (e) {
                        log("error updating users carat amount");
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
                    // Get.back();
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
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    LocaleKeys.understood.tr(),
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
                                        borderRadius: BorderRadius.circular(20),
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

                }
              },
              // paymentController.makePayment(
              //     amount: "10", currency: "USD"),
              child: Text(
                "Use Carats",
                style: TextStyle(
                  color: constantColors.navButton,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
