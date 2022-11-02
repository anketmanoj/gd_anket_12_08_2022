// To parse this JSON data, do
//
//     final payoutRequestModel = payoutRequestModelFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

PayoutRequestModel payoutRequestModelFromJson(String str) =>
    PayoutRequestModel.fromJson(json.decode(str));

String payoutRequestModelToJson(PayoutRequestModel data) =>
    json.encode(data.toJson());

class PayoutRequestModel {
  PayoutRequestModel({
    required this.amountToTransfer,
    required this.paypalLink,
    required this.timestamp,
    required this.totalGeneratedForGd,
    required this.transferred,
    required this.userUid,
    required this.useremail,
    required this.userimage,
    required this.username,
  });

  String amountToTransfer;
  String paypalLink;
  Timestamp timestamp;
  String totalGeneratedForGd;
  bool transferred;
  String userUid;
  String useremail;
  String userimage;
  String username;

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) =>
      PayoutRequestModel(
        amountToTransfer: json["amountToTransfer"],
        paypalLink: json["paypalLink"],
        timestamp: json["timestamp"],
        totalGeneratedForGd: json["totalGeneratedForGd"],
        transferred: json["transferred"],
        userUid: json["userUid"],
        useremail: json["useremail"],
        userimage: json["userimage"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "amountToTransfer": amountToTransfer,
        "paypalLink": paypalLink,
        "timestamp": timestamp,
        "totalGeneratedForGd": totalGeneratedForGd,
        "transferred": transferred,
        "userUid": userUid,
        "useremail": useremail,
        "userimage": userimage,
        "username": username,
      };
}
