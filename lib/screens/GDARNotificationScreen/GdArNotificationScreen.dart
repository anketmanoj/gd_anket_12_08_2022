import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/services/ArPendingModel.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class GDARNotificationScreen extends StatelessWidget {
  const GDARNotificationScreen({Key? key}) : super(key: key);

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    log("${Duration(hours: hours, minutes: minutes, microseconds: micros)}");
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .collection("MyCollection")
            .where("usage", isEqualTo: "Pending")
            .snapshots(),
        builder: (context, snaps) {
          if (snaps.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snaps.data!.docs.length == 0) {
            return Center(
              child: Text("No GD AR Pending"),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: snaps.data!.docs.length,
              itemBuilder: (ctx, index) {
                final ArPendingModel arPendingModel = ArPendingModel.fromMap(
                    snaps.data!.docs[index].data() as Map<String, dynamic>);

                return Slidable(
                  enabled:
                      snaps.data!.docs[index]['main'] != null ? true : false,
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.info,
                              title: "Delete this AR?",
                              text: "Are you sure you want to delete this AR?",
                              onConfirmBtnTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(Provider.of<Authentication>(context,
                                            listen: false)
                                        .getUserId)
                                    .collection("MyCollection")
                                    .doc(arPendingModel.id)
                                    .delete();

                                Navigator.pop(context);
                              });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_forever,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () async {
                      if (snaps.data!.docs[index]['main'] == null) {
                        // ignore: unawaited_futures
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.info,
                          title: "GD AR Processing",
                          text:
                              "Your GD AR is being processed, you will be notified once its done",
                        );
                      } else {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(Provider.of<Authentication>(context,
                                    listen: false)
                                .getUserId)
                            .collection("MyCollection")
                            .doc(arPendingModel.id)
                            .get()
                            .then((arVal) {
                          MyArCollection arDoc =
                              MyArCollection.fromJson(arVal.data()!);

                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ArPreviewSetting(
                                    gifUrl: arDoc.gif,
                                    ownerName: arDoc.ownerName,
                                    audioFlag: arDoc.audioFlag == true ? 1 : 0,
                                    alphaUrl: arDoc.alpha,
                                    audioUrl: arDoc.audioFile,
                                    imgSeqList: arDoc.imgSeq,
                                    arIdVal: arDoc.id,
                                    inputUrl: arDoc.main,
                                    userUid: arDoc.ownerId,
                                    endDuration:
                                        parseDuration(arDoc.endDuration!),
                                  ),
                                  type: PageTransitionType.fade));
                        });
                      }
                    },
                    title: Text("${arPendingModel.ownerName}"),
                    leading: Container(
                      height: 50,
                      width: 50,
                      child: ImageNetworkLoader(imageUrl: arPendingModel.gif),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: snaps.data!.docs[index]['main'] == null
                            ? constantColors.navButton
                            : Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          snaps.data!.docs[index]['main'] == null
                              ? "Pending"
                              : "Ready",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
