import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/ArPreviewSetting/ArPreviewScreen.dart';
import 'package:diamon_rose_app/services/ArPendingModel.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class GDARNotificationScreen extends StatelessWidget {
  GDARNotificationScreen({Key? key}) : super(key: key);
  ValueNotifier<bool> selectDelete = ValueNotifier<bool>(false);
  ValueNotifier<List<String>> postIdsToDelete = ValueNotifier<List<String>>([]);

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
    return AnimatedBuilder(
        animation: Listenable.merge([
          selectDelete,
          postIdsToDelete,
        ]),
        builder: (context, _) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: constantColors.navButton,
              onPressed: () {
                postIdsToDelete.value.clear();
                selectDelete.value = !selectDelete.value;
              },
              child: Icon(
                Icons.delete_sweep,
                color: constantColors.whiteColor,
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(Provider.of<Authentication>(context, listen: false)
                      .getUserId)
                  .collection("MyCollection")
                  .where("usage", isEqualTo: "Pending")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snaps) {
                if (snaps.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snaps.data!.docs.length == 0) {
                  return Center(
                    child: Text(LocaleKeys.nogdarpending.tr()),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snaps.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            final ArPendingModel arPendingModel =
                                ArPendingModel.fromMap(snaps.data!.docs[index]
                                    .data() as Map<String, dynamic>);

                            return Slidable(
                              enabled: snaps.data!.docs[index]['main'] != null
                                  ? true
                                  : false,
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.info,
                                        title: "Delete this AR?",
                                        text:
                                            "Are you sure you want to delete this AR?",
                                        showCancelBtn: true,
                                        onConfirmBtnTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(Provider.of<Authentication>(
                                                      context,
                                                      listen: false)
                                                  .getUserId)
                                              .collection("MyCollection")
                                              .doc(arPendingModel.id)
                                              .delete();

                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete_forever,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: AnimatedBuilder(
                                  animation: Listenable.merge([
                                    arPendingModel.deletethis,
                                  ]),
                                  builder: (context, _) {
                                    return ListTile(
                                      onTap: () async {
                                        if (snaps.data!.docs[index]['main'] ==
                                            null) {
                                          // ignore: unawaited_futures
                                          CoolAlert.show(
                                            context: context,
                                            type: CoolAlertType.info,
                                            title:
                                                LocaleKeys.gdarprocessing.tr(),
                                            text: LocaleKeys
                                                .yourgdarisbeingprocessedyouwillbenotifiedonceitsdone
                                                .tr(),
                                          );
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(Provider.of<Authentication>(
                                                      context,
                                                      listen: false)
                                                  .getUserId)
                                              .collection("MyCollection")
                                              .doc(arPendingModel.id)
                                              .get()
                                              .then((arVal) {
                                            MyArCollection arDoc =
                                                MyArCollection.fromJson(
                                                    arVal.data()!);

                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child: ArPreviewSetting(
                                                      gifUrl: arDoc.gif,
                                                      ownerName:
                                                          arDoc.ownerName,
                                                      audioFlag:
                                                          arDoc.audioFlag ==
                                                                  true
                                                              ? 1
                                                              : 0,
                                                      alphaUrl: arDoc.alpha,
                                                      audioUrl: arDoc.audioFile,
                                                      imgSeqList: arDoc.imgSeq,
                                                      arIdVal: arDoc.id,
                                                      inputUrl: arDoc.main,
                                                      userUid: arDoc.ownerId,
                                                      endDuration:
                                                          parseDuration(arDoc
                                                              .endDuration!),
                                                    ),
                                                    type: PageTransitionType
                                                        .fade));
                                          });
                                        }
                                      },
                                      title:
                                          Text("${arPendingModel.ownerName}"),
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        child: ImageNetworkLoader(
                                            imageUrl: arPendingModel.gif),
                                      ),
                                      trailing: snaps.data!.docs[index]
                                                      ['main'] !=
                                                  null &&
                                              selectDelete.value == true
                                          ? Switch(
                                              value: arPendingModel
                                                  .deletethis!.value,
                                              onChanged: (v) {
                                                if (postIdsToDelete
                                                        .value.length >
                                                    10) {
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.info,
                                                      title: "Max delete is 10",
                                                      text:
                                                          "You can only delete 10 items in 1 go.\nPlease delete these first before selecting more items to delete");
                                                } else {
                                                  log("v = $v");
                                                  if (v == true) {
                                                    log("added");
                                                    postIdsToDelete.value
                                                        .add(arPendingModel.id);
                                                  } else {
                                                    log("removed");
                                                    postIdsToDelete.value
                                                        .remove(
                                                            arPendingModel.id);
                                                  }
                                                  arPendingModel
                                                      .deletethis!.value = v;
                                                  log(postIdsToDelete
                                                      .toString());
                                                }
                                              })
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: snaps.data!.docs[index]
                                                            ['main'] ==
                                                        null
                                                    ? constantColors.navButton
                                                    : Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                  snaps.data!.docs[index]
                                                              ['main'] ==
                                                          null
                                                      ? LocaleKeys.pending.tr()
                                                      : LocaleKeys.ready.tr(),
                                                  style: TextStyle(
                                                    color: constantColors
                                                        .whiteColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    );
                                  }),
                            );
                          },
                        ),
                        Visibility(
                          visible: selectDelete.value == true,
                          child: Container(
                            height: 7.h,
                            width: 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    CoolAlert.show(
                                      context: context,
                                      type: CoolAlertType.info,
                                      title:
                                          "Delete ${postIdsToDelete.value.length} posts?",
                                      text:
                                          "Are you sure you want to delete these AR's?",
                                      showCancelBtn: true,
                                      onConfirmBtnTap: () async {
                                        for (String postId
                                            in postIdsToDelete.value) {
                                          log("delete this id = $postId");
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(Provider.of<Authentication>(
                                                      context,
                                                      listen: false)
                                                  .getUserId)
                                              .collection("MyCollection")
                                              .doc(postId)
                                              .delete();
                                        }

                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.delete_forever),
                                  label: Text(LocaleKeys.deleteSelected.tr()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
