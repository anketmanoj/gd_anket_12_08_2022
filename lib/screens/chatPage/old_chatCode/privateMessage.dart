import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/image_utils_provider.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessageHelper.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/fcm_notification_Service.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nanoid/nanoid.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PrivateMessage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  const PrivateMessage({Key? key, required this.documentSnapshot})
      : super(key: key);

  @override
  _PrivateMessageState createState() => _PrivateMessageState();
}

class _PrivateMessageState extends State<PrivateMessage> {
  ConstantColors constantColors = ConstantColors();
  TextEditingController messageController = TextEditingController();
  final FCMNotificationService _fcmNotificationService =
      FCMNotificationService();
  final _formKey = GlobalKey<FormState>();

  String? thisDeviceToken;
  String? otherDeviceToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    load();
  }

  Future<void> load() async {
    DocumentSnapshot thisDeviceDocSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .get();

    DocumentSnapshot otherDeviceDocSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.documentSnapshot.id)
        .get();

    setState(() {
      thisDeviceToken = thisDeviceDocSnap['token'];
      otherDeviceToken = otherDeviceDocSnap['token'];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        // bottomSheet: _bottomSheet(),
        backgroundColor: constantColors.darkColor,
        appBar: AppBar(
          leadingWidth: 90,
          actions: [
            IconButton(
              onPressed: () {
                Provider.of<PrivateMessageHelper>(context, listen: false)
                    .deleteChat(
                        context: context,
                        documentSnapshot: widget.documentSnapshot);
              },
              icon: Icon(EvaIcons.trash, color: constantColors.redColor),
            ),
            Provider.of<Authentication>(context, listen: false).getUserId ==
                    widget.documentSnapshot['useruid']
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(
                      EvaIcons.moreVertical,
                      color: constantColors.whiteColor,
                    ),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
          leading: Row(
            children: [
              // IconButton to go back to the previous page
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CircleAvatar(
                backgroundColor: constantColors.darkColor,
                backgroundImage: NetworkImage(
                  widget.documentSnapshot['userimage'],
                  scale: 0.2,
                ),
              ),
            ],
          ),
          backgroundColor: constantColors.navButton,
          centerTitle: false,
          title: Text(
            widget.documentSnapshot['username'],
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: constantColors.whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AnimatedContainer(
                  color: constantColors.whiteColor,
                  height: MediaQuery.of(context).size.height * 0.72,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(seconds: 1),
                  curve: Curves.bounceIn,
                  child:
                      Provider.of<PrivateMessageHelper>(context, listen: false)
                          .showMessages(
                              context: context,
                              documentSnapshot: widget.documentSnapshot,
                              adminUserUid: widget.documentSnapshot['useruid']),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // add emoji icon button

                        Padding(
                          padding: const EdgeInsets.only(
                            right: 15,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              selectImage(context).whenComplete(() async {
                                String messageId = nanoid(14).toString();
                                await Provider.of<PrivateMessageHelper>(context,
                                        listen: false)
                                    .sendImageMessage(
                                  context: context,
                                  documentSnapshot: widget.documentSnapshot,
                                  imageUrl: Provider.of<ImageUtils>(context,
                                          listen: false)
                                      .chatImageUrl,
                                  messageId: messageId,
                                );

                                FocusScope.of(context).unfocus();

                                await _fcmNotificationService
                                    .sendNotificationToUser(
                                        to:
                                            otherDeviceToken!, //To change once set up
                                        title:
                                            "${LocaleKeys.newMessageFrom.tr()} ${Provider.of<FirebaseOperations>(context, listen: false).getInitUserName}",
                                        body: "")
                                    .whenComplete(() {
                                  print("notification sent");
                                });

                                await Provider.of<PrivateMessageHelper>(context,
                                        listen: false)
                                    .updateTime(
                                        context: context,
                                        documentSnapshot:
                                            widget.documentSnapshot);

                                messageController.clear();
                              });
                            },
                            child: Icon(
                              FontAwesomeIcons.camera,
                              color: constantColors.navButton,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(
                              color: constantColors.black,
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: LocaleKeys.typeamessage.tr(),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate() ==
                                        true) {
                                      String messageId = nanoid(14).toString();
                                      await Provider.of<PrivateMessageHelper>(
                                              context,
                                              listen: false)
                                          .sendMessage(
                                        context: context,
                                        documentSnapshot:
                                            widget.documentSnapshot,
                                        messagecontroller: messageController,
                                        messageId: messageId,
                                      );

                                      FocusScope.of(context).unfocus();

                                      await _fcmNotificationService
                                          .sendNotificationToUser(
                                              to:
                                                  otherDeviceToken!, //To change once set up
                                              title:
                                                  "${LocaleKeys.newMessageFrom.tr()} ${Provider.of<FirebaseOperations>(context, listen: false).getInitUserName}",
                                              body: messageController.text)
                                          .whenComplete(() {
                                        print("notification sent");
                                      });

                                      await Provider.of<PrivateMessageHelper>(
                                              context,
                                              listen: false)
                                          .updateTime(
                                              context: context,
                                              documentSnapshot:
                                                  widget.documentSnapshot);

                                      messageController.clear();
                                    }
                                  },
                                  icon: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: constantColors.navButton,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.send,
                                      color: constantColors.greyColor,
                                      size: 18,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future selectImage(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            bottom: true,
            child: Container(
              // ignore: sort_child_properties_last
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                          color: constantColors.navButton,
                          child: Text(
                            'Gallery',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickChatImage(context, ImageSource.gallery);
                            //     .whenComplete(() {
                            //   Provider.of<ImageUtils>(context, listen: false)
                            //       .showChatImage(context);
                            // });
                          }),
                      MaterialButton(
                          color: constantColors.navButton,
                          child: Text(
                            'Camera',
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<ImageUtils>(context, listen: false)
                                .pickChatImage(context, ImageSource.camera);
                            //     .whenComplete(() {
                            //   Provider.of<ImageUtils>(context, listen: false)
                            //       .showChatImage(context);
                            // });
                          }),
                    ],
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
  }
}
