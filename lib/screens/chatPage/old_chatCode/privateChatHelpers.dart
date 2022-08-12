import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PrivateChatHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  int? unReadMsgs;
  int? get getUnReadMsgs => unReadMsgs;

  Future countUnReadMsgs(
      {required DocumentSnapshot documentSnapshot,
      required BuildContext context}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .doc(documentSnapshot.id)
        .collection("messages")
        .where('msgSeen', isEqualTo: false)
        .get()
        .then((value) {
      unReadMsgs = value.docs.length;
    });

    print("$unReadMsgs new msgs");
  }

  Future msgReadByUser(
      {required DocumentSnapshot documentSnapshot,
      required BuildContext context}) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .doc(documentSnapshot.id)
        .collection("messages")
        .get()
        .then((value) async {
      value.docs.forEach((msg) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .collection("chats")
            .doc(documentSnapshot.id)
            .collection("messages")
            .doc(msg['messageid'])
            .update({
          'msgSeen': true,
        });
      });
    });
  }

  showChatrooms({required BuildContext context, required String userUid}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .collection("chats")
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, chatroomSnaps) {
        if (chatroomSnaps.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatroomSnaps.data!.size < 1) {
          return Center(
            child: Text(
              "No Chats Yet",
              style: TextStyle(
                color: constantColors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return ListView(
          children:
              chatroomSnaps.data!.docs.map((DocumentSnapshot documentSnapshot) {
            return ListTile(
              onTap: () async {
                // here
                await msgReadByUser(
                    documentSnapshot: documentSnapshot, context: context);
                Navigator.push(
                    context,
                    PageTransition(
                        child:
                            PrivateMessage(documentSnapshot: documentSnapshot),
                        type: PageTransitionType.rightToLeft));
              },
              onLongPress: () {},
              title: Text(
                documentSnapshot['username'],
                style: TextStyle(
                  color: constantColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(Provider.of<Authentication>(context,
                                  listen: false)
                              .getUserId)
                          .collection("chats")
                          .doc(documentSnapshot.id)
                          .collection("messages")
                          .where('msgSeen', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 0,
                            width: 0,
                          );
                        } else {
                          return Visibility(
                            visible: snapshot.data!.docs.isNotEmpty,
                            child: Text(
                              "${snapshot.data!.docs.length} New Messages",
                              style: TextStyle(
                                color: constantColors.redColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                      }),
                  Text(
                    timeago.format(
                        (documentSnapshot['time'] as Timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.mainColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(Provider.of<Authentication>(context, listen: false)
                          .getUserId)
                      .collection("chats")
                      .doc(documentSnapshot.id)
                      .collection("messages")
                      .orderBy('time', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.data!.docs.isNotEmpty) {
                        return Text(
                          snapshot.data!.docs[0]['message']
                                  .toString()
                                  .isNotEmpty
                              ? "${snapshot.data!.docs[0]['username']}: ${snapshot.data!.docs[0]['message']}"
                              : "${snapshot.data!.docs[0]['username']}: Sticker",
                          style: TextStyle(
                            color: constantColors.mainColor,
                            fontSize: 10,
                          ),
                        );
                      } else {
                        return Text(
                          "",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 10,
                          ),
                        );
                      }
                    } catch (e) {
                      return Center(
                        child: Text(e.toString()),
                      );
                    }
                  }),
              leading: CircleAvatar(
                backgroundColor: constantColors.transperant,
                backgroundImage: NetworkImage(documentSnapshot['userimage']),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
