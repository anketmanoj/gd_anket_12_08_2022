import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/backgroundVideoViewer.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyCollectionMiddleNav extends StatelessWidget {
  MyCollectionMiddleNav({Key? key}) : super(key: key);

  void runARCommand({required MyArCollection myAr}) {
    final String audioFile = myAr.audioFile;

    // ignore: cascade_invocations
    final String folderName = audioFile.split(myAr.id).toList()[0];
    final String fileName = "${myAr.id}imgSeq";

    Get.to(
      () => ImageSeqAniScreen(
        folderName: folderName,
        fileName: fileName,
        MyAR: myAr,
      ),
    );
  }

  ValueNotifier<String> _materialValue = ValueNotifier<String>("AR");
  ValueNotifier<bool> deleteItems = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: constantColors.redColor,
        foregroundColor: constantColors.whiteColor,
        child: Icon(Icons.delete_outlined),
        onPressed: () {
          deleteItems.value = !deleteItems.value;
        },
      ),
      appBar: AppBarWidget(text: LocaleKeys.myMaterials.tr(), context: context),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: ToggleSwitch(
                minWidth: 50.w,
                totalSwitches: 3,
                activeBgColor: [
                  constantColors.navButton,
                  constantColors.navButton,
                  constantColors.navButton,
                ],
                labels: [
                  LocaleKeys.ar.tr(),
                  LocaleKeys.effects.tr(),
                  LocaleKeys.background.tr(),
                ],
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      _materialValue.value = "AR";
                      break;
                    case 1:
                      _materialValue.value = "Effects";
                      break;
                    case 2:
                      _materialValue.value = "Background";
                      break;
                  }
                },
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([
                _materialValue,
                deleteItems,
              ]),
              builder: (context, _) {
                switch (_materialValue.value) {
                  case "AR":
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserId)
                                .collection("MyCollection")
                                .where("layerType", isEqualTo: "AR")
                                .where("usage", isEqualTo: "Material")
                                .orderBy("timestamp", descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.length == 0) {
                                  return Center(
                                    child: Text("No AR Added Yet!"),
                                  );
                                }
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var arSnap = snapshot.data!.docs[index];

                                    MyArCollection myAr =
                                        MyArCollection.fromJson(arSnap.data()
                                            as Map<String, dynamic>);

                                    return InkWell(
                                      onTap: () {
                                        runARCommand(myAr: myAr);
                                      },
                                      child: GridTile(
                                        header: deleteItems.value == true
                                            ? InkWell(
                                                onTap: () {
                                                  log("locale == ${Get.locale}");
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      title: "Delete Item?",
                                                      text:
                                                          "Are you sure you want to delete this?",
                                                      onConfirmBtnTap:
                                                          () async {
                                                        await context
                                                            .read<
                                                                FirebaseOperations>()
                                                            .deleteItemFromMyCollection(
                                                              arID: arSnap.id,
                                                              useruid: context
                                                                  .read<
                                                                      Authentication>()
                                                                  .getUserId,
                                                            );

                                                        Navigator.pop(context);
                                                      });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: constantColors
                                                            .redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: constantColors
                                                                .whiteColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : null,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image.asset(
                                                      "assets/arViewer/bg.png")
                                                  .image,
                                            )),
                                            height: 50,
                                            width: 50,
                                            child: ImageNetworkLoader(
                                                imageUrl:
                                                    arSnap["gif"].toString()),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ),
                    );

                  case "Background":
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserId)
                                .collection("MyCollection")
                                .where("layerType", isEqualTo: "Background")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.length == 0) {
                                  return Center(
                                    child: Text("No Backgrounds Added Yet!"),
                                  );
                                }
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var arSnap = snapshot.data!.docs[index];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                              child: BackgroundVideoViewer(
                                                videoUrl: arSnap['main'],
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft),
                                        );
                                      },
                                      child: GridTile(
                                        header: deleteItems.value == true
                                            ? InkWell(
                                                onTap: () {
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      title: "Delete Item?",
                                                      text:
                                                          "Are you sure you want to delete this?",
                                                      onConfirmBtnTap:
                                                          () async {
                                                        await context
                                                            .read<
                                                                FirebaseOperations>()
                                                            .deleteItemFromMyCollection(
                                                              arID: arSnap.id,
                                                              useruid: context
                                                                  .read<
                                                                      Authentication>()
                                                                  .getUserId,
                                                            );

                                                        Navigator.pop(context);
                                                      });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: constantColors
                                                            .redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: constantColors
                                                                .whiteColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : null,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image.asset(
                                                      "assets/arViewer/bg.png")
                                                  .image,
                                            )),
                                            height: 50,
                                            width: 50,
                                            child: ImageNetworkLoader(
                                                imageUrl:
                                                    arSnap["gif"].toString()),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text("No Backgrounds Added Yet!"),
                                );
                              }
                            }),
                      ),
                    );

                  case "Effects":
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(Provider.of<Authentication>(context,
                                        listen: false)
                                    .getUserId)
                                .collection("MyCollection")
                                .where("layerType", isEqualTo: "Effect")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.length == 0) {
                                  return Center(
                                    child: Text("No Effects Added Yet!"),
                                  );
                                }
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var arSnap = snapshot.data!.docs[index];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                              child: ArViewerPage(
                                                gifUrl: arSnap['gif'],
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft),
                                        );
                                      },
                                      child: GridTile(
                                        header: deleteItems.value == true
                                            ? InkWell(
                                                onTap: () {
                                                  log("locale == ${Get.locale}");
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      title: "Delete Item?",
                                                      text:
                                                          "Are you sure you want to delete this?",
                                                      onConfirmBtnTap:
                                                          () async {
                                                        await context
                                                            .read<
                                                                FirebaseOperations>()
                                                            .deleteItemFromMyCollection(
                                                              arID: arSnap.id,
                                                              useruid: context
                                                                  .read<
                                                                      Authentication>()
                                                                  .getUserId,
                                                            );

                                                        Navigator.pop(context);
                                                      });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: constantColors
                                                            .redColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color: constantColors
                                                                .whiteColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : null,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image.asset(
                                                      "assets/arViewer/bg.png")
                                                  .image,
                                            )),
                                            height: 50,
                                            width: 50,
                                            child: ImageNetworkLoader(
                                                imageUrl:
                                                    arSnap["gif"].toString()),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child: Text("No Effects Added Yet!"),
                                );
                              }
                            }),
                      ),
                    );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
