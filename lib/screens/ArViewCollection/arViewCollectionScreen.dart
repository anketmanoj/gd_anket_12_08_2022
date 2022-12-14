import 'dart:convert';
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
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ArViewcollectionScreen extends StatelessWidget {
  ArViewcollectionScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();

  void runARCommand(
      {required MyArCollection myAr, required BuildContext context}) async {
    final String audioFile = myAr.audioFile;

    // ignore: cascade_invocations
    final String folderName = audioFile.split(myAr.id).toList()[0];
    final String fileName = "${myAr.id}imgSeq";

    myAr.imgSeq =
        myAr.imgSeq.map((e) => e.replaceAll("https:", "http:")).toList();

    Get.dialog(
      SimpleDialog(
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    final value = await FFprobeKit.execute(
        "-show_entries stream=r_frame_rate -v quiet -of json ${myAr.main}");

    log("value == ${value}");

    final String? mapOutput = await value.getOutput();

    final Map<String, dynamic> json = jsonDecode(mapOutput!);

    List<String> fpsString = json['streams'][0]['r_frame_rate'].split("/");
    double fpsCount = double.parse(fpsString[0]) / double.parse(fpsString[1]);

    log("durationString final : $fpsCount");

    Get.back();

    Get.to(
      () => ImageSeqAniScreen(
        folderName: folderName,
        fileName: fileName,
        MyAR: myAr,
        videoFPS: fpsCount,
        arViewerScreen: true,
      ),
    );

    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => ImageSeqAniScreen(
    //       arViewerScreen: true,
    //       folderName: folderName,
    //       fileName: fileName,
    //       MyAR: myAr,
    //     ),
    //   ),
    // );
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
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Center(
                              child: Text("No AR For Viewing Added Yet!"),
                            );
                          }

                          List<MyArCollection> myArList = [];

                          snapshot.data!.docs.removeWhere((element) {
                            MyArCollection myAr = MyArCollection.fromJson(
                                element.data() as Map<String, dynamic>);

                            if (myAr.usage == "Pending") {
                              log("removed pending == ${myAr.usage}");
                              return true;
                            } else {
                              log("not removed pending == ${myAr.usage}");
                              myArList.add(myAr);
                              return false;
                            }
                          });
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: myArList.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      log("name == ${myArList[index].id}");
                                      runARCommand(
                                          myAr: myArList[index],
                                          context: context);
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
                                                            arID:
                                                                myArList[index]
                                                                    .id,
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
                                                      color: constantColors
                                                          .redColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: Image.asset(
                                                    "assets/arViewer/bg.png")
                                                .image,
                                          )),
                                          height: 100.h,
                                          width: 100.w,
                                          child: Image.network(
                                            myArList[index].imgSeq[0],
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: myArList[index].usage ==
                                                      "Material" ||
                                                  myArList[index].usage == null
                                              ? constantColors.greyColor
                                                  .withOpacity(0.7)
                                              : constantColors.navButton
                                                  .withOpacity(0.7)),
                                      child: Text(
                                        myArList[index].usage ?? "Material",
                                        style: TextStyle(
                                            color: constantColors.whiteColor),
                                      ),
                                    ),
                                  ),
                                ],
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
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          // .doc("ndkBvq3gGWWTCUKvbXOFzuZUzNx2")
                          .doc(Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId)
                          .collection("MyCollection")
                          .where("layerType", isEqualTo: "AR")
                          .where("ownerId",
                              isEqualTo: Provider.of<Authentication>(context,
                                      listen: false)
                                  .getUserId)

                          // .where("usage", isEqualTo: "Ar View Only")
                          .orderBy("timestamp", descending: true)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length == 0) {
                            return Center(
                              child: Text("No AR For Viewing Added Yet!"),
                            );
                          }

                          List<MyArCollection> myArList = [];

                          snapshot.data!.docs.removeWhere((element) {
                            MyArCollection myAr = MyArCollection.fromJson(
                                element.data() as Map<String, dynamic>);

                            if (myAr.usage == "Pending") {
                              log("removed pending == ${myAr.usage}");
                              return true;
                            } else {
                              log("not removed pending == ${myAr.usage}");
                              myArList.add(myAr);
                              return false;
                            }
                          });
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: myArList.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      log("name == ${myArList[index].id}");
                                      runARCommand(
                                          myAr: myArList[index],
                                          context: context);
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
                                                            arID:
                                                                myArList[index]
                                                                    .id,
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
                                                      color: constantColors
                                                          .redColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                          height: 100.h,
                                          width: 100.w,
                                          child: Image.network(
                                            myArList[index].imgSeq[0],
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: myArList[index].usage ==
                                                      "Material" ||
                                                  myArList[index].usage == null
                                              ? constantColors.greyColor
                                                  .withOpacity(0.7)
                                              : constantColors.navButton
                                                  .withOpacity(0.7)),
                                      child: Text(
                                        myArList[index].usage ?? "Material",
                                        style: TextStyle(
                                            color: constantColors.whiteColor),
                                      ),
                                    ),
                                  ),
                                ],
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

                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      log("name == ${myAr.id}");
                                      runARCommand(
                                          myAr: myAr, context: context);
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
                                                      color: constantColors
                                                          .redColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                          height: 100.h,
                                          width: 100.w,
                                          child: Image.network(
                                            arSnap["imgSeq"][0],
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: myAr.usage == "Material" ||
                                                  myAr.usage == null
                                              ? constantColors.greyColor
                                                  .withOpacity(0.7)
                                              : constantColors.navButton
                                                  .withOpacity(0.7)),
                                      child: Text(
                                        myAr.usage ?? "Material",
                                        style: TextStyle(
                                            color: constantColors.whiteColor),
                                      ),
                                    ),
                                  ),
                                ],
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
