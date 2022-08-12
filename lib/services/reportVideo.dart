// To parse this JSON data, do
//
//     final reportVideo = reportVideoFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class ReportVideo {
  ReportVideo({
    required this.reportId,
    required this.videoId,
    required this.videoThumbnail,
    required this.timestamp,
    required this.videoOwnerId,
    required this.videoOwnerUsername,
    required this.videoOwnerImage,
    required this.videoUrl,
    required this.reportReason,
    required this.reportedById,
  });

  String reportId;
  String videoId;
  String videoThumbnail;
  Timestamp timestamp;
  String videoOwnerId;
  String videoOwnerUsername;
  String videoOwnerImage;
  String videoUrl;
  String reportReason;
  String reportedById;

  factory ReportVideo.fromJson(String str) =>
      ReportVideo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ReportVideo.fromMap(Map<String, dynamic> json) => ReportVideo(
        reportId: json["reportId"],
        videoId: json["videoId"],
        videoThumbnail: json["videoThumbnail"],
        timestamp: json["timestamp"],
        videoOwnerId: json["videoOwnerId"],
        videoOwnerUsername: json["videoOwnerUsername"],
        videoOwnerImage: json["videoOwnerImage"],
        videoUrl: json["videoUrl"],
        reportReason: json["reportReason"],
        reportedById: json["reportedById"],
      );

  Map<String, dynamic> toMap() => {
        "reportId": reportId,
        "videoId": videoId,
        "videoThumbnail": videoThumbnail,
        "timestamp": timestamp,
        "videoOwnerId": videoOwnerId,
        "videoOwnerUsername": videoOwnerUsername,
        "videoOwnerImage": videoOwnerImage,
        "videoUrl": videoUrl,
        "reportReason": reportReason,
        "reportedById": reportedById,
      };
}
