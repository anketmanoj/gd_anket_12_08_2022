import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          folderName: folderName,
          fileName: fileName,
          MyAR: myAr,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar: AppBarWidget(
          text: LocaleKeys.arviewcollection.tr(), context: context),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(
                  Provider.of<Authentication>(context, listen: false).getUserId)
              .collection("MyCollection")
              .where("layerType", isEqualTo: "AR")
              .where("usage", isEqualTo: "Ar View Only")
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.length == 0) {
                return Center(
                  child: Text("No AR For Viewing Added Yet!"),
                );
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset("assets/arViewer/bg.png").image,
                          )),
                          height: 50,
                          width: 50,
                          child: Image.network(
                            arSnap["gif"].toString(),
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
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
      ),
    );
  }
}
