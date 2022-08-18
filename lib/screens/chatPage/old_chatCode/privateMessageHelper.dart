import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/seeChatImage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PrivateMessageHelper with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  showMessages(
      {required BuildContext context,
      required DocumentSnapshot documentSnapshot,
      required String adminUserUid}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .collection("chats")
          .doc(documentSnapshot.id)
          .collection("messages")
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, messageSnaps) {
        if (messageSnaps.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return StatefulBuilder(builder: (context, state) {
            return ListView(
              reverse: true,
              children: messageSnaps.data!.docs.map((DocumentSnapshot msgSnap) {
                return Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.05,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: InkWell(
                    onLongPress: () {
                      if (Provider.of<Authentication>(context, listen: false)
                              .getUserId ==
                          msgSnap['useruid']) {
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.warning,
                          title: "Delete Message?",
                          text:
                              "Are you sure you want to delete this messsage?",
                          cancelBtnText: "No",
                          showCancelBtn: true,
                          confirmBtnText: "Yes",
                          onCancelBtnTap: () => Navigator.pop(context),
                          onConfirmBtnTap: () async {
                            await deleteMessage(
                                context: context,
                                documentSnapshot: documentSnapshot,
                                msgId: msgSnap.id);
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment:
                            Provider.of<Authentication>(context, listen: false)
                                        .getUserId ==
                                    msgSnap['useruid']
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              constraints: BoxConstraints(
                                // maxHeight:
                                //     MediaQuery.of(context).size.height * 0.13,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Provider.of<Authentication>(context,
                                                  listen: false)
                                              .getUserId !=
                                          msgSnap['useruid']
                                      ? Radius.circular(20)
                                      : Radius.circular(0),
                                  topLeft: Provider.of<Authentication>(context,
                                                  listen: false)
                                              .getUserId ==
                                          msgSnap['useruid']
                                      ? Radius.circular(20)
                                      : Radius.circular(0),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                color: Provider.of<Authentication>(context,
                                                listen: false)
                                            .getUserId ==
                                        msgSnap['useruid']
                                    ? constantColors.greyColor.withOpacity(0.8)
                                    : constantColors.navButton,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    msgSnap['message'].toString().isNotEmpty
                                        ? Text(
                                            msgSnap['message'],
                                            style: TextStyle(
                                              color: constantColors.whiteColor,
                                              fontSize: 14,
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SeeChatImage(
                                                              chatImageUrl: msgSnap[
                                                                  'imageurl'])));
                                            },
                                            child: SizedBox(
                                              height: 250,
                                              width: 250,
                                              child: ImageNetworkLoader(
                                                  imageUrl:
                                                      msgSnap['imageurl']),
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: SizedBox(
                                        width: 80,
                                        child: Text(
                                          timeago.format(
                                              (msgSnap['time'] as Timestamp)
                                                  .toDate()),
                                          style: TextStyle(
                                            color: constantColors.whiteColor,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          });
        }
      },
    );
  }

  // Send image as message
  sendImageMessage({
    required BuildContext context,
    required DocumentSnapshot documentSnapshot,
    required String messageId,
    required String imageUrl,
  }) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .doc(documentSnapshot.id)
        .collection("messages")
        .doc(messageId)
        .set({
      'messageid': messageId,
      'message': "",
      'imageurl': imageUrl,
      'time': Timestamp.now(),
      'useruid': Provider.of<Authentication>(context, listen: false).getUserId,
      'username': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserName,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserImage,
      'msgSeen': true,
    }).whenComplete(() async {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(documentSnapshot.id)
          .collection("chats")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .collection("messages")
          .doc(messageId)
          .set({
        'messageid': messageId,
        'message': "",
        'imageurl': imageUrl,
        'time': Timestamp.now(),
        'useruid':
            Provider.of<Authentication>(context, listen: false).getUserId,
        'username': Provider.of<FirebaseOperations>(context, listen: false)
            .getInitUserName,
        'userimage': Provider.of<FirebaseOperations>(context, listen: false)
            .getInitUserImage,
        'msgSeen': false,
      });
    });
  }

  sendMessage(
      {required BuildContext context,
      required DocumentSnapshot documentSnapshot,
      required TextEditingController messagecontroller,
      required String messageId}) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .doc(documentSnapshot.id)
        .collection("messages")
        .doc(messageId)
        .set({
      'messageid': messageId,
      'message': messagecontroller.text,
      'time': Timestamp.now(),
      'useruid': Provider.of<Authentication>(context, listen: false).getUserId,
      'username': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserName,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false)
          .getInitUserImage,
      'msgSeen': true,
    }).whenComplete(() async {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(documentSnapshot.id)
          .collection("chats")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .collection("messages")
          .doc(messageId)
          .set({
        'messageid': messageId,
        'message': messagecontroller.text,
        'time': Timestamp.now(),
        'useruid':
            Provider.of<Authentication>(context, listen: false).getUserId,
        'username': Provider.of<FirebaseOperations>(context, listen: false)
            .getInitUserName,
        'userimage': Provider.of<FirebaseOperations>(context, listen: false)
            .getInitUserImage,
        'msgSeen': false,
      });
    });
  }

  updateTime({
    required BuildContext context,
    required DocumentSnapshot documentSnapshot,
  }) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .doc(documentSnapshot.id)
        .update({
      'time': Timestamp.now(),
    }).whenComplete(() {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(documentSnapshot.id)
          .collection("chats")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .update({
        'time': Timestamp.now(),
      });
    });
  }

  Future deleteMessage({
    required BuildContext context,
    required DocumentSnapshot documentSnapshot,
    required String msgId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .collection("chats")
          .doc(documentSnapshot.id)
          .collection("messages")
          .doc(msgId)
          .delete()
          .whenComplete(() async {
        return await FirebaseFirestore.instance
            .collection("users")
            .doc(documentSnapshot.id)
            .collection("chats")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .collection("messages")
            .doc(msgId)
            .delete()
            .whenComplete(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: "Sign In Failed",
        text: e.toString(),
      );
    }
  }

  deleteChat(
      {required BuildContext context,
      required DocumentSnapshot documentSnapshot}) async {
    return CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: constantColors.darkColor,
      title: "Delete Chat with ${documentSnapshot['username']}?",
      text: "Are you sure you want to delete this conversation?",
      showCancelBtn: true,
      cancelBtnText: "No",
      confirmBtnText: "Yes",
      onCancelBtnTap: () => Navigator.pop(context),
      onConfirmBtnTap: () async {
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(
                  Provider.of<Authentication>(context, listen: false).getUserId)
              .collection("chats")
              .doc(documentSnapshot.id)
              .delete()
              .whenComplete(() async {
            return await FirebaseFirestore.instance
                .collection("users")
                .doc(documentSnapshot.id)
                .collection("chats")
                .doc(Provider.of<Authentication>(context, listen: false)
                    .getUserId)
                .delete()
                .whenComplete(() {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          });
        } catch (e) {
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: "Sign In Failed",
            text: e.toString(),
          );
        }
      },
    );
  }
}
