// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageUtils extends ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  UploadTask? imageUploadTask;
  final picker = ImagePicker();
  late File userAvatar;
  late String userAvatarUrl;
  late File userCover;
  late String userCoverUrl;
  late File chatImage;
  late String chatImageUrl;

  File get getUserAvatar => userAvatar;
  String get getUserAvatarUrl => userAvatarUrl;
  File get getUserCover => userCover;
  String get getUserCoverUrl => userCoverUrl;
  File get getChatImage => chatImage;
  String get getChatImageUrl => chatImageUrl;

  Future pickUserAvatar(BuildContext context, ImageSource source) async {
    final pickedUserAvatar = await picker.pickImage(source: source);
    pickedUserAvatar == null
        // ignore: avoid_print
        ? print("select image")
        : userAvatar = File(pickedUserAvatar.path);
    // ignore: avoid_print
    print(userAvatar.path);

    // ignore: unnecessary_null_comparison
    userAvatar != null ? showUserAvatar(context) : print("Image upload error");

    notifyListeners();
  }

  // pick chat image
  Future pickChatImage(BuildContext context, ImageSource source) async {
    final pickedChatImage = await picker.pickImage(source: source);
    pickedChatImage == null
        // ignore: avoid_print
        ? print("select image")
        : chatImage = File(pickedChatImage.path);
    // ignore: avoid_print
    print(chatImage.path);

    // ignore: unnecessary_null_comparison
    chatImage != null ? showChatImage(context) : print("Image upload error");

    notifyListeners();
  }

  Future uploadChatImage(BuildContext context) async {
    final Reference imageReference = FirebaseStorage.instance
        .ref()
        .child("chatImages/${chatImage.path}/${TimeOfDay.now()}");
    imageUploadTask = imageReference.putFile(chatImage);
    await imageUploadTask!.whenComplete(
      () {
        print("Image uploaded!");
      },
    );
    await imageReference.getDownloadURL().then((url) {
      chatImageUrl = url.toString();
      // Provider.of<ImageUtils>(context, listen: false).userAvatarUrl =
      //     url.toString();
      print(" Chat image is at $chatImageUrl");
      notifyListeners();
    });
  }

  Future pickUserCover(BuildContext context, ImageSource source) async {
    final pickedUserCover = await picker.pickImage(source: source);
    pickedUserCover == null
        // ignore: avoid_print
        ? print("select image")
        : userCover = File(pickedUserCover.path);
    // ignore: avoid_print
    print(userCover.path);

    // ignore: unnecessary_null_comparison
    userCover != null ? showUserCover(context) : print("Image upload error");

    notifyListeners();
  }

  Future showChatImage(BuildContext context) async {
    return showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    fit: BoxFit.contain,
                    image: FileImage(
                      chatImage,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel button
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: constantColors.redColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // Upload button
                      FlatButton(
                        onPressed: () async {
                          // Show uploading image cool alert
                          CoolAlert.show(
                            context: context,
                            barrierDismissible: false,
                            title: "Uploading image",
                            text: "Please wait",
                            type: CoolAlertType.loading,
                          );
                          // ignore: unnecessary_statements
                          await uploadChatImage(context).whenComplete(() {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text(
                          "Upload",
                          style: TextStyle(
                            color: constantColors.redColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future showUserAvatar(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            bottom: true,
            child: Container(
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
                      Text("Select Profile Picture",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: constantColors.transperant,
                      backgroundImage: FileImage(
                        userAvatar,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          child: Text(
                            "Reselect",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: constantColors.whiteColor,
                            ),
                          ),
                          onPressed: () {
                            pickUserAvatar(
                              context,
                              ImageSource.gallery,
                            );
                          },
                        ),
                        MaterialButton(
                          color: constantColors.blueColor,
                          child: Text(
                            "Confirm Image",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.loading,
                                text: "Updating your profile picture");
                            await Provider.of<FirebaseOperations>(context,
                                    listen: false)
                                .uploadUserAvatar(context)
                                .whenComplete(() async {
                              await Provider.of<FirebaseOperations>(
                                      context,
                                      listen: false)
                                  .updateUserImage(
                                      uid: Provider.of<Authentication>(context,
                                              listen: false)
                                          .getUserId,
                                      imageUrl: Provider.of<ImageUtils>(context,
                                              listen: false)
                                          .userAvatarUrl);

                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        });
  }

  Future showUserCover(BuildContext context) {
    return showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            bottom: true,
            child: Container(
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
                      Text("Select Cover Image",
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: constantColors.transperant,
                      backgroundImage: FileImage(
                        userCover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          child: Text(
                            "Reselect",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: constantColors.whiteColor,
                            ),
                          ),
                          onPressed: () {
                            pickUserCover(
                              context,
                              ImageSource.gallery,
                            );
                          },
                        ),
                        MaterialButton(
                          color: constantColors.blueColor,
                          child: Text(
                            "Confirm Image",
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            // ignore: unawaited_futures
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.loading,
                                text: "Updating Cover Image");
                            await Provider.of<FirebaseOperations>(context,
                                    listen: false)
                                .uploadUserCover(context)
                                .whenComplete(() async {
                              await Provider.of<FirebaseOperations>(
                                      context,
                                      listen: false)
                                  .updateUserCover(
                                      uid: Provider.of<Authentication>(context,
                                              listen: false)
                                          .getUserId,
                                      imageUrl: Provider.of<ImageUtils>(context,
                                              listen: false)
                                          .userCoverUrl);

                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        });
  }

  Future selectAvatarOptionsSheet(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            bottom: true,
            child: Container(
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
                      Text("Select Profile Picture",
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
                            pickUserAvatar(context, ImageSource.gallery)
                                .whenComplete(() {
                              showUserAvatar(context);
                            });
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
                            pickUserAvatar(context, ImageSource.camera)
                                .whenComplete(() {
                              showUserAvatar(context);
                            });
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
