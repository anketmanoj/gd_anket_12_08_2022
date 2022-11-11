import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/video_editor_provider.dart';
import 'package:diamon_rose_app/screens/PostPage/postMaterialModel.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/backgroundVideoViewer.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/TrimVideo/InitVideoEditorScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/ArVideoCreationService.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart' as path;

class MyCollectionMiddleNav extends StatelessWidget {
  MyCollectionMiddleNav({Key? key, this.goToMaterial = 0}) : super(key: key);
  final int goToMaterial;

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

  Future<int> audioCheck(
      {required String videoUrl, required BuildContext context}) async {
    context.read<ArVideoCreation>().setFromPexel(false);
    return FFprobeKit.execute(
            "-i $videoUrl -show_streams -select_streams a -loglevel error")
        .then((value) {
      return value.getOutput().then((output) {
        if (output!.isEmpty) {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(0);
          return 1;
        } else {
          context.read<ArVideoCreation>().setArAudioFlagGeneral(1);
          return 1;
        }
      });
    });
  }

  Future<File> getImage({required String url}) async {
    /// Get Image from server
    final dio.Response res = await dio.Dio().get<List<int>>(
      url,
      options: dio.Options(
        responseType: dio.ResponseType.bytes,
      ),
    );

    /// Get App local storage
    final Directory appDir = await getApplicationDocumentsDirectory();
    String timeNow = Timestamp.now().millisecondsSinceEpoch.toString();

    /// Generate Image Name
    final String imageName = "${timeNow}videoFilePexel.mp4";

    /// Create Empty File in app dir & fill with new image
    final File file = File(path.join(appDir.path, imageName));
    file.writeAsBytesSync(res.data as List<int>);

    return file;
  }

  ValueNotifier<String> _materialValue = ValueNotifier<String>("AR");
  ValueNotifier<bool> deleteItems = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    switch (goToMaterial) {
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
    return Scaffold(
      backgroundColor: constantColors.bioBg,
      appBar: AppBarWidget(
        text: LocaleKeys.myMaterials.tr(),
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
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: ToggleSwitch(
                minWidth: 50.w,
                initialLabelIndex: goToMaterial,
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
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      title: "Delete Item?",
                                                      text:
                                                          "Are you sure you want to delete this?",
                                                      showCancelBtn: true,
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
                                                imageUrl: arSnap["imgSeq"][0]),
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
                                .orderBy("timestamp", descending: true)
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
                                        Get.bottomSheet(
                                          Container(
                                            height: 20.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                              color: constantColors.whiteColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                constantColors
                                                                    .navButton),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              child:
                                                                  BackgroundVideoViewer(
                                                                videoUrl:
                                                                    arSnap[
                                                                        'main'],
                                                              ),
                                                              type: PageTransitionType
                                                                  .rightToLeft),
                                                        );
                                                      },
                                                      icon: Icon(
                                                          Icons.play_arrow),
                                                      label: Text(
                                                        "Play Video",
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                constantColors
                                                                    .navButton),
                                                      ),
                                                      onPressed: () async {
                                                        CoolAlert.show(
                                                          context: context,
                                                          type: CoolAlertType
                                                              .loading,
                                                        );
                                                        final int audioFlag =
                                                            await audioCheck(
                                                                videoUrl:
                                                                    arSnap[
                                                                        'main'],
                                                                context:
                                                                    context);

                                                        switch (audioFlag) {
                                                          case 1:
                                                            await getImage(
                                                                    url: arSnap[
                                                                        'main'])
                                                                .then((value) {
                                                              context
                                                                  .read<
                                                                      VideoEditorProvider>()
                                                                  .setBackgroundVideoFile(
                                                                      File(value
                                                                          .path));

                                                              context
                                                                  .read<
                                                                      VideoEditorProvider>()
                                                                  .setBackgroundVideoController();

                                                              context
                                                                  .read<
                                                                      ArVideoCreation>()
                                                                  .setFromPexel(
                                                                      false);

                                                              PostMaterialModel
                                                                  postMaterial =
                                                                  PostMaterialModel.fromMap(arSnap
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>);

                                                              context
                                                                  .read<
                                                                      VideoEditorProvider>()
                                                                  .setBackgroundVideoId(
                                                                      postMaterial);
                                                            });

                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute<
                                                                        void>(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        InitVideoEditorScreen()));

                                                            break;
                                                          default:
                                                            CoolAlert.show(
                                                              context: context,
                                                              type:
                                                                  CoolAlertType
                                                                      .info,
                                                              title: LocaleKeys
                                                                  .videocontainsnoaudio
                                                                  .tr(),
                                                              text: LocaleKeys
                                                                  .onlyVideoWithAudioSupported
                                                                  .tr(),
                                                            );
                                                        }
                                                      },
                                                      icon: Icon(
                                                          Icons.upload_sharp),
                                                      label: Text(
                                                        "Use Video",
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
                                                      showCancelBtn: true,
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
                                .orderBy("timestamp", descending: true)
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
                                                      showCancelBtn: true,
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
