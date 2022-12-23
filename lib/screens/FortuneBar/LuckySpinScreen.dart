import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/screens/FortuneBar/fortuneBarProvider.dart';
import 'package:diamon_rose_app/screens/FortuneBar/roll_button.dart';
import 'package:diamon_rose_app/screens/FortuneBar/wonArScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/buyCaratScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LuckySpinScreen extends HookWidget {
  FortuneBarProvider fortuneBarProvider = FortuneBarProvider();

  @override
  Widget build(BuildContext context) {
    final selected = useStreamController<int>();
    final selectedIndex = useStream(selected.stream, initialData: 0).data ?? 0;
    final isAnimating = useState(false);

    return Consumer<FortuneBarProvider>(builder: (context, fbp, _) {
      void handleRoll() {
        Get.dialog(
          SimpleDialog(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Consumer<CaratProvider>(builder: (context, carat, _) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Carats",
                            style: TextStyle(
                              color: constantColors.navButton,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          VerifiedMark(
                            height: 25,
                            width: 25,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            carat.getCarats.toString(),
                            style: TextStyle(
                              color: constantColors.navButton,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Are you sure you want to spend 5 Carats?",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final double totalPrice = 5;

                              log("total price : $totalPrice");
                              if (carat.getCarats <= totalPrice - 1) {
                                await Get.bottomSheet(
                                    Container(
                                      height: 80.h,
                                      width: 100.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: constantColors.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Not Enough Carats",
                                            style: TextStyle(
                                              color: constantColors.navButton,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Please purchase ${totalPrice - carat.getCarats} more carat(s) to purchase the items",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: constantColors.navButton,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Expanded(
                                            child: BuyCaratScreen(
                                              showAppBar: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    enableDrag: true,
                                    isDismissible: true,
                                    isScrollControlled: true);
                              } else {
                                try {
                                  final int remainingCarats =
                                      carat.getCarats - totalPrice.toInt();

                                  log("started ${carat.getCarats} | using ${totalPrice} | remaining ${remainingCarats}");
                                  context
                                      .read<CaratProvider>()
                                      .setCarats(remainingCarats);
                                  log("cartprovider value ${context.read<CaratProvider>().getCarats}");
                                  await context
                                      .read<FirebaseOperations>()
                                      .updateCaratsOfUser(
                                          userid: context
                                              .read<Authentication>()
                                              .getUserId,
                                          caratValue: remainingCarats);
                                } catch (e) {
                                  log("error updating users carat amount");
                                }

                                Get.back();
                                Get.snackbar(
                                  'Spin Purchased!',
                                  "",
                                  overlayColor: constantColors.navButton,
                                  colorText: constantColors.whiteColor,
                                  snackPosition: SnackPosition.TOP,
                                  forwardAnimationCurve: Curves.elasticInOut,
                                  reverseAnimationCurve: Curves.easeOut,
                                );

                                context
                                    .read<FortuneBarProvider>()
                                    .stopArCollection(false);
                                selected.add(
                                  roll(fbp.getArCollectionsList.length),
                                );
                              }
                            },
                            icon: VerifiedMark(
                              height: 25,
                              width: 25,
                            ),
                            label: Text(
                              "Purchase",
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      }

      return fbp.getArCollectionsList.isNotEmpty
          ? Center(
              child: Stack(
                children: [
                  Container(
                    height: 30.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: constantColors.bioBg.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FortuneBar(
                              height: 200,
                              selected: selected.stream,
                              items: [
                                for (var it in fbp.getArCollectionsList)
                                  FortuneItem(
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        child: ImageNetworkLoader(
                                          imageUrl: it.gif,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      onTap: () => print(it))
                              ],
                              animateFirst: false,
                              onAnimationStart: () {
                                isAnimating.value = true;
                              },
                              onAnimationEnd: () {
                                isAnimating.value = false;
                                context
                                    .read<FortuneBarProvider>()
                                    .stopArCollection(true);

                                // await FirebaseFirestore.instance
                                //     .collection("users")
                                //     .doc(Provider.of<Authentication>(context,
                                //             listen: false)
                                //         .getUserId)
                                //     .collection("MyCollection")
                                //     .doc(context
                                //         .read<FortuneBarProvider>()
                                //         .getArRollSelected
                                //         .id)
                                //     .set({
                                //   "alpha": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .alpha,
                                //   "audioFile": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .audioFile,
                                //   "audioFlag": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .audioFlag,
                                //   "gif": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .gif,
                                //   "id": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .id,
                                //   "imgSeq": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .imgSeq,
                                //   "layerType": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .layerType,
                                //   "main": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .main,
                                //   "timestamp": Timestamp.now(),
                                //   "valueType": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .valueType,
                                //   "ownerId": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .ownerId,
                                //   "ownerName": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .layerType,
                                //   "usage": context
                                //       .read<FortuneBarProvider>()
                                //       .getArRollSelected
                                //       .usage,
                                // });
                                // log("AR ADDED!!!!!!!");

                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: WonArScreen(),
                                      type: PageTransitionType.fade),
                                );

                                // ! use selected index to get the image of the Ar that has been selected from the list
                              },
                            ),
                          ),
                        ),
                        RollButtonWithPreview(
                          selected: selectedIndex,
                          items: fbp.getArCollectionsList,
                          onPressed: isAnimating.value ? null : handleRoll,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            );
    });
  }
}
