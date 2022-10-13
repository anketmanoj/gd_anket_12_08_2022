import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/services/NotifyUserModels.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/fcm_notification_Service.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';

class AdminVideoCreator extends ChangeNotifier {
  UserModel? _userModel;
  UserModel? get getUserModel => _userModel;
  List<String> _arIdsVal = [];
  List<String> get getArIdsVal => _arIdsVal;
  late String videoUrl;
  String get getVideoUrl => videoUrl;

  final FCMNotificationService _fcmNotificationService =
      FCMNotificationService();

  void setUserModel(UserModel user) {
    _userModel = user;
    notifyListeners();
  }

  Future<bool> uploadVideo({
    required File backgroundVideoFile,
    required String userUid,
    required String video_title,
    required String caption,
    required String contentAvailability,
    required File videoFile,
    required bool isFree,
    required bool isPaid,
    required bool isSubscription,
    double? price,
    double? discountAmount,
    Timestamp? startDiscountDate,
    Timestamp? endDiscountDate,
    required List<String?> genre,
    required String coverThumbnailUrl,
    List<ARList>? arListVal,
    required BuildContext ctx,
    required bool addBgToMaterials,
  }) async {
    try {
      List<String> arUid = [];
      List<String> effectUID = [];

      final File bgFileThumbnail =
          await Provider.of<FFmpegProvider>(ctx, listen: false)
              .thumbnailCreator(vidFilePath: backgroundVideoFile.path);

      String? uploadedAWS_BgThumbnailFile = await AwsAnketS3.uploadFile(
          accessKey: "AKIATF76MVYR34JAVB7H",
          secretKey: "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",
          bucket: "anketvideobucket",
          file: bgFileThumbnail,
          filename:
              "${Timestamp.now().millisecondsSinceEpoch}_bgThumbnailGif.gif",
          region: "us-east-1",
          destDir: "${Timestamp.now().millisecondsSinceEpoch}");

      String? uploadedAWS_BgFile = await AwsAnketS3.uploadFile(
          accessKey: "AKIATF76MVYR34JAVB7H",
          secretKey: "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",
          bucket: "anketvideobucket",
          file: backgroundVideoFile,
          filename: "${Timestamp.now().millisecondsSinceEpoch}bgfile.mp4",
          region: "us-east-1",
          destDir: "${Timestamp.now().millisecondsSinceEpoch}");

      log("uploadedAWS_BgThumbnailFile = ${uploadedAWS_BgThumbnailFile} \n\n uploadedAWS_BgFile = ${uploadedAWS_BgFile}");

      String idVal = nanoid();

      if (addBgToMaterials == true) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .collection("MyCollection")
            .doc(idVal)
            .set({
          'id': idVal,
          'gif': uploadedAWS_BgThumbnailFile!,
          'main': uploadedAWS_BgFile!,
          'layerType': 'Background',
          'timestamp': Timestamp.now(),
          'valueType': "myItems",
          "ownerId": userUid,
          "ownerName": _userModel!.username,
        }).then((value) {
          _arIdsVal.add(idVal);
          notifyListeners();
        });
      }

      await AwsAnketS3.uploadFile(
              accessKey: "AKIATF76MVYR34JAVB7H",
              secretKey: "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",
              bucket: "anketvideobucket",
              file: videoFile,
              filename:
                  "${Timestamp.now().millisecondsSinceEpoch}videoFile.mp4",
              region: "us-east-1",
              destDir: "${Timestamp.now().millisecondsSinceEpoch}")
          .then((url) {
        videoUrl = url!;
        print(videoUrl + "video url");
        notifyListeners();
      });

      final String id = nanoid().toString();

      print("length of arListVal: ${arListVal!.length}");
      arListVal.forEach((arVal) async {
        print("ar index ${arVal.arIndex}");
        if (arVal.layerType == LayerType.Effect &&
            arVal.fromFirebase == false) {
          // final String idValForEffect = await uploadEffects(
          //   userUid: userUid,
          //   gifFile: File(arVal.gifFilePath!),
          // );

          final String? effectUrl = await AwsAnketS3.uploadFile(
              accessKey: "AKIATF76MVYR34JAVB7H",
              secretKey: "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",
              bucket: "anketvideobucket",
              file: File(arVal.gifFilePath!),
              filename: "${Timestamp.now().millisecondsSinceEpoch}Effect.gif",
              region: "us-east-1",
              destDir: "${userUid}");

          String idVal = nanoid();

          await FirebaseFirestore.instance
              .collection("users")
              .doc(userUid)
              .collection("MyCollection")
              .doc(idVal)
              .set({
            'id': idVal,
            'gif': effectUrl!,
            'layerType': 'Effect',
            'timestamp': Timestamp.now(),
            'valueType': "myItems",
            "ownerId": userUid,
            "ownerName": _userModel!.username,
          });

          log("id for effect == $idVal");
          _arIdsVal.add(idVal);
          notifyListeners();
        } else {
          _arIdsVal.add(arVal.arId!);
          notifyListeners();
        }

        print(
            "added arId: ${arVal.arIndex} to list _arIdsVal |  ${_arIdsVal.length}");
      });

      print("lis of ar == ${getArIdsVal}");

      print("uploading to firestore ${id}");

      String name = "${caption} ${video_title}";

      List<String> splitList = name.split(" ");
      List<String> indexList = [];

      for (int i = 0; i < splitList.length; i++) {
        for (int j = 0; j < splitList[i].length; j++) {
          indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
        }
      }

      await FirebaseFirestore.instance.collection("posts").doc(id).set({
        "id": id,
        "useruid": userUid,
        "videourl": videoUrl,
        "videotitle": video_title,
        "caption": caption,
        "timestamp": Timestamp.now(),
        "username": _userModel!.username,
        "userimage": _userModel!.userimage,
        "thumbnailurl": coverThumbnailUrl,
        "isfree": isFree,
        "ispaid": isPaid,
        "issubscription": isSubscription,
        "price": price,
        "discountamount": discountAmount,
        "startdiscountdate": startDiscountDate,
        "enddiscountdate": endDiscountDate,
        "contentavailability": contentAvailability,
        'ownerFcmToken': _userModel!.token,
        "searchindexList": indexList,
        "genre": genre,
        'boughtBy': [],
        'totalBilled': 0,
        'verifiedUser': _userModel!.isverified,
        "videoType": "video",
        'views': 0,
      }).then((value) {
        _arIdsVal.forEach((arUidVal) async {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userUid)
              .collection("MyCollection")
              .doc(arUidVal)
              .get()
              .then((arSnapshot) async {
            switch (arSnapshot.data()!['layerType']) {
              case "AR":
                log("adding AR to Materials");
                if (arSnapshot.data()!['ownerId'] == userUid) {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "alpha": arSnapshot.data()!['alpha'],
                    "hideItem": false,
                    "audioFile": arSnapshot.data()!['audioFile'],
                    "audioFlag": arSnapshot.data()!['audioFlag'],
                    "gif": arSnapshot.data()!['gif'],
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "imgSeq": arSnapshot.data()!['imgSeq'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "main": arSnapshot.data()!['main'],
                    "timestamp": arSnapshot.data()!['timestamp'],
                    "usage": arSnapshot.data()!['usage'],
                    "valueType": isFree ? "free" : "paid",
                    "videoId": id,
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "alpha": arSnapshot.data()!['alpha'],
                    "hideItem": arSnapshot.data()!['hideItem'],
                    "audioFile": arSnapshot.data()!['audioFile'],
                    "audioFlag": arSnapshot.data()!['audioFlag'],
                    "gif": arSnapshot.data()!['gif'],
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "imgSeq": arSnapshot.data()!['imgSeq'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "main": arSnapshot.data()!['main'],
                    "timestamp": arSnapshot.data()!['timestamp'],
                    "valueType": isFree ? "free" : "paid",
                    "videoId": arSnapshot.data()!['videoId'],
                    "usage": arSnapshot.data()!['usage'],
                  });
                }
                break;
              case "Effect":
                log("adding Effect to Materials");
                if (arSnapshot.data()!['ownerId'] == userUid) {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "hideItem": false,
                    "gif": arSnapshot.data()!['gif'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "timestamp": arSnapshot.data()!['timestamp'],
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "videoId": id,
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "gif": arSnapshot.data()!['gif'],
                    "hideItem": arSnapshot.data()!['hideItem'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "timestamp": arSnapshot.data()!['timestamp'],
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "videoId": arSnapshot.data()!['videoId'],
                  });
                }
                break;
              case "Background":
                log("adding Background to Materials");
                if (arSnapshot.data()!['ownerId'] == userUid) {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "hideItem": false,
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "gif": arSnapshot.data()!['gif'],
                    "main": arSnapshot.data()!['main'],
                    'layerType': 'Background',
                    'timestamp': Timestamp.now(),
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "videoId": id,
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "gif": arSnapshot.data()!['gif'],
                    "main": arSnapshot.data()!['main'],
                    "hideItem": arSnapshot.data()!['hideItem'],
                    'layerType': 'Background',
                    'timestamp': Timestamp.now(),
                    "ownerId": arSnapshot.data()!['ownerId'],
                    "ownerName": arSnapshot.data()!['ownerName'],
                    "videoId": arSnapshot.data()!['videoId'],
                  });
                }
            }
          });
        });
      }).then((value) {
        _arIdsVal = [];
        notifyListeners();
      });

      await notifyAllFromNotifierList(
        accountOwnerId: userUid,
      );

      log("notified");

      return true;
    } catch (e) {
      return false;
      print("ANKET ERROR ${e.toString()}");
    }
  }

  Future notifyAllFromNotifierList({
    required String accountOwnerId,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(accountOwnerId)
        .collection("notifyUsers")
        .get()
        .then((value) => value.docs.forEach((element) async {
              final NotifyUsers notifyUser =
                  NotifyUsers.fromMap(element.data());

              await _fcmNotificationService.sendNotificationToUser(
                  to: notifyUser.token, //To change once set up
                  title:
                      "${_userModel!.username} ${LocaleKeys.hasANewPost.tr()}",
                  body: "");
            }));
  }
}
