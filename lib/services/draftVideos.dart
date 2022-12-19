import 'package:cached_video_player/cached_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DraftVideo {
  String id;
  String useruid;
  String videourl;
  String caption;
  bool isPaid;
  double price;
  double discountAmount;
  Timestamp startDiscountDate;
  Timestamp endDiscountDate;
  bool isSubscription;
  String contentAvailability;
  bool isFree;
  String username;
  String userimage;
  String videotitle;
  Timestamp timestamp;
  String thumbnailurl;
  String? ownerFcmToken;
  List<dynamic> genre;
  List<dynamic> boughtBy;
  int? totalBilled;
  bool? verifiedUser;
  String? videoType;
  int? views;
  ValueNotifier<bool>? deletethis = ValueNotifier<bool>(false);

  CachedVideoPlayerController? controller;

  // create video constructor
  DraftVideo({
    required this.id,
    required this.useruid,
    required this.videourl,
    required this.caption,
    required this.isPaid,
    required this.price,
    required this.discountAmount,
    required this.startDiscountDate,
    required this.endDiscountDate,
    required this.isSubscription,
    required this.contentAvailability,
    required this.isFree,
    required this.username,
    required this.userimage,
    required this.videotitle,
    required this.timestamp,
    required this.thumbnailurl,
    required this.ownerFcmToken,
    required this.genre,
    required this.boughtBy,
    this.totalBilled,
    this.verifiedUser,
    this.videoType = "video",
    this.views = 0,
    this.deletethis,
  });

  // create video from json
  factory DraftVideo.fromJson(Map<String, dynamic> json) {
    return DraftVideo(
      id: json['id'] as String,
      useruid: json['useruid'] as String,
      videourl: json['videourl'] as String,
      caption: json['caption'] as String,
      isPaid: json['ispaid'] as bool,
      price: json['price'] as double,
      discountAmount: json['discountamount'] as double,
      startDiscountDate: json['startdiscountdate'] as Timestamp,
      endDiscountDate: json['enddiscountdate'] as Timestamp,
      isSubscription: json['issubscription'] as bool,
      contentAvailability: json['contentavailability'] as String,
      isFree: json['isfree'] as bool,
      username: json['username'] as String,
      userimage: json['userimage'] as String,
      videotitle: json['videotitle'] as String,
      videoType: json['videoType'] as String,
      timestamp: json['timestamp'] as Timestamp,
      thumbnailurl: json['thumbnailurl'].toString(),
      ownerFcmToken: json['ownerFcmToken'] as String?,
      genre: json['genre'] as List<dynamic>,
      boughtBy: json['boughtBy'] as List<dynamic>,
      totalBilled: json['totalBilled'] as int?,
      verifiedUser: json['verifiedUser'] as bool?,
      views: json['views'] ?? 0,
      deletethis: ValueNotifier<bool>(false),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'useruid': useruid,
      'videourl': videourl,
      'caption': caption,
      'ispaid': isPaid,
      'price': price,
      'discountamount': discountAmount,
      'startdiscountdate': startDiscountDate,
      'enddiscountdate': endDiscountDate,
      'issubscription': isSubscription,
      'contentavailability': contentAvailability,
      'isfree': isFree,
      'username': username,
      'userimage': userimage,
      'videotitle': videotitle,
      'timestamp': timestamp,
      'thumbnailurl': thumbnailurl,
      'ownerFcmToken': ownerFcmToken,
      'genre': genre,
      'boughtBy': boughtBy,
      'totalBilled': totalBilled,
      'verifiedUser': verifiedUser,
      'videoType': videoType,
      'views': views,
      'archive': false,
    };
  }

  Future<Null> loadController() async {
    controller = CachedVideoPlayerController.network(videourl);
    await controller?.initialize();
    // controller?.setLooping(true);
  }
}
