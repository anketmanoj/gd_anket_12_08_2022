import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/ArViewCollection/arViewCollectionProvider.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ArViewcollectionScreen extends StatelessWidget {
  ArViewcollectionScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();

  void runARCommand(
      {required MyArCollection myAr, required BuildContext context}) {
    final String audioFile = myAr.audioFile;

    // ignore: cascade_invocations
    final String folderName = audioFile.split(myAr.id).toList()[0];
    final String fileName = "${myAr.id}imgSeq";

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageSeqAniScreen(
          arViewerScreen: true,
          folderName: folderName,
          fileName: fileName,
          MyAR: myAr,
        ),
      ),
    );
  }

  ValueNotifier<bool> deleteItems = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(
        text: LocaleKeys.arviewcollection.tr(),
        context: context,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: deleteItems,
            builder: (_, deleteVal, __) {
              return IconButton(
                onPressed: () {
                  deleteItems.value = !deleteItems.value;
                },
                icon: Icon(
                  deleteVal == true
                      ? Icons.delete_forever_outlined
                      : Icons.delete_outlined,
                ),
              );
            },
          ),
          IconButton(
              onPressed: () => Get.bottomSheet(
                    Container(
                      height: 40.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: constantColors.bioBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Consumer<ArViewcollectionProvider>(
                          builder: (context, selectedVal, _) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text("Show all content"),
                              trailing: Switch(
                                activeColor: constantColors.navButton,
                                value:
                                    "showBoth" == selectedVal.getSelectedValue,
                                onChanged: (value) {
                                  selectedVal.setSelectedValue("showBoth");
                                },
                              ),
                            ),
                            ListTile(
                              title: Text("Only show content that is mine"),
                              trailing: Switch(
                                activeColor: constantColors.navButton,
                                value: "mine" == selectedVal.getSelectedValue,
                                onChanged: (value) {
                                  value
                                      ? selectedVal.setSelectedValue("mine")
                                      : selectedVal
                                          .setSelectedValue("showBoth");
                                },
                              ),
                            ),
                            ListTile(
                              title: Text(
                                  "Only show content that belongs to others"),
                              trailing: Switch(
                                activeColor: constantColors.navButton,
                                value: "other" == selectedVal.getSelectedValue,
                                onChanged: (value) {
                                  value
                                      ? selectedVal.setSelectedValue("other")
                                      : selectedVal
                                          .setSelectedValue("showBoth");
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
              icon: Icon(Icons.filter_alt)),
        ],
      ),
      body: Consumer<ArViewcollectionProvider>(
          builder: (context, arViewcollectionVal, _) {
        return AnimatedBuilder(
            animation: Listenable.merge([deleteItems]),
            builder: (context, _) {
              switch (arViewcollectionVal.getSelectedValue) {
                case "showBoth":
                  return Container(
                    padding: const EdgeInsets.all(15),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId)
                          .collection("MyCollection")
                          .where("layerType", isEqualTo: "AR")

                          // .where("usage", isEqualTo: "Ar View Only")
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Center(
                              child: Text("No AR For Viewing Added Yet!"),
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

                              MyArCollection myAr = MyArCollection.fromJson(
                                  arSnap.data() as Map<String, dynamic>);

                              return InkWell(
                                onTap: () {
                                  log("name == ${myAr.id}");
                                  runARCommand(myAr: myAr, context: context);
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
                                                showCancelBtn: true,
                                                onConfirmBtnTap: () async {
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
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      constantColors.redColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                    borderRadius: BorderRadius.circular(30),
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
                                      child: Image.network(
                                        arSnap["gif"].toString(),
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
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
                      },
                    ),
                  );

                case "mine":
                  return Container(
                    padding: const EdgeInsets.all(15),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId)
                          .collection("MyCollection")
                          .where("layerType", isEqualTo: "AR")
                          .where("ownerId",
                              isEqualTo:
                                  context.read<Authentication>().getUserId)

                          // .where("usage", isEqualTo: "Ar View Only")
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Center(
                              child: Text("No AR For Viewing Added Yet!"),
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

                              MyArCollection myAr = MyArCollection.fromJson(
                                  arSnap.data() as Map<String, dynamic>);

                              return InkWell(
                                onTap: () {
                                  log("name == ${myAr.id}");
                                  runARCommand(myAr: myAr, context: context);
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
                                                showCancelBtn: true,
                                                onConfirmBtnTap: () async {
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
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      constantColors.redColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                    borderRadius: BorderRadius.circular(30),
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
                                      child: Image.network(
                                        arSnap["gif"].toString(),
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
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
                      },
                    ),
                  );
                case "other":
                  return Container(
                    padding: const EdgeInsets.all(15),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId)
                          .collection("MyCollection")
                          .where("layerType", isEqualTo: "AR")
                          .where("ownerId",
                              isNotEqualTo:
                                  context.read<Authentication>().getUserId)

                          // .where("usage", isEqualTo: "Ar View Only")
                          .orderBy("ownerId", descending: false)
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Center(
                              child: Text("No AR For Viewing Added Yet!"),
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

                              MyArCollection myAr = MyArCollection.fromJson(
                                  arSnap.data() as Map<String, dynamic>);

                              return InkWell(
                                onTap: () {
                                  log("name == ${myAr.id}");
                                  runARCommand(myAr: myAr, context: context);
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
                                                showCancelBtn: true,
                                                onConfirmBtnTap: () async {
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
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      constantColors.redColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
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
                                    borderRadius: BorderRadius.circular(30),
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
                                      child: Image.network(
                                        arSnap["gif"].toString(),
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
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
                      },
                    ),
                  );
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            });
      }),
    );
  }
}
