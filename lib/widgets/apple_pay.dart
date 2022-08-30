import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/PurchaseHistory/purchaseHistroy.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ApplePayWidget extends StatelessWidget {
  ApplePayWidget({Key? key, required this.totalPrice}) : super(key: key);
  final String totalPrice;

  GlobalKey gesKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    void onApplePayResult(paymentResult) async {
      log("success!");
      // Payment succesful, now iterate through each video and AddtoMycollection

      await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.getUserId)
          .collection("cart")
          .get()
          .then((cartDocs) {
        cartDocs.docs.forEach((cartVideos) async {
          final Video videoModel = Video.fromJson(cartVideos.data());

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
        // Get.back();
        // Get.back();
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
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            constantColors.navButton),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            constantColors.navButton),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
    }

    return Container(
      color: constantColors.navButton,
      height: 30.h,
      width: 100.w,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150),
            child: Divider(
              thickness: 4,
              color: constantColors.whiteColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              "To checkout the cart items with Apple Pay please click the button below",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            width: 100.w,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ApplePayButton(
              type: ApplePayButtonType.checkout,
              paymentConfigurationAsset: 'default_payment_profile_apple.json',
              paymentItems: [
                PaymentItem(
                    amount: totalPrice,
                    label: "for Videos in Shopping Cart",
                    type: PaymentItemType.total),
              ],
              onPaymentResult: onApplePayResult,
              style: ApplePayButtonStyle.automatic,
              height: 5.h,
              onError: (val) {
                Get.dialog(
                  SimpleDialog(
                    backgroundColor: constantColors.whiteColor,
                    title: Text(
                      "Your purchase was unsuccessfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: constantColors.black,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "We were unable to use Apple Pay to checkout the items in your cart",
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
                                  "Understood!",
                                  style: TextStyle(fontSize: 12),
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
              },
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
