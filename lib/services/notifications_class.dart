import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id;
  String? postId;
  bool seen;
  Timestamp timestamp;
  String type;
  String useremail;
  String userimage;
  String username;
  String useruid;

  NotificationModel({
    required this.id,
    this.postId,
    required this.seen,
    required this.timestamp,
    required this.type,
    required this.useremail,
    required this.userimage,
    required this.username,
    required this.useruid,
  });

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        postId = json['postid'],
        seen = json['seen'],
        timestamp = json['timestamp'],
        type = json['type'],
        useremail = json['useremail'],
        userimage = json['userimage'],
        username = json['username'],
        useruid = json['useruid'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postid'] = this.postId;
    data['seen'] = this.seen;
    data['timestamp'] = this.timestamp;
    data['type'] = this.type;
    data['useremail'] = this.useremail;
    data['userimage'] = this.userimage;
    data['username'] = this.username;
    data['useruid'] = this.useruid;
    return data;
  }
}
