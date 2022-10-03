// ignore_for_file: unnecessary_await_in_return

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/providers/caratsProvider.dart';
import 'package:diamon_rose_app/providers/ffmpegProviders.dart';
import 'package:diamon_rose_app/providers/image_utils_provider.dart';
import 'package:diamon_rose_app/providers/social_media_links_provider.dart';
import 'package:diamon_rose_app/screens/OtherUserProfile/otherUserProfile.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/testVideoEditor/ArContainerClass/ArContainerClass.dart';
import 'package:diamon_rose_app/services/ArViewOnlyServerResponse.dart';
import 'package:diamon_rose_app/services/NotifyUserModels.dart';
import 'package:diamon_rose_app/services/RVMServerResponse.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/aws/aws_upload_service.dart';
import 'package:diamon_rose_app/services/fcm_notification_Service.dart';
import 'package:diamon_rose_app/services/mux/mux_video_stream.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:glamorous_diastation/screens/LandingPage/landingUtils.dart';
// import 'package:glamorous_diastation/services/authentication.dart';
// import 'package:glamorous_diastation/services/fcm_notification_Service.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class FirebaseOperations with ChangeNotifier {
  UploadTask? imageUploadTask;
  UploadTask? videoUploadTask;
  UploadTask? thumbnailUploadTask;
  late String thumbnailUrl;
  late String videoUrl;
  List<String> arIdsVal = [];
  late String initUserEmail = "";
  late String initUserName = "";
  late String initUserImage = "";
  late bool isverified = false;
  late String fcmToken;
  int? unReadMsgs;
  late String userAddress;
  late String userbio = "";
  late String usercontactnumber;
  late String usercover = "";
  late String userfacebookurl;
  late String usergender;
  late String userinstagramurl;
  late String userrealname;
  late String usertiktokurl;
  String usercountrycode = "";

  late List<dynamic> usersearchindex;
  late Timestamp userdob;

  int? get getUnReadMsgs => unReadMsgs;
  bool get getIsVerified => isverified;
  String get getFcmToken => fcmToken;
  String get getVideoUrl => videoUrl;
  List<String> get getArIdsVal => arIdsVal;
  String get getThumbnailUrl => thumbnailUrl;
  String get getInitUserImage => initUserImage;
  String get getInitUserEmail => initUserEmail;
  String get getInitUserName => initUserName;
  String get getUserAddress => userAddress;
  String get getUserbio => userbio;
  String get getUsercontactnumber => usercontactnumber;
  String get getUsercover => usercover;
  Timestamp get getUserdob => userdob;

  String get getUserfacebookurl => userfacebookurl;
  String get getUsergender => usergender;
  String get getUserinstagramurl => userinstagramurl;
  String get getUserrealname => userrealname;
  String get getUsertiktokurl => usertiktokurl;
  String get getUsercountrycode => usercountrycode;
  List<dynamic> get getUsersearchindex => usersearchindex;

  late String timePosted;
  String get getTimePosted => timePosted;

  showTimeAgo(dynamic timeData) {
    Timestamp time = timeData;
    DateTime dateTime = time.toDate();
    timePosted = timeago.format(dateTime);

    notifyListeners();
  }

  // Set dob
  void setDob(Timestamp dob) {
    userdob = dob;
    notifyListeners();
  }

  // set username
  Function(String) setUserName(String name) {
    return (String name) {
      initUserName = name;
      notifyListeners();
    };
  }

  // set country code
  void setCountryCode(String code) {
    usercountrycode = code;
    notifyListeners();
  }

  // set user image
  void setUserImage(String image) {
    initUserImage = image;
    notifyListeners();
  }

  // set user email
  void setUserEmail(String email) {
    initUserEmail = email;
    notifyListeners();
  }

  // set user verified
  void setUserVerified(bool verified) {
    isverified = verified;
    notifyListeners();
  }

  // set user fcm token
  void setFcmToken(String token) {
    fcmToken = token;

    print("fcm token is $fcmToken");
    notifyListeners();
  }

  // set user unread messages
  void setUnReadMsgs(int unread) {
    unReadMsgs = unread;
    notifyListeners();
  }

  // set user address
  Function(String) setUserAddress(String address) {
    log("address == $address");
    return (String address) {
      userAddress = address;
      notifyListeners();
    };
  }

  // set user bio
  Function(String) setUserBio(String bio) {
    return (String bio) {
      userbio = bio;
      notifyListeners();
    };
  }

  // set user contact number
  Function(String) setUserContactNumber(String contactnumber) {
    return (String contactnumber) {
      usercontactnumber = contactnumber;
      notifyListeners();
    };
  }

  // set user cover
  void setUserCover(String cover) {
    usercover = cover;
    notifyListeners();
  }

  // set user facebook url
  Function(String) setUserFacebookUrl(String facebookurl) {
    return (String facebookurl) {
      userfacebookurl = facebookurl;
      notifyListeners();
    };
  }

  // set usergender
  void setUserGender(String userGender) {
    usergender = userGender;
    notifyListeners();
  }

  // set user instagram url
  Function(String) setUserInstagramUrl(String instagramurl) {
    return (String instagramurl) {
      userinstagramurl = instagramurl;
      notifyListeners();
    };
  }

  // set user real name
  Function(String) setUserRealName(String realname) {
    return (String realname) {
      userrealname = realname;
      notifyListeners();
    };
  }

  // set user tiktok url
  Function(String) setUserTikTokUrl(String tiktokurl) {
    return (String tiktokurl) {
      usertiktokurl = tiktokurl;
      notifyListeners();
    };
  }

  final FCMNotificationService _fcmNotificationService =
      FCMNotificationService();

  Future uploadUserAvatar(BuildContext context) async {
    final Reference imageReference = FirebaseStorage.instance.ref().child(
        "userProfileAvatar/${Provider.of<ImageUtils>(context, listen: false).getUserAvatar.path}/${TimeOfDay.now()}");
    imageUploadTask = imageReference
        .putFile(Provider.of<ImageUtils>(context, listen: false).getUserAvatar);
    await imageUploadTask!.whenComplete(
      () {
        print("Image uploaded!");
      },
    );
    await imageReference.getDownloadURL().then((url) {
      initUserImage = url.toString();
      Provider.of<ImageUtils>(context, listen: false).userAvatarUrl =
          url.toString();
      print(
          "The user profile avatar url => ${Provider.of<ImageUtils>(context, listen: false).userAvatarUrl}");
      notifyListeners();
    });
  }

  Future<String?> uploadUserProfile(
      {required BuildContext context, required File imgFile}) async {
    String? urlPath;
    final Reference imageReference = FirebaseStorage.instance
        .ref()
        .child("userProfilePicture/${imgFile.path}/${TimeOfDay.now()}");
    imageUploadTask = imageReference.putFile(imgFile);
    await imageUploadTask!.whenComplete(
      () {
        log("Image uploaded!");
      },
    );
    await imageReference.getDownloadURL().then((url) {
      urlPath = url;
      initUserImage = url.toString();

      notifyListeners();
    });

    return urlPath;
  }

  Future<String?> uploadUserCoverImage(
      {required BuildContext context, required File coverFile}) async {
    String? urlPath;
    final Reference imageReference = FirebaseStorage.instance
        .ref()
        .child("userProfilePicture/${coverFile.path}/${TimeOfDay.now()}");
    imageUploadTask = imageReference.putFile(coverFile);
    await imageUploadTask!.whenComplete(
      () {
        log("Image uploaded!");
      },
    );
    await imageReference.getDownloadURL().then((url) {
      urlPath = url;
      usercover = url.toString();

      notifyListeners();
    });

    return urlPath;
  }

  Future uploadUserCover(BuildContext context) async {
    final Reference imageReference = FirebaseStorage.instance.ref().child(
        "userProfileAvatar/${Provider.of<ImageUtils>(context, listen: false).getUserCover.path}/${TimeOfDay.now()}");
    imageUploadTask = imageReference
        .putFile(Provider.of<ImageUtils>(context, listen: false).getUserCover);
    await imageUploadTask!.whenComplete(
      () {
        print("Image uploaded!");
      },
    );
    await imageReference.getDownloadURL().then((url) {
      usercover = url.toString();
      Provider.of<ImageUtils>(context, listen: false).userCoverUrl =
          url.toString();
      print(
          "The user cover image url => ${Provider.of<ImageUtils>(context, listen: false).userCoverUrl}");
      notifyListeners();
    });
  }

  Future createUserCollection(BuildContext context, dynamic data) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .set(data);
  }

  Future initUserData(BuildContext context) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .get()
        .then((doc) {
      print("fetching user data");
      initUserName = doc['username'];
      initUserEmail = doc['useremail'];
      initUserImage = doc['userimage'];
      userAddress = doc['address'];
      setUserVerified(doc['isverified']);
      userbio = doc['userbio'];
      usercontactnumber = doc['usercontactnumber'];
      usercover = doc['usercover'];
      userdob = doc['userdob'];
      userfacebookurl = doc['userfacebookurl'];
      usergender = doc['usergender'];
      userinstagramurl = doc['userinstagramurl'];
      userrealname = doc['userrealname'];
      usertiktokurl = doc['usertiktokurl'];
      usersearchindex = doc['usersearchindex'];

      log("checking carats");
      if (doc.data()!.containsKey("carats")) {
        log("contains carats");
        context.read<CaratProvider>().setCarats(doc['carats']);
        log("carats now == ${context.read<CaratProvider>().getCarats}");
      }

      print("is verified == ${doc['isverified']}");

      print(Provider.of<Authentication>(context, listen: false).getUserId);

      // fcmToken = doc['token'];

      print("token is ${doc['token']}");

      setFcmToken(doc['token']);

      // print(fcmToken);
      // print(initUserName);
      notifyListeners();
    });
  }

  Future initChatData(BuildContext context) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("chats")
        .get()
        .then((chats) async {
      chats.docs.forEach((chat) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(Provider.of<Authentication>(context, listen: false).getUserId)
            .collection("chats")
            .doc(chat.id)
            .collection("messages")
            .where("msgSeen", isEqualTo: false)
            .get()
            .then((messages) async {
          print("${messages.docs.length} here");
          unReadMsgs = messages.docs.length;
          notifyListeners();
        });
      });
    });
  }

  Future uploadPostData(String postId, dynamic data) async {
    return FirebaseFirestore.instance.collection("posts").doc(postId).set(data);
  }

  Future deleteUserData(String userUid) async {
    return FirebaseFirestore.instance.collection('users').doc(userUid).delete();
  }

  Future deletePostData(
      {required String postId, required String userUid}) async {
    return await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .delete()
        .whenComplete(() async {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(userUid)
          .collection("posts")
          .doc(postId)
          .delete()
          .whenComplete(() async {
        return await FirebaseFirestore.instance
            .collection("banners")
            .get()
            .then((bannerCollection) {
          bannerCollection.docs.forEach((element) async {
            if (element['postid'] == postId) {
              await FirebaseFirestore.instance
                  .collection("banners")
                  .doc(element.id)
                  .delete();
            }
          });
        });
      });
    });
  }

  Future deleteUserComment(
      {required String postId, required String commentId}) async {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .collection("comments")
        .doc(commentId)
        .delete();
  }

  Future updateDescription(
      {required String postId,
      required AsyncSnapshot<DocumentSnapshot> postDoc,
      String? description,
      required BuildContext context}) async {
    String name = "${postDoc.data!['caption']} ${description}";

    List<String> splitList = name.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int j = 0; j < splitList[i].length; j++) {
        indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
      }
    }
    return await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({
      'description': description,
      'searchindex': indexList,
    }).whenComplete(() async {
      return await FirebaseFirestore.instance
          .collection("users")
          .doc(Provider.of<Authentication>(context, listen: false).getUserId)
          .collection("posts")
          .doc(postId)
          .update({
        'description': description,
        'searchindex': indexList,
      });
    });
  }

  Future followUser({
    required String followingUid,
    required String followingDocId,
    required dynamic followingData,
    required String followerUid,
    required String followerDocId,
    required dynamic followerData,
    required String otherUserToken,
    required String followingUserName,
  }) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(followingUid)
        .collection("followers")
        .doc(followingDocId)
        .set(followingData)
        .whenComplete(() async {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(followerUid)
          .collection("following")
          .doc(followerDocId)
          .set(followerData);
    }).whenComplete(() async {
      await _fcmNotificationService.sendNotificationToUser(
          to: otherUserToken, //To change once set up
          title: "$followingUserName follows you",
          body: "");
    });
  }

  Future unfollowUser({
    required String followingUid,
    required String followingDocId,
    required String followerUid,
    required String followerDocId,
  }) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(followingUid)
        .collection("followers")
        .doc(followingDocId)
        .delete()
        .whenComplete(() async {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(followerUid)
          .collection("following")
          .doc(followerDocId)
          .delete();
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(followingUid)
          .get()
          .then((postUser) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(followerUid)
            .get()
            .then((followingUser) async {
          await _fcmNotificationService.sendNotificationToUser(
              to: postUser['fcmToken']!, //To change once set up
              title: "${followingUser['username']} unfollowed you",
              body: "");
        });
      });
    });
  }

  Future submitChatroomData({
    required String chatroomName,
    required dynamic chatroomData,
  }) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomName)
        .set(chatroomData);
  }

  Future messageUser({
    required String messagingUid,
    required String messagingDocId,
    required dynamic messagingData,
    required String messengerUid,
    required String messengerDocId,
    required dynamic messengerData,
  }) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(messagingUid)
        .collection("chats")
        .doc(messagingDocId)
        .set(messagingData)
        .whenComplete(() async {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(messengerUid)
          .collection("chats")
          .doc(messengerDocId)
          .set(messengerData);
    });
  }

  Future deleteMessage(
      {required String chatroomId, required String messageId}) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  // check if user exists based on field userrealname
  Future<bool> checkUserExists({required String useruid}) async {
    log("anket here");
    return FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .get()
        .then((value) {
      if (value.exists == true) {
        log("anket here -- true");
        return true;
      } else {
        log("anket here -- false");
        return false;
      }
    });
  }

  // Update users bio
  Future updateBio(
      {required String uid,
      required String bio,
      required BuildContext context}) async {
    userbio = bio;
    notifyListeners();
    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      'userbio': bio,
    }).whenComplete(() => initUserData(context));
  }

  // Update users data
  Future updateUserData({
    required String uid,
    required String username,
    required String userrealname,
    required String userContactNumber,
    required String userAddress,
    String? userGender,
    required Timestamp userDob,
    String? tiktokUrl,
    String? facebookUrl,
    String? instagramUrl,
    String? countryCode,
    String? userbio,
  }) {
    final String name = "${username}";

    List<String> splitList = name.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int j = 0; j < splitList[i].length; j++) {
        indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
      }
    }

    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      'username': username,
      'userrealname': userrealname,
      'usercontactnumber': userContactNumber,
      'address': userAddress,
      'usergender': userGender,
      'userdob': userDob,
      'usercountrycode': countryCode ?? "",
      "usertiktokurl": tiktokUrl ?? "",
      "userinstagramurl": instagramUrl ?? "",
      "userfacebookurl": facebookUrl ?? "",
      "userbio": userbio ?? "",
      'usersearchindex': indexList,
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("followers")
          .get()
          .then((followers) async {
        followers.docs.forEach((followerDoc) async {
          bool exists = await checkUserExists(useruid: followerDoc.id);
          if (exists == true) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(followerDoc.id)
                .collection("following")
                .doc(uid)
                .update({
              'username': username,
            });
          }
        });
      });
    });
    ;
  }

  Future deleteVideoPost({required String videoid}) async {
    await FirebaseFirestore.instance.collection("posts").doc(videoid).delete();
  }

  // update users social media links to a collection under the users doc
  Future updateSocialMediaLinks({
    required String uid,
    String? url,
    String? twitterUrl,
    String? youtubeUrl,
    String? instagramUrl,
  }) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("socialMedia")
        .doc("links")
        .update({
      "url": url ?? "",
      "youtubeurl": youtubeUrl ?? "",
      "instagramurl": instagramUrl ?? "",
      "twitterurl": twitterUrl ?? "",
    });
  }

  // Init users social media links
  Future initSocialMediaLinks({
    required String uid,
    required BuildContext context,
  }) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("socialMedia")
        .doc("links")
        .get()
        .then((value) {
      if (value.exists) {
        final socialProvider =
            Provider.of<SocialMediaLinksProvider>(context, listen: false);
        // ignore: cascade_invocations
        socialProvider.setSocialMediaLinks(
            url: value['url'] ?? "",
            youtubeUrl: value['youtubeurl'] ?? "",
            instagramUrl: value['instagramurl'] ?? "",
            twitterUrl: value['twitterurl'] ?? "");
      } else {
        FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("socialMedia")
            .doc("links")
            .set({
          "url": "",
          "youtubeurl": "",
          "instagramurl": "",
          "twitterurl": "",
        });
      }
    });
  }

  // Update users image
  Future updateUserImage({
    required String uid,
    required String imageUrl,
  }) {
    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      'userimage': imageUrl,
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("followers")
          .get()
          .then((followers) async {
        followers.docs.forEach((followerDoc) async {
          bool exists = await checkUserExists(useruid: followerDoc.id);
          if (exists == true) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(followerDoc.id)
                .collection("following")
                .doc(uid)
                .update({
              'userimage': imageUrl,
            });
          }
        });
      });
    });
  }

  Future updateUserCover({
    required String uid,
    required String imageUrl,
  }) {
    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      'usercover': imageUrl,
    });
  }

  Future<File> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight:
          300, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    File file = File(fileName!);
    return file;
  }

  Future updatePost({
    required String caption,
    required String video_title,
    required String videoId,
    required bool isFree,
    required bool isPaid,
    required double price,
    required double discountAmount,
    required Timestamp startDiscountDate,
    required Timestamp endDiscountDate,
    required List<String?> genre,
    required String contentAvailability,
  }) async {
    String name = "${caption} ${video_title}";

    List<String> splitList = name.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int j = 0; j < splitList[i].length; j++) {
        indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
      }
    }

    await FirebaseFirestore.instance.collection("posts").doc(videoId).update({
      "videotitle": video_title,
      "caption": caption,
      "username": initUserName,
      "userimage": initUserImage,
      "isfree": isFree,
      "ispaid": isPaid,
      "price": price,
      "discountamount": discountAmount,
      "startdiscountdate": startDiscountDate,
      "enddiscountdate": endDiscountDate,
      "contentavailability": contentAvailability,
      "searchindexList": indexList,
      "genre": genre,
      'verifiedUser': isverified,
    });
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
          "ownerName": initUserName,
        }).then((value) {
          arIdsVal.add(idVal);
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
            "ownerName": initUserName,
            "hideItem": false,
          });

          log("id for effect == $idVal");
          arIdsVal.add(idVal);
          notifyListeners();
        } else {
          arIdsVal.add(arVal.arId!);
          notifyListeners();
        }

        print(
            "added arId: ${arVal.arIndex} to list arIdsVal |  ${arIdsVal.length}");
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
        "username": initUserName,
        "userimage": initUserImage,
        "thumbnailurl": coverThumbnailUrl,
        "isfree": isFree,
        "ispaid": isPaid,
        "issubscription": isSubscription,
        "price": price,
        "discountamount": discountAmount,
        "startdiscountdate": startDiscountDate,
        "enddiscountdate": endDiscountDate,
        "contentavailability": contentAvailability,
        'ownerFcmToken': fcmToken,
        "searchindexList": indexList,
        "genre": genre,
        'boughtBy': [],
        'totalBilled': 0,
        'verifiedUser': isverified,
        "videoType": "video",
      }).then((value) {
        arIdsVal.forEach((arUidVal) async {
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
                  await notifyUserOfUsage(userid: userUid, type: "AR");
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "alpha": arSnapshot.data()!['alpha'],
                    "audioFile": arSnapshot.data()!['audioFile'],
                    "hideItem": arSnapshot.data()!['hideItem'],
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
                  await notifyUserOfUsage(userid: userUid, type: "Effect");
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "gif": arSnapshot.data()!['gif'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "hideItem": arSnapshot.data()!['hideItem'],
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
                  await notifyUserOfUsage(userid: userUid, type: "Background");
                  await FirebaseFirestore.instance
                      .collection("posts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "hideItem": arSnapshot.data()!['hideItem'],
                    "gif": arSnapshot.data()!['gif'],
                    "main": arSnapshot.data()!['main'],
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
        arIdsVal = [];
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

  Future<bool> uploadDraftVideo({
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

      log("adding to drafts");

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
          "ownerName": initUserName,
        }).then((value) {
          arIdsVal.add(idVal);
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
            "ownerName": initUserName,
            "hideItem": false,
          });

          log("id for effect == $idVal");
          arIdsVal.add(idVal);
          notifyListeners();
        } else {
          arIdsVal.add(arVal.arId!);
          notifyListeners();
        }

        print(
            "added arId: ${arVal.arIndex} to list arIdsVal |  ${arIdsVal.length}");
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

      await FirebaseFirestore.instance.collection("drafts").doc(id).set({
        "id": id,
        "useruid": userUid,
        "videourl": videoUrl,
        "videotitle": video_title,
        "caption": caption,
        "timestamp": Timestamp.now(),
        "username": initUserName,
        "userimage": initUserImage,
        "thumbnailurl": coverThumbnailUrl,
        "isfree": isFree,
        "ispaid": isPaid,
        "issubscription": isSubscription,
        "price": price,
        "discountamount": discountAmount,
        "startdiscountdate": startDiscountDate,
        "enddiscountdate": endDiscountDate,
        "contentavailability": contentAvailability,
        'ownerFcmToken': fcmToken,
        "searchindexList": indexList,
        "genre": genre,
        'boughtBy': [],
        'totalBilled': 0,
        'verifiedUser': isverified,
        "videoType": "video",
      }).then((value) {
        arIdsVal.forEach((arUidVal) async {
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
                      .collection("drafts")
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
                  // await notifyUserOfUsage(userid: userUid, type: "AR");
                  await FirebaseFirestore.instance
                      .collection("drafts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "alpha": arSnapshot.data()!['alpha'],
                    "audioFile": arSnapshot.data()!['audioFile'],
                    "hideItem": arSnapshot.data()!['hideItem'],
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
                      .collection("drafts")
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
                  // await notifyUserOfUsage(userid: userUid, type: "Effect");
                  await FirebaseFirestore.instance
                      .collection("drafts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "gif": arSnapshot.data()!['gif'],
                    "layerType": arSnapshot.data()!['layerType'],
                    "hideItem": arSnapshot.data()!['hideItem'],
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
                      .collection("drafts")
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
                  // await notifyUserOfUsage(userid: userUid, type: "Background");
                  await FirebaseFirestore.instance
                      .collection("drafts")
                      .doc(id)
                      .collection("materials")
                      .doc("${arUidVal}${id}")
                      .set({
                    "id": "${arSnapshot.data()!['id']}${id}",
                    "hideItem": arSnapshot.data()!['hideItem'],
                    "gif": arSnapshot.data()!['gif'],
                    "main": arSnapshot.data()!['main'],
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
        arIdsVal = [];
        notifyListeners();
      });

      // await notifyAllFromNotifierList(
      //   accountOwnerId: userUid,
      // );

      log("notified");

      return true;
    } catch (e) {
      return false;
      print("ANKET ERROR ${e.toString()}");
    }
  }

  Future notifyUserOfUsage(
      {required String userid, required String type}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .get()
        .then((value) async {
      UserModel userModel = UserModel.fromMap(value.data()!);

      await _fcmNotificationService
          .sendNotificationToUser(
              to: userModel.token,
              title: "Your created ${type} is used in a video!",
              body: "")
          .whenComplete(() {
        log("notification sent");
      });
    });
  }

  Future<void> addArToPostMaterials({
    required String videoId,
    required String useruid,
    required String ownerName,
    required String idVal,
    required String alphaUrl,
    required String mainUrl,
    required String gifUrl,
    required String audioUrl,
    required List<String> imgSeqList,
    required int audioFlag,
    required String usage,
    bool asMaterialAlso = false,
  }) async {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(videoId)
        .collection("materials")
        .doc(asMaterialAlso == false
            ? "${idVal}${videoId}"
            : "${idVal}${videoId}asMaterialAlso")
        .set({
      "videoId": videoId,
      "alpha": alphaUrl,
      "main": mainUrl,
      "audioFile": audioUrl,
      "gif": gifUrl,
      "layerType": "AR",
      "valueType": "myItems",
      "timestamp": Timestamp.now(),
      "id": idVal,
      "imgSeq": imgSeqList,
      "audioFlag": audioFlag == 1 ? true : false,
      "ownerId": useruid,
      "ownerName": ownerName,
      "usage": usage,
      "hideItem": false,
    });
  }

  Future uploadArVideoViewOnly({
    required String userUid,
    required String video_title,
    required String caption,
    required String contentAvailability,
    required bool isFree,
    bool isMaterialAlso = false,
    required bool isPaid,
    required bool isSubscription,
    double? price,
    double? discountAmount,
    Timestamp? startDiscountDate,
    Timestamp? endDiscountDate,
    required List<String?> genre,
    required String videoUrl,
    required BuildContext ctx,
    required String gifUrl,
    required String ownerName,
    required int audioFlag,
    required String alphaUrl,
    required String audioUrl,
    required List<String> imgSeqList,
    required String arIdVal,
    required String inputUrl,
  }) async {
    try {
      CoolAlert.show(
        barrierDismissible: false,
        context: ctx,
        type: CoolAlertType.loading,
        text: "Posting GD AR as Ar View Only",
      );
      final File videoThumbnail =
          await Provider.of<FFmpegProvider>(ctx, listen: false)
              .thumbnailCreator(vidFilePath: videoUrl);

      final String? packageThumbnailUrl = await AwsAnketS3.uploadFile(
          accessKey: "AKIATF76MVYR34JAVB7H",
          secretKey: "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",
          bucket: "anketvideobucket",
          file: videoThumbnail,
          filename: "${Timestamp.now().millisecondsSinceEpoch}.gif",
          region: "us-east-1",
          destDir: "${Timestamp.now().millisecondsSinceEpoch}");

      log("package URl = $packageThumbnailUrl");

      final String id = nanoid();

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
        "username": initUserName,
        "userimage": initUserImage,
        "thumbnailurl": packageThumbnailUrl,
        "isfree": isFree,
        "ispaid": isPaid,
        "issubscription": isSubscription,
        "price": price,
        "discountamount": discountAmount,
        "startdiscountdate": startDiscountDate,
        "enddiscountdate": endDiscountDate,
        "contentavailability": contentAvailability,
        'ownerFcmToken': fcmToken,
        "searchindexList": indexList,
        "genre": genre,
        'boughtBy': [],
        'totalBilled': 0,
        'verifiedUser': isverified,
        'videoType': 'arView',
      }).then((value) async {
        await addArToCollection(
          ownerName: initUserName,
          audioFlag: audioFlag,
          alphaUrl: alphaUrl,
          audioUrl: audioUrl,
          imgSeqList: imgSeqList,
          gifUrl: gifUrl,
          idVal: arIdVal,
          mainUrl: inputUrl,
          useruid: userUid,
          usage: "Ar View Only",
        );

        await addArToPostMaterials(
          videoId: id,
          ownerName: initUserName,
          audioFlag: audioFlag,
          alphaUrl: alphaUrl,
          audioUrl: audioUrl,
          imgSeqList: imgSeqList,
          gifUrl: gifUrl,
          idVal: arIdVal,
          mainUrl: inputUrl,
          useruid: userUid,
          usage: "Ar View Only",
        );

        if (isMaterialAlso) {
          log("is material also");
          await addArToCollection(
            ownerName: initUserName,
            audioFlag: audioFlag,
            alphaUrl: alphaUrl,
            audioUrl: audioUrl,
            imgSeqList: imgSeqList,
            gifUrl: gifUrl,
            idVal: arIdVal,
            mainUrl: inputUrl,
            useruid: userUid,
            asMaterialAlso: true,
            usage: "Material",
          );

          await addArToPostMaterials(
            videoId: id,
            ownerName: initUserName,
            audioFlag: audioFlag,
            alphaUrl: alphaUrl,
            audioUrl: audioUrl,
            imgSeqList: imgSeqList,
            gifUrl: gifUrl,
            idVal: arIdVal,
            mainUrl: inputUrl,
            useruid: userUid,
            asMaterialAlso: true,
            usage: "Material",
          );
        }

        Get.snackbar(
          'GD AR posted as View Only',
          "The use of this GD AR is in view only!",
          overlayColor: constantColors.navButton,
          colorText: constantColors.whiteColor,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.elasticInOut,
          reverseAnimationCurve: Curves.easeOut,
        );

        Navigator.pop(ctx);
      }).then((value) {
        Navigator.pop(ctx);
        log("Done posting");
        arIdsVal = [];
        notifyListeners();
      });
    } catch (e) {
      print("ANKET ERROR ${e.toString()}");
    }
  }

  // Like users post
  Future likePost({
    required String postUid,
    required String userUid,
    required BuildContext context,
    required String sendToUserToken,
    required String likerUsername,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(postUid)
        .collection("likes")
        .doc(userUid)
        .set({
      'likes': FieldValue.increment(1),
      'username': initUserName,
      'useruid': userUid,
      'userimage': initUserImage,
      'useremail': initUserEmail,
      'time': Timestamp.now(),
    }).then((value) async {
      await _fcmNotificationService.sendNotificationToUser(
          to: sendToUserToken, //To change once set up
          title: "$initUserName liked your post",
          body: "");
    });
  }

  // delete like post
  Future deleteLikePost({
    required String postUid,
    required String userUid,
    required BuildContext context,
  }) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(postUid)
        .collection("likes")
        .doc(userUid)
        .delete();
  }

  Future addComment({
    required String userUid,
    required String postId,
    required String comment,
    required BuildContext context,
    required String ownerFcmToken,
  }) async {
    final String commentId = nanoid().toString();
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
      'commentid': commentId,
      'comment': comment,
      'username': initUserName,
      'useruid': Provider.of<Authentication>(context, listen: false).getUserId,
      'userimage': initUserImage,
      'useremail': initUserEmail,
      'time': Timestamp.now(),
    }).then((value) async {
      await _fcmNotificationService.sendNotificationToUser(
        to: ownerFcmToken,
        title: "$initUserName commented",
        body: comment,
      );
    });
  }

  // Delete comment
  Future deleteComment({
    required String postId,
    required String commentId,
    required BuildContext context,
  }) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // Like user comment
  Future likeComment({
    required String postId,
    required String commentId,
    required String userUid,
    required BuildContext context,
  }) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .doc(userUid)
        .set({
      'likes': FieldValue.increment(1),
      'username': initUserName,
      'useruid': userUid,
      'userimage': initUserImage,
      'useremail': initUserEmail,
      'time': Timestamp.now(),
    });
  }

  // Delete like comment
  Future unLikeComment({
    required String postId,
    required String commentId,
    required String userUid,
    required BuildContext context,
  }) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .doc(userUid)
        .delete();
  }

  // Go to user profile
  Future goToUserProfile({
    required String userUid,
    required BuildContext context,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .get()
        .then((value) {
      if (value.exists) {
        try {
          UserModel user = UserModel.fromMap(value.data()!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserProfile(
                userModel: user,
              ),
            ),
          );
        } catch (e) {
          print(e.toString());
        }
      }
    });
  }

  // Add Post to Favorites list
  Future addToFavs({required Video video, required BuildContext context}) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("favorites")
        .doc(video.id)
        .set({
      "videoid": video.id,
      "videourl": video.videourl,
      "videotitle": video.videotitle,
      "caption": video.caption,
      "timestamp": Timestamp.now(),
      "username": video.username,
      "userimage": video.userimage,
      "thumbnailurl": video.thumbnailurl,
      "isfree": video.isFree,
    });
  }

  // remove video from favorites
  Future removeFromFavs({required Video video, required BuildContext context}) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("favorites")
        .doc(video.id)
        .delete();
  }

  // Add like to notification collection inside user document
  Future addLikeNotification({
    required String postId,
    required String userUid,
    required BuildContext context,
    required String videoOwnerUid,
  }) {
    final String id = nanoid().toString();
    return FirebaseFirestore.instance
        .collection("users")
        .doc(videoOwnerUid)
        .collection("notifications")
        .doc(id)
        .set({
      "id": id,
      "postid": postId,
      "seen": false,
      "type": "like",
      "timestamp": Timestamp.now(),
      "username": initUserName,
      "useruid": userUid,
      "userimage": initUserImage,
      "useremail": initUserEmail,
    });
  }

  // Add comment to notification collection inside user document
  Future addCommentNotification({
    required String postId,
    required String userUid,
    required BuildContext context,
    required String videoOwnerUid,
  }) {
    final String id = nanoid().toString();
    return FirebaseFirestore.instance
        .collection("users")
        .doc(videoOwnerUid)
        .collection("notifications")
        .doc(id)
        .set({
      "id": id,
      "postid": postId,
      "seen": false,
      "type": "comment",
      "timestamp": Timestamp.now(),
      "username": initUserName,
      "useruid": userUid,
      "userimage": initUserImage,
      "useremail": initUserEmail,
    });
  }

  // Add follow to notification collection inside user document
  Future addFollowNotification({
    required String userUid,
    required String otherUserId,
    required BuildContext context,
  }) {
    final String id = nanoid().toString();
    return FirebaseFirestore.instance
        .collection("users")
        .doc(otherUserId)
        .collection("notifications")
        .doc(id)
        .set({
      "id": id,
      "useruid": userUid,
      "seen": false,
      "type": "follow",
      "timestamp": Timestamp.now(),
      "username": initUserName,
      "userimage": initUserImage,
      "useremail": initUserEmail,
    });
  }

  // make notification seen to true
  Future makeNotificationSeen({
    required String userUid,
    required String notificationId,
  }) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .collection("notifications")
        .doc(notificationId)
        .update({
      "seen": true,
    });
  }

  // Upload gif layers (effects) to AWS then store the links in Firebase (MyCollection)
  Future<String> uploadEffects({
    required File gifFile,
    required String userUid,
  }) async {
    final String? effectUrl = await AwsAnketS3.uploadFile(
        accessKey: "AKIATF76MVYR34JAVB7H",
        secretKey: "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",
        bucket: "anketvideobucket",
        file: gifFile,
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
      "owner": initUserName,
    });

    return idVal;
  }

  Future<void> addToGraph({
    required String videoOwnerId,
    required int month,
    required double amount,
    // required BuildContext ctx,
  }) async {
    final String id = nanoid();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(videoOwnerId)
        .collection("graphData")
        .doc(id)
        .set({
      'id': id,
      'month': month,
      'amount': amount,
    });
  }

  Future addToCart({
    required String videoId,
    required BuildContext ctx,
    required Video videoItem,
    required String useruid,
    required bool isFree,
    bool canPop = true,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("cart")
        .doc(videoId)
        .set(videoItem.toJson());

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(videoId)
        .collection("materials")
        .get()
        .then((value) {
      value.docs.forEach((arSnapshot) async {
        switch (arSnapshot.data()['layerType']) {
          case "AR":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(useruid)
                  .collection("cart")
                  .doc(videoId)
                  .collection("materials")
                  .doc(arSnapshot.id)
                  .set({
                "alpha": arSnapshot.data()['alpha'],
                "audioFile": arSnapshot.data()['audioFile'],
                "audioFlag": arSnapshot.data()['audioFlag'],
                "gif": arSnapshot.data()['gif'],
                "id": "${arSnapshot.data()['id']}",
                "imgSeq": arSnapshot.data()['imgSeq'],
                "layerType": arSnapshot.data()['layerType'],
                "main": arSnapshot.data()['main'],
                "timestamp": arSnapshot.data()['timestamp'],
                "valueType": arSnapshot.data()['valueType'],
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
                "usage": arSnapshot.data()['usage'],
              });
              log("AR ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
          case "Effect":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(useruid)
                  .collection("cart")
                  .doc(videoId)
                  .collection("materials")
                  .doc(arSnapshot.id)
                  .set({
                "gif": arSnapshot.data()['gif'],
                "layerType": arSnapshot.data()['layerType'],
                "timestamp": arSnapshot.data()['timestamp'],
                "id": arSnapshot.data()['id'],
                "valueType": isFree ? "free" : "paid",
                "itemType": "material",
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
              });
              log("EFFECT ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
          case "Background":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(useruid)
                  .collection("cart")
                  .doc(videoId)
                  .collection("materials")
                  .doc(arSnapshot.id)
                  .set({
                "main": arSnapshot.data()['main'],
                "gif": arSnapshot.data()['gif'],
                "layerType": arSnapshot.data()['layerType'],
                "timestamp": arSnapshot.data()['timestamp'],
                "id": arSnapshot.data()['id'],
                "valueType": isFree ? "free" : "paid",
                "itemType": "material",
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
              });
              log("BACKGROUND ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
        }
      });

      if (canPop) {
        Navigator.pop(ctx);
        Navigator.pop(ctx);
      }

      showTopSnackBar(
        ctx,
        CustomSnackBar.success(
          message: "Added To Cart!",
        ),
      );
    });
  }

  Future addToMyCollection({
    required String videoId,
    required BuildContext ctx,
    required bool isFree,
    required Video videoItem,
    required String videoOwnerId,
    int amount = 0,
    bool canPop = true,
  }) async {
    await FirebaseFirestore.instance.collection("posts").doc(videoId).update({
      'totalBilled': videoItem.totalBilled! + amount,
      'boughtBy': FieldValue.arrayUnion([
        Provider.of<Authentication>(ctx, listen: false).getUserId,
      ]),
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(videoOwnerId)
        .get()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(value.id)
          .update({
        "totalmade": value.data()!['totalmade'] + amount,
      }).then((_) async {
        if (isFree == false) {
          await addToGraph(
            videoOwnerId: videoOwnerId,
            month: DateTime.now().month,
            amount: (value.data()!['totalmade'] + amount) *
                value.data()!['percentage'] /
                100,
            // ctx: ctx,
          );
        }
      });
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(ctx, listen: false).getUserId)
        .collection("MyCollection")
        .doc(videoId)
        .set(videoItem.toJson());

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(videoId)
        .collection("materials")
        .get()
        .then((value) {
      value.docs.forEach((arSnapshot) async {
        switch (arSnapshot.data()['layerType']) {
          case "AR":
            if (arSnapshot.data().containsKey("hideItem")) {
              if (arSnapshot.data()['hideItem'] == false) {
                if (arSnapshot.data()['videoId'] == videoId) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(Provider.of<Authentication>(ctx, listen: false)
                          .getUserId)
                      .collection("MyCollection")
                      .doc(arSnapshot.id)
                      .set({
                    "alpha": arSnapshot.data()['alpha'],
                    "audioFile": arSnapshot.data()['audioFile'],
                    "audioFlag": arSnapshot.data()['audioFlag'],
                    "gif": arSnapshot.data()['gif'],
                    "id": "${arSnapshot.data()['id']}",
                    "imgSeq": arSnapshot.data()['imgSeq'],
                    "layerType": arSnapshot.data()['layerType'],
                    "main": arSnapshot.data()['main'],
                    "timestamp": arSnapshot.data()['timestamp'],
                    "valueType": arSnapshot.data()['valueType'],
                    "ownerId": arSnapshot.data()['ownerId'],
                    "ownerName": arSnapshot.data()['ownerName'],
                    "videoId": arSnapshot.data()['videoId'],
                    "usage": arSnapshot.data()['usage'],
                  });
                  log("AR ADDED | ${arSnapshot.data()['videoId']}");
                }
              } else {
                log("AR hidden by user");
              }
            } else {
              if (arSnapshot.data()['videoId'] == videoId) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(Provider.of<Authentication>(ctx, listen: false)
                        .getUserId)
                    .collection("MyCollection")
                    .doc(arSnapshot.id)
                    .set({
                  "alpha": arSnapshot.data()['alpha'],
                  "audioFile": arSnapshot.data()['audioFile'],
                  "audioFlag": arSnapshot.data()['audioFlag'],
                  "gif": arSnapshot.data()['gif'],
                  "id": "${arSnapshot.data()['id']}",
                  "imgSeq": arSnapshot.data()['imgSeq'],
                  "layerType": arSnapshot.data()['layerType'],
                  "main": arSnapshot.data()['main'],
                  "timestamp": arSnapshot.data()['timestamp'],
                  "valueType": arSnapshot.data()['valueType'],
                  "ownerId": arSnapshot.data()['ownerId'],
                  "ownerName": arSnapshot.data()['ownerName'],
                  "videoId": arSnapshot.data()['videoId'],
                  "usage": arSnapshot.data()['usage'],
                });
                log("AR ADDED | ${arSnapshot.data()['videoId']}");
              }
            }

            break;
          case "Effect":
            // effect
            if (arSnapshot.data().containsKey("hideItem")) {
              if (arSnapshot.data()['hideItem'] == false) {
                if (arSnapshot.data()['videoId'] == videoId) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(Provider.of<Authentication>(ctx, listen: false)
                          .getUserId)
                      .collection("MyCollection")
                      .doc(arSnapshot.id)
                      .set({
                    "gif": arSnapshot.data()['gif'],
                    "layerType": arSnapshot.data()['layerType'],
                    "timestamp": arSnapshot.data()['timestamp'],
                    "id": arSnapshot.data()['id'],
                    "valueType": isFree ? "free" : "paid",
                    "itemType": "material",
                    "ownerId": arSnapshot.data()['ownerId'],
                    "ownerName": arSnapshot.data()['ownerName'],
                    "videoId": arSnapshot.data()['videoId'],
                  });
                  log("EFFECT ADDED | ${arSnapshot.data()['videoId']}");
                }
              } else {
                log("Effect hidden by user");
              }
            } else {
              if (arSnapshot.data()['videoId'] == videoId) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(Provider.of<Authentication>(ctx, listen: false)
                        .getUserId)
                    .collection("MyCollection")
                    .doc(arSnapshot.id)
                    .set({
                  "gif": arSnapshot.data()['gif'],
                  "layerType": arSnapshot.data()['layerType'],
                  "timestamp": arSnapshot.data()['timestamp'],
                  "id": arSnapshot.data()['id'],
                  "valueType": isFree ? "free" : "paid",
                  "itemType": "material",
                  "ownerId": arSnapshot.data()['ownerId'],
                  "ownerName": arSnapshot.data()['ownerName'],
                  "videoId": arSnapshot.data()['videoId'],
                });
                log("EFFECT ADDED | ${arSnapshot.data()['videoId']}");
              }
            }

            break;
          case "Background":
            // BG
            if (arSnapshot.data().containsKey("hideItem")) {
              if (arSnapshot.data()['hideItem'] == false) {
                if (arSnapshot.data()['videoId'] == videoId) {
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(Provider.of<Authentication>(ctx, listen: false)
                          .getUserId)
                      .collection("MyCollection")
                      .doc(arSnapshot.id)
                      .set({
                    "main": arSnapshot.data()['main'],
                    "gif": arSnapshot.data()['gif'],
                    "layerType": arSnapshot.data()['layerType'],
                    "timestamp": arSnapshot.data()['timestamp'],
                    "id": arSnapshot.data()['id'],
                    "valueType": isFree ? "free" : "paid",
                    "itemType": "material",
                    "ownerId": arSnapshot.data()['ownerId'],
                    "ownerName": arSnapshot.data()['ownerName'],
                    "videoId": arSnapshot.data()['videoId'],
                  });
                  log("BACKGROUND ADDED | ${arSnapshot.data()['videoId']}");
                }
              } else {
                log("BG hidden by user");
              }
            } else {
              if (arSnapshot.data()['videoId'] == videoId) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(Provider.of<Authentication>(ctx, listen: false)
                        .getUserId)
                    .collection("MyCollection")
                    .doc(arSnapshot.id)
                    .set({
                  "main": arSnapshot.data()['main'],
                  "gif": arSnapshot.data()['gif'],
                  "layerType": arSnapshot.data()['layerType'],
                  "timestamp": arSnapshot.data()['timestamp'],
                  "id": arSnapshot.data()['id'],
                  "valueType": isFree ? "free" : "paid",
                  "itemType": "material",
                  "ownerId": arSnapshot.data()['ownerId'],
                  "ownerName": arSnapshot.data()['ownerName'],
                  "videoId": arSnapshot.data()['videoId'],
                });
                log("BACKGROUND ADDED | ${arSnapshot.data()['videoId']}");
              }
            }
            break;
        }
      });

      log("now delete");

      if (canPop == true) {
        Navigator.pop(ctx);

        showTopSnackBar(
          ctx,
          CustomSnackBar.success(
            message: "Added To Your Collection!",
          ),
        );
      }
    });
  }

  Future addToMyCollectionFromCart({
    required String videoId,
    // required BuildContext ctx,
    required Authentication auth,
    required bool isFree,
    required Video videoItem,
    required String videoOwnerId,
    int amount = 0,
  }) async {
    await FirebaseFirestore.instance.collection("posts").doc(videoId).update({
      'totalBilled': videoItem.totalBilled! + amount,
      'boughtBy': FieldValue.arrayUnion([
        auth.getUserId,
      ]),
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(videoOwnerId)
        .get()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(value.id)
          .update({
        "totalmade": value.data()!['totalmade'] + amount,
      }).then((_) async {
        if (isFree == false) {
          await addToGraph(
            videoOwnerId: videoOwnerId,
            month: DateTime.now().month,
            amount: (value.data()!['totalmade'] + amount) *
                value.data()!['percentage'] /
                100,
            // ctx: ctx,
          );
        }
      });
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(auth.getUserId)
        .collection("MyCollection")
        .doc(videoId)
        .set(videoItem.toJson());

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(videoId)
        .collection("materials")
        .get()
        .then((value) {
      value.docs.forEach((arSnapshot) async {
        switch (arSnapshot.data()['layerType']) {
          case "AR":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(auth.getUserId)
                  .collection("MyCollection")
                  .doc(arSnapshot.id)
                  .set({
                "alpha": arSnapshot.data()['alpha'],
                "audioFile": arSnapshot.data()['audioFile'],
                "audioFlag": arSnapshot.data()['audioFlag'],
                "gif": arSnapshot.data()['gif'],
                "id": "${arSnapshot.data()['id']}",
                "imgSeq": arSnapshot.data()['imgSeq'],
                "layerType": arSnapshot.data()['layerType'],
                "main": arSnapshot.data()['main'],
                "timestamp": arSnapshot.data()['timestamp'],
                "valueType": arSnapshot.data()['valueType'],
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
                "usage": arSnapshot.data()['usage'],
              });
              log("AR ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
          case "Effect":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(auth.getUserId)
                  .collection("MyCollection")
                  .doc(arSnapshot.id)
                  .set({
                "gif": arSnapshot.data()['gif'],
                "layerType": arSnapshot.data()['layerType'],
                "timestamp": arSnapshot.data()['timestamp'],
                "id": arSnapshot.data()['id'],
                "valueType": isFree ? "free" : "paid",
                "itemType": "material",
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
              });
              log("EFFECT ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
          case "Background":
            if (arSnapshot.data()['videoId'] == videoId) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(auth.getUserId)
                  .collection("MyCollection")
                  .doc(arSnapshot.id)
                  .set({
                "main": arSnapshot.data()['main'],
                "gif": arSnapshot.data()['gif'],
                "layerType": arSnapshot.data()['layerType'],
                "timestamp": arSnapshot.data()['timestamp'],
                "id": arSnapshot.data()['id'],
                "valueType": isFree ? "free" : "paid",
                "itemType": "material",
                "ownerId": arSnapshot.data()['ownerId'],
                "ownerName": arSnapshot.data()['ownerName'],
                "videoId": arSnapshot.data()['videoId'],
              });
              log("BACKGROUND ADDED | ${arSnapshot.data()['videoId']}");
            }
            break;
        }
      });

      log("now delete");
    });
  }

  Future<String?> uploadToAWS({
    required File file,
    required String startingFileName,
    required String endingFileName,
    required BuildContext ctx,
    required bool pop,
  }) async {
    // ignore: unawaited_futures

    log("filename == ${startingFileName}");

    final String? url = await AwsAnketS3.uploadFile(
        accessKey: "AKIATF76MVYR34JAVB7H",
        secretKey: "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",
        bucket: "anketvideobucket",
        file: file,
        filename: "${startingFileName}${endingFileName}",
        region: "us-east-1",
        destDir: startingFileName);

    log("url; == $url");

    if (pop) {
      Navigator.pop(ctx);
    }

    return url;
  }

  Future<RvmResponse?> postDataOld(
      {required String fileStarting, required int audioFlag}) async {
    // ignore: unawaited_futures

    var response = await http.post(
      Uri.parse(
          "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api/background_separation/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "file_title": fileStarting,
          "audio_flag": audioFlag,
          "useruid": "",
          "idVal": "",
          "registrationId": "",
          "ownerName": "",
          "endDuration": "hh:mm:ss"
        },
      ),
    );

    // log(response.statusCode)

    if (response.statusCode == 200) {
      log("Anket response OK");

      log("rvm response full = ${response.body}");
      final RvmResponse rvmResponse = RvmResponse.fromJson(response.body);

      return rvmResponse;
    } else {
      // ignore: unawaited_futures
      log("Anket Error RVM ${response.statusCode}");
      return null;
    }
  }

  Future<int> uploadDataForUser({
    required String mainUrl,
    required String alphaUrl,
    required String fileName,
    required String useruid,
    required String title,
    required String caption,
    required List<String?> genre,
    required bool isFree,
    required bool isPaid,
    bool issubscription = false,
    required double price,
    double discountAmount = 0,
    required List<String> searchindexList,
    required String registrationId,
    required String ownerName,
    required String videoId,
    required String userimageUrl,
    String? startDiscountDate,
    String? endDiscountDate,
    String contentAvailability = "All",
    required String fcmToken,
    required bool isVerified,
  }) async {
    // ignore: unawaited_futures

    var response = await http.post(
      Uri.parse(
        "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api_ad1v3/adminpost/",
        // "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api_ad1v2/adminpost/",
        // "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api_ad1/adminpost/",m
      ),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        // {
        //   "mainUrl":
        //       "https://anketvideobucket.s3.amazonaws.com/backend_test/1662007152834videoFile.mp4",
        //   "alphaUrl":
        //       "https://anketvideobucket.s3.amazonaws.com/backend_test/1662007152834_alpha.mp4",
        //   "fileName": "1662007152834",
        //   "Useruid": "8ZCJXYnX3oUZ0LX57L8xFM4qXX62",
        //   "title": "Moc",
        //   "caption": "caption",
        //   "genre": ["Dance", "Music"],
        //   "isFree": false,
        //   "isPaid": true,
        //   "issubscription": false,
        //   "Price": 100,
        //   "discountAmount": 0,
        //   "searchindexList": ["M", "m", "Mo", "mo", "Moc", "moc"],
        //   "registrationId":
        //       "eUWovzfyw0lZm1lo75H-3w:APA91bG364e70Zhc9Y02dQmabmN8wPjn9lDntvjup_vD903KhHILVa2PMgwWSvqO8tCRG17JCSR8_q4NNS8zdib_p_bMn_LOX1s6vgWvI2B-gDcM6ILOXHSbzF3fJeQMKkhF4ZzIIDEH",
        //   "ownerName": "高須京介",
        //   "videoId": "Esi62BCOLHvWe3q2GGuWb",
        //   "userimageUrl":
        //       "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/userProfileAvatar%2Fprivate%2Fvar%2Fmobile%2FContainers%2FData%2FApplication%2F64A10DE0-C02C-4EEE-ACE5-55CB77425695%2Ftmp%2Fimage_picker_64197659-D3FB-47CC-BA47-DF658D1D2F77-25765-000003B073FFDFDF.jpg%2FTimeOfDay(15:05)?alt=media&token=967032ce-b918-46e2-bd6f-6ce3e6c94c71",
        //   "startDiscountDate": "2022-09-21 00:00:00+0900",
        //   "endDiscountDate": "2022-09-23 23:59:59+0900",
        //   "contentAvailability": "All",
        //   "fcmToken":
        //       "eUWovzfyw0lZm1lo75H-3w:APA91bG364e70Zhc9Y02dQmabmN8wPjn9lDntvjup_vD903KhHILVa2PMgwWSvqO8tCRG17JCSR8_q4NNS8zdib_p_bMn_LOX1s6vgWvI2B-gDcM6ILOXHSbzF3fJeQMKkhF4ZzIIDEH",
        //   "isverified": false,
        //   "s3_dir_name": "backend_test/"
        // },
        {
          "mainUrl": mainUrl,
          "alphaUrl": alphaUrl,
          "fileName": fileName,
          "Useruid": useruid,
          "title": title,
          "caption": caption,
          "genre": genre,
          "isFree": isFree,
          "isPaid": isPaid,
          "issubscription": false,
          "Price": price,
          "discountAmount": 0,
          "searchindexList": searchindexList,
          "registrationId": registrationId,
          "ownerName": ownerName,
          "videoId": videoId,
          "userimageUrl": userimageUrl,
          "startDiscountDate": startDiscountDate,
          "endDiscountDate": endDiscountDate,
          "contentAvailability": "All",
          "fcmToken": fcmToken,
          "isverified": isVerified,
          "s3_dir_name": "$fileName/"
        },
      ),
    );

    // log(response.statusCode)

    if (response.statusCode == 200) {
      log("Anket response OK");

      log("response full = ${response.body}");

      return response.statusCode;
    } else {
      // ignore: unawaited_futures
      log("this Error  ${response.statusCode}");
      return response.statusCode;
    }
  }

  Future<void> createPendingArDoc({
    required String endDurationString,
    required String useruid,
    required String ownerName,
    required String idVal,
    required String gifUrl,
  }) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("MyCollection")
        .doc(idVal)
        .set({
      "gif": gifUrl,
      "layerType": "AR",
      "valueType": "myItems-Pending",
      "timestamp": Timestamp.now(),
      "id": idVal,
      "ownerId": useruid,
      "ownerName": ownerName,
      "usage": "Pending",
      "main": null,
      "endDuration": endDurationString,
    });
  }

  Future<RvmResponse?> postData2({
    required String fileStarting,
    required int audioFlag,
    required String useruid,
    required String idVal,
    required String registrationId,
    required String ownerName,
    required String endDuration,
  }) async {
    // ignore: unawaited_futures

    log("sending request");

    var response = await http.post(
      Uri.parse(
        "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api3v3/background_separation2/",
        // "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api3v2/background_separation2/",
        // "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api3/background_separation2/",
      ),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "file_title": fileStarting,
          "audio_flag": audioFlag,
          "useruid": useruid,
          "idVal": idVal,
          "registrationId": registrationId,
          "ownerName": ownerName,
          "endDuration": endDuration,
          "s3_dir_name": "${fileStarting}/"
        },
      ),
    );

    log("sent request");

    // log(response.statusCode)

    if (response.statusCode == 200) {
      log("Anket response OK");

      log("rvm response full = ${response.body}");
      final RvmResponse rvmResponse = RvmResponse.fromJson(response.body);

      return rvmResponse;
    } else {
      // ignore: unawaited_futures
      log("Anket Error RVM ${response.statusCode}");
      return null;
    }
  }

  Future<ArViewOnlyModel?> postArViewOnlyServer(
      {required String fileStarting,
      required int audioFlag,
      required String videoDuration}) async {
    // ignore: unawaited_futures

    var response = await http.post(
      Uri.parse(
        "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api2v2/combine_body_GDback/",
        // "http://ALBforSeparateAPI-1104668696.us-east-1.elb.amazonaws.com/api2/combine_body_GDback/",
      ),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        {
          "file_title": fileStarting,
          "audio_flag": audioFlag,
          "video_duration": videoDuration,
          "s3_dir_name": "${fileStarting}/"
        },
      ),
    );

    // log(response.statusCode)

    if (response.statusCode == 200) {
      log("Anket response OK");

      log("rvm response full = ${response.body}");
      final ArViewOnlyModel arViewOnlyResponse =
          ArViewOnlyModel.fromJson(response.body);

      return arViewOnlyResponse;
    } else {
      // ignore: unawaited_futures
      log("Anket Error arViewOnlyResponse ${response.statusCode}");
      return null;
    }
  }

  Future<void> addArToCollection({
    required String useruid,
    required String ownerName,
    required String idVal,
    required String alphaUrl,
    required String mainUrl,
    required String gifUrl,
    required String audioUrl,
    required List<String> imgSeqList,
    required int audioFlag,
    required String usage,
    bool asMaterialAlso = false,
  }) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("MyCollection")
        .doc(asMaterialAlso == false ? idVal : "${idVal}asMaterialAlso")
        .set({
      "alpha": alphaUrl,
      "main": mainUrl,
      "audioFile": audioUrl,
      "gif": gifUrl,
      "layerType": "AR",
      "hideItem": false,
      "valueType": "myItems",
      "timestamp": Timestamp.now(),
      "id": asMaterialAlso == false ? idVal : "${idVal}asMaterialAlso",
      "imgSeq": imgSeqList,
      "audioFlag": audioFlag == 1 ? true : false,
      "ownerId": useruid,
      "ownerName": ownerName,
      "usage": usage,
    });
  }

  Future<void> updatePaypalLink(
      {required String paypalAccountName, required String useruid}) async {
    await FirebaseFirestore.instance.collection("users").doc(useruid).update({
      'paypal': paypalAccountName,
    });
  }

  Future<void> sendPayoutRequest({
    required Timestamp timestamp,
    required String username,
    required String userUid,
    required String useremail,
    required String userimage,
    required String paypalLink,
    required String amountToTransfer,
    required String totalGeneratedForGd,
    required bool transferred,
    required BuildContext ctx,
  }) async {
    try {
      showTopSnackBar(
          ctx, CustomSnackBar.info(message: "Sending Payout Request"));

      await FirebaseFirestore.instance
          .collection("payoutRequest")
          .doc(userUid)
          .set({
        'timestamp': timestamp,
        'username': username,
        'userUid': userUid,
        'useremail': useremail,
        'userimage': userimage,
        'paypalLink': paypalLink,
        'amountToTransfer': amountToTransfer,
        'totalGeneratedForGd': totalGeneratedForGd,
        'transferred': transferred,
      }).whenComplete(() async {
        submitForm(
          date: timestamp.toDate().toIso8601String(),
          username: username,
          email: useremail,
          paypalLink: paypalLink,
          amountToTransfer: amountToTransfer,
          amountGeneratedForGD: totalGeneratedForGd,
        );
        showTopSnackBar(
            ctx, CustomSnackBar.success(message: "Request Successful!"));
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      showTopSnackBar(
          ctx, CustomSnackBar.error(message: "Error Sending Request"));
      log(e.toString());
    }
  }

  Future<void> reportVideo(
      {required Video video,
      required String reason,
      required BuildContext ctx}) async {
    final String reportId = nanoid();
    await FirebaseFirestore.instance
        .collection("reportedPosts")
        .doc(reportId)
        .set({
      'reportId': reportId,
      'videoId': video.id,
      'videoThumbnail': video.thumbnailurl,
      'timestamp': Timestamp.now(),
      'videoOwnerId': video.useruid,
      'videoOwnerUsername': video.username,
      'videoOwnerImage': video.userimage,
      'videoUrl': video.videourl,
      'reportReason': reason,
      'reportedById': Provider.of<Authentication>(ctx, listen: false).getUserId,
    });
  }

  Future<void> reportUser(
      {required UserModel userModel,
      required String reason,
      required BuildContext ctx}) async {
    final String reportId = nanoid();
    await FirebaseFirestore.instance
        .collection("reportedUsers")
        .doc(reportId)
        .set({
      'reportId': reportId,
      'userId': userModel.useruid,
      'userImage': userModel.userimage,
      'timestamp': Timestamp.now(),
      'reportReason': reason,
      'reportedById': Provider.of<Authentication>(ctx, listen: false).getUserId,
    });
  }

  Future<void> blockUser({
    required UserModel userModel,
    required BuildContext ctx,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(ctx, listen: false).getUserId)
        .collection("blockedAccounts")
        .doc(userModel.useruid)
        .set(userModel.toMap());
  }

  Future<void> unblockUser({
    required UserModel userModel,
    required BuildContext ctx,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(ctx, listen: false).getUserId)
        .collection("blockedAccounts")
        .doc(userModel.useruid)
        .delete();
  }

  Future updateUserDetailsAdmin(
      {required bool isVerified,
      required int percentage,
      required String useruid}) async {
    await FirebaseFirestore.instance.collection("users").doc(useruid).update({
      'percentage': percentage,
      "isverified": isVerified,
    });

    log("isVerified == $isVerified");

    await FirebaseFirestore.instance
        .collection("posts")
        .where("useruid", isEqualTo: useruid)
        .get()
        .then((allVidsForThatUser) {
      log("no of vids = ${allVidsForThatUser.docs.length}");
      allVidsForThatUser.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(element.id)
            .update({
          'verifiedUser': isVerified,
        }).then((value) {
          log("done updating for id = ${element.id}");
        });
      });
    });

    log("updated all for that user");
  }

  Future addCaratsToUser(
      {required String userid, required int caratValue}) async {
    await FirebaseFirestore.instance.collection("users").doc(userid).update({
      "carats": caratValue,
    });
  }

  Future updateCaratsOfUser(
      {required String userid, required int caratValue}) async {
    await FirebaseFirestore.instance.collection("users").doc(userid).update({
      "carats": caratValue,
    });
  }

  Future addUserToNotifierList({
    required String accountOwnerId,
    required NotifyUsers notifyUsers,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(accountOwnerId)
        .collection("notifyUsers")
        .doc(notifyUsers.personalUserId)
        .set({
      "personalUserId": notifyUsers.personalUserId,
      "token": notifyUsers.token
    });

    log("done notifyi");
  }

  Future removeUserFromNotifierList(
      {required String accountOwnerId, required personlUserid}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(accountOwnerId)
        .collection("notifyUsers")
        .doc(personlUserid)
        .delete();
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
                  title: "$initUserName has a new post!",
                  body: "");
            }));
  }

  Future hideUnhideItem(
      {required String videoId,
      required String itemId,
      required bool hideVal}) async {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(videoId)
        .collection("materials")
        .doc(itemId)
        .update({
      "hideItem": hideVal,
    });
  }

  Future hideUnhideItemDrafts(
      {required String videoId,
      required String itemId,
      required bool hideVal}) async {
    return FirebaseFirestore.instance
        .collection("drafts")
        .doc(videoId)
        .collection("materials")
        .doc(itemId)
        .update({
      "hideItem": hideVal,
    });
  }

  Future updatePostView(
      {required String videoId,
      required String useruidVal,
      required Video videoVal}) async {
    if (videoVal.isPaid) {
      log("paid video but bought?");
      if (videoVal.boughtBy.contains(useruidVal)) {
        log("paid video but bought? YEs user bought");

        await FirebaseFirestore.instance
            .collection("posts")
            .doc(videoId)
            .update({
          "views": FieldValue.increment(1),
        });
      }
    } else if (videoVal.isFree) {
      log("Free video view ");
      await FirebaseFirestore.instance.collection("posts").doc(videoId).update({
        "views": FieldValue.increment(1),
      });
    }
  }

  Future goFromDraftToPosts({
    required String caption,
    required String video_title,
    required String id,
    required String userUid,
    required String coverThumbnailUrl,
    required bool isFree,
    required bool isPaid,
    required String videoUrlVal,
    double? price,
    double? discountAmount,
    Timestamp? startDiscountDate,
    Timestamp? endDiscountDate,
    required List<String?> genre,
    required bool isverifiedVal,
  }) async {
    String name = "${caption} ${video_title}";

    List<String> splitList = name.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int j = 0; j < splitList[i].length; j++) {
        indexList.add(splitList[i].substring(0, j + 1).toLowerCase());
      }
    }

    log("updating from drafts to posts == id $id");

    await FirebaseFirestore.instance.collection("posts").doc(id).set({
      "id": id,
      "useruid": userUid,
      "videourl": videoUrlVal,
      "videotitle": video_title,
      "caption": caption,
      "timestamp": Timestamp.now(),
      "username": initUserName,
      "userimage": initUserImage,
      "thumbnailurl": coverThumbnailUrl,
      "isfree": isFree,
      "ispaid": isPaid,
      "issubscription": false,
      "price": price,
      "discountamount": discountAmount,
      "startdiscountdate": startDiscountDate,
      "enddiscountdate": endDiscountDate,
      "contentavailability": "All",
      'ownerFcmToken': fcmToken,
      "searchindexList": indexList,
      "genre": genre,
      'boughtBy': [],
      'totalBilled': 0,
      'verifiedUser': isverifiedVal,
      "videoType": "video",
    }).then((value) async {
      log("now moving materials");

      await FirebaseFirestore.instance
          .collection("drafts")
          .doc(id)
          .collection("materials")
          .get()
          .then((materialsVal) async {
        for (QueryDocumentSnapshot<Map<String, dynamic>> element
            in materialsVal.docs) {
          await FirebaseFirestore.instance
              .collection("posts")
              .doc(id)
              .collection("materials")
              .doc(element.id)
              .set(element.data());
        }
      });

      log("posted everything, now delete from draft");
      await FirebaseFirestore.instance.collection("drafts").doc(id).delete();
      log("deleted from drafts");
    });
  }
}
