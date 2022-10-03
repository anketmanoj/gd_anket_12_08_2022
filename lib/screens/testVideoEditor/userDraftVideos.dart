import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/draftVideos.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class USerDraftVideoScreen extends StatelessWidget {
  USerDraftVideoScreen({Key? key}) : super(key: key);
  ValueNotifier<bool> selectDelete = ValueNotifier<bool>(false);
  ValueNotifier<List<String>> postIdsToDelete = ValueNotifier<List<String>>([]);

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
            appBar: AppBarWidget(text: "Draft Videos", context: context),
            backgroundColor: constantColors.whiteColor,
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("drafts")
                  .where("useruid",
                      isEqualTo:
                          Provider.of<Authentication>(context, listen: false)
                              .getUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error connecting to server"),
                  );
                }
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("No Drafts Saved!"),
                  );
                }

                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DraftVideo video = DraftVideo.fromJson(
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>);

                          return AnimatedBuilder(
                              animation: Listenable.merge([
                                video.deletethis,
                              ]),
                              builder: (context, _) {
                                return ListTile(
                                  onTap: () {
                                    // Navigate to Edit screen
                                  },
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    child: ImageNetworkLoader(
                                      imageUrl: video.thumbnailurl,
                                    ),
                                  ),
                                  title: Text(video.videotitle),
                                  trailing: selectDelete.value
                                      ? Switch(
                                          value: video.deletethis!.value,
                                          onChanged: (v) {
                                            if (postIdsToDelete.value.length >
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
                                                    .add(video.id);
                                              } else {
                                                log("removed");
                                                postIdsToDelete.value
                                                    .remove(video.id);
                                              }
                                              video.deletethis!.value = v;
                                              log(postIdsToDelete.toString());
                                            }
                                          })
                                      : Container(
                                          constraints: BoxConstraints(
                                            minWidth: 15.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: constantColors.navButton,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          padding: EdgeInsets.all(3),
                                          // alignment: Alignment.center,
                                          child: Text(
                                            "Edit",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: constantColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                );
                              });
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
                                        "Delete ${postIdsToDelete.value.length} draft videos?",
                                    text:
                                        "Are you sure you want to delete these drafts?",
                                    onConfirmBtnTap: () async {
                                      for (String postId
                                          in postIdsToDelete.value) {
                                        log("delete this id = $postId");
                                        await FirebaseFirestore.instance
                                            .collection("drafts")
                                            .doc(postId)
                                            .delete();
                                      }

                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete_forever),
                                label: Text("Delete Selected"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}
