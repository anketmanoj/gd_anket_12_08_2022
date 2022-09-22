import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/ProfilePage/ArViewerScreen.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/MyCollectionPage/backgroundVideoViewer.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MyCollectionHome extends StatefulWidget {
  MyCollectionHome({Key? key}) : super(key: key);

  @override
  State<MyCollectionHome> createState() => _MyCollectionHomeState();
}

class _MyCollectionHomeState extends State<MyCollectionHome> {
  final ConstantColors constantColors = ConstantColors();

  ValueNotifier<String> _isFreeVal = ValueNotifier<String>("My Items");

  ValueNotifier<bool> _isPackageVal = ValueNotifier<bool>(true);

  ValueNotifier<String> _materialValue = ValueNotifier<String>("AR");

  ValueNotifier<String> _myItemsMaterialValue = ValueNotifier<String>("AR");

  String? folderName;
  File? audioFile;

  bool loading = false;

  void runARCommand({required MyArCollection myAr}) {
    final String audioFile = myAr.audioFile;

    // ignore: cascade_invocations
    final String folderName = audioFile.split(myAr.id).toList()[0];
    final String fileName = "${myAr.id}imgSeq";

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageSeqAniScreen(
          folderName: folderName,
          fileName: fileName,
          MyAR: myAr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(text: "My Materials", context: context),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Center(
              child: ToggleSwitch(
                minWidth: size.width * 0.5,
                totalSwitches: 3,
                activeBgColor: [
                  constantColors.navButton,
                  constantColors.navButton,
                  constantColors.navButton,
                ],
                labels: ['My Items', 'Standard', 'Diamond'],
                onToggle: (index) {
                  switch (index) {
                    case 0:
                      _isFreeVal.value = "My Items";
                      _isPackageVal.value = true;
                      break;
                    case 1:
                      _isFreeVal.value = "Free";
                      _isPackageVal.value = true;
                      break;
                    case 2:
                      _isFreeVal.value = "Paid";
                      _isPackageVal.value = true;
                      break;
                  }
                },
              ),
            ),
            ValueListenableBuilder<String>(
                valueListenable: _isFreeVal,
                builder: (context, value, child) {
                  if (_isFreeVal.value != "My Items") {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: ToggleSwitch(
                          activeBgColor: [
                            constantColors.navButton,
                            constantColors.navButton,
                          ],
                          minWidth: size.width * 0.5,
                          totalSwitches: 2,
                          labels: ['Package', 'Materials'],
                          onToggle: (index) {
                            if (index == 0) {
                              _isPackageVal.value = true;
                            } else {
                              _isPackageVal.value = false;
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: ToggleSwitch(
                          activeBgColor: [
                            constantColors.navButton,
                            constantColors.navButton,
                          ],
                          initialLabelIndex: 0,
                          minWidth: size.width * 0.5,
                          totalSwitches: 2,
                          labels: ['AR', 'Effects'],
                          onToggle: (index) {
                            switch (index) {
                              case 0:
                                _myItemsMaterialValue.value = "AR";
                                break;

                              case 1:
                                _myItemsMaterialValue.value = "Effects";
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  }
                }),
            ValueListenableBuilder<bool>(
              valueListenable: _isPackageVal,
              builder: (context, value, child) {
                if (value == false) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: ToggleSwitch(
                        activeBgColor: [
                          constantColors.navButton,
                          constantColors.navButton,
                        ],
                        initialLabelIndex: 0,
                        minWidth: size.width * 0.5,
                        totalSwitches: 3,
                        labels: ['AR', 'Background', 'Effects'],
                        onToggle: (index) {
                          switch (index) {
                            case 0:
                              _materialValue.value = "AR";
                              break;
                            case 1:
                              _materialValue.value = "Background";
                              break;
                            case 2:
                              _materialValue.value = "Effects";
                              break;
                          }
                        },
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _isFreeVal,
                    _isPackageVal,
                    _materialValue,
                    _myItemsMaterialValue,
                  ]),
                  builder: (context, _) {
                    switch (_isFreeVal.value) {
                      case 'Free':
                        switch (_isPackageVal.value) {
                          case true:
                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                    .collection("MyCollection")
                                    .where("isfree", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var videoSnap =
                                            snapshot.data!.docs[index];

                                        print(videoSnap.id);

                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: PostDetailsScreen(
                                                      videoId: videoSnap.id,
                                                    ),
                                                    type: PageTransitionType
                                                        .fade));
                                          },
                                          child: GridTile(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: ImageNetworkLoader(
                                                      imageUrl: videoSnap[
                                                              "thumbnailurl"]
                                                          .toString())),
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
                                });

                          case false:
                            switch (_materialValue.value) {
                              case "AR":
                                return loading == false
                                    ? StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(Provider.of<Authentication>(
                                                    context,
                                                    listen: false)
                                                .getUserId)
                                            .collection("MyCollection")
                                            .where("valueType",
                                                isEqualTo: "free")
                                            .where("layerType", isEqualTo: "AR")
                                            .where("usage",
                                                isEqualTo: "Material")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.length ==
                                                0) {
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
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                var arSnap =
                                                    snapshot.data!.docs[index];

                                                MyArCollection myAr =
                                                    MyArCollection.fromJson(
                                                        arSnap.data() as Map<
                                                            String, dynamic>);

                                                return InkWell(
                                                  onTap: () {
                                                    runARCommand(myAr: myAr);
                                                  },
                                                  child: GridTile(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Image.asset(
                                                                  "assets/arViewer/bg.png")
                                                              .image,
                                                        )),
                                                        height: 50,
                                                        width: 50,
                                                        child: ImageNetworkLoader(
                                                            imageUrl: arSnap[
                                                                    "gif"]
                                                                .toString()),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        })
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              case "Background":
                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
                                                listen: false)
                                            .getUserId)
                                        .collection("MyCollection")
                                        .where("valueType", isEqualTo: "free")
                                        .where("layerType",
                                            isEqualTo: "Background")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.docs.length == 0) {
                                          return Center(
                                            child: Text(
                                                "No Backgrounds Added Yet!"),
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
                                            var arSnap =
                                                snapshot.data!.docs[index];

                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child:
                                                          BackgroundVideoViewer(
                                                        videoUrl:
                                                            arSnap['main'],
                                                      ),
                                                      type: PageTransitionType
                                                          .rightToLeft),
                                                );
                                              },
                                              child: GridTile(
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
                                                        imageUrl: arSnap["gif"]
                                                            .toString()),
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
                                    });
                              case "Effects":
                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
                                                listen: false)
                                            .getUserId)
                                        .collection("MyCollection")
                                        .where("valueType", isEqualTo: "free")
                                        .where("layerType", isEqualTo: "Effect")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.docs.length == 0) {
                                          return Center(
                                            child:
                                                Text("No Effects Added Yet!"),
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
                                            var arSnap =
                                                snapshot.data!.docs[index];

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
                                                        imageUrl: arSnap["gif"]
                                                            .toString()),
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
                                    });
                            }
                        }
                        break;
                      case 'Paid':
                        switch (_isPackageVal.value) {
                          case true:
                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                    .collection("MyCollection")
                                    .where("isfree", isEqualTo: false)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    print(
                                        "length ${snapshot.data!.docs.length}");
                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var videoSnap =
                                            snapshot.data!.docs[index];

                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: PostDetailsScreen(
                                                      videoId: videoSnap.id,
                                                    ),
                                                    type: PageTransitionType
                                                        .fade));
                                          },
                                          child: GridTile(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                child: ImageNetworkLoader(
                                                    imageUrl: videoSnap[
                                                            "thumbnailurl"]
                                                        .toString()),
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
                                });
                          case false:
                            switch (_materialValue.value) {
                              case "AR":
                                return loading == false
                                    ? StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(Provider.of<Authentication>(
                                                    context,
                                                    listen: false)
                                                .getUserId)
                                            .collection("MyCollection")
                                            .where("valueType",
                                                isEqualTo: "paid")
                                            .where("layerType", isEqualTo: "AR")
                                            .where("usage",
                                                isEqualTo: "Material")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data!.docs.length ==
                                                0) {
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
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                var arSnap =
                                                    snapshot.data!.docs[index];

                                                MyArCollection myAr =
                                                    MyArCollection.fromJson(
                                                        arSnap.data() as Map<
                                                            String, dynamic>);

                                                return InkWell(
                                                  onTap: () {
                                                    runARCommand(myAr: myAr);
                                                  },
                                                  child: GridTile(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Image.asset(
                                                                  "assets/arViewer/bg.png")
                                                              .image,
                                                        )),
                                                        height: 50,
                                                        width: 50,
                                                        child: ImageNetworkLoader(
                                                            imageUrl: arSnap[
                                                                    "gif"]
                                                                .toString()),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        })
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              case "Background":
                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
                                                listen: false)
                                            .getUserId)
                                        .collection("MyCollection")
                                        .where("valueType", isEqualTo: "paid")
                                        .where("layerType",
                                            isEqualTo: "Background")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.docs.length == 0) {
                                          return Center(
                                            child: Text(
                                                "No Background Added Yet!"),
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
                                            var arSnap =
                                                snapshot.data!.docs[index];

                                            return InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child:
                                                          BackgroundVideoViewer(
                                                        videoUrl:
                                                            arSnap['main'],
                                                      ),
                                                      type: PageTransitionType
                                                          .rightToLeft),
                                                );
                                              },
                                              child: GridTile(
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
                                                        imageUrl: arSnap["gif"]
                                                            .toString()),
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
                                    });
                              case "Effects":
                                return StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
                                                listen: false)
                                            .getUserId)
                                        .collection("MyCollection")
                                        .where("valueType", isEqualTo: "paid")
                                        .where("layerType", isEqualTo: "Effect")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data!.docs.length == 0) {
                                          return Center(
                                            child: Text("No Effect Added Yet!"),
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
                                            var arSnap =
                                                snapshot.data!.docs[index];

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
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.asset(
                                                                "assets/arViewer/bg.png")
                                                            .image,
                                                      )),
                                                      height: 50,
                                                      width: 50,
                                                      child: ImageNetworkLoader(
                                                          imageUrl:
                                                              arSnap["gif"]
                                                                  .toString())),
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
                                    });
                            }
                        }
                        break;
                      case "My Items":
                        switch (_myItemsMaterialValue.value) {
                          case "AR":
                            return loading == false
                                ? StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(Provider.of<Authentication>(
                                                context,
                                                listen: false)
                                            .getUserId)
                                        .collection("MyCollection")
                                        .where("valueType",
                                            isEqualTo: "myItems")
                                        .where("layerType", isEqualTo: "AR")
                                        .where("usage", isEqualTo: "Material")
                                        .snapshots(),
                                    builder: (context, snapshot) {
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
                                            var arSnap =
                                                snapshot.data!.docs[index];

                                            MyArCollection myAr =
                                                MyArCollection.fromJson(arSnap
                                                        .data()
                                                    as Map<String, dynamic>);

                                            return InkWell(
                                              onTap: () {
                                                runARCommand(myAr: myAr);
                                              },
                                              child: GridTile(
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
                                                        imageUrl: arSnap["gif"]
                                                            .toString()),
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
                                    })
                                : Center(
                                    child: CircularProgressIndicator(),
                                  );

                          case "Effects":
                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                    .collection("MyCollection")
                                    .where("valueType", isEqualTo: "myItems")
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
                                                    imageUrl: arSnap["gif"]
                                                        .toString()),
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
                                });
                        }
                        break;
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
