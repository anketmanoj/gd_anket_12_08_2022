// To parse this JSON data, do
//
//     final user = userFromMap(jsonString);

// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    this.address,
    this.isverified,
    this.userbio,
    this.usercontactnumber,
    this.usercover,
    this.usercreatedat,
    this.userdob,
    required this.useremail,
    this.userfacebookurl,
    this.usergender,
    required this.userimage,
    this.userinstagramurl,
    required this.username,
    this.userrealname,
    this.usersearchindex,
    this.usertiktokurl,
    required this.useruid,
    required this.token,
    required this.totalmade,
    this.paypal,
    required this.percentage,
  });

  String? address;
  bool? isverified;
  String? userbio;
  String? usercontactnumber;
  String? usercover;
  Timestamp? usercreatedat;
  Timestamp? userdob;
  String useremail;
  String? userfacebookurl;
  String? usergender;
  String userimage;
  String? userinstagramurl;
  String username;
  String? userrealname;
  List<dynamic>? usersearchindex;
  String? usertiktokurl;
  String useruid;
  String token;
  int totalmade;
  String? paypal;
  int percentage;

  factory UserModel.fromJson(String str) => UserModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
        address: json["address"],
        isverified: json["isverified"],
        userbio: json["userbio"],
        usercontactnumber: json["usercontactnumber"],
        usercover: json["usercover"],
        usercreatedat: json["usercreatedat"],
        userdob: json["userdob"],
        useremail: json["useremail"],
        userfacebookurl: json["userfacebookurl"],
        usergender: json["usergender"],
        userimage: json["userimage"],
        userinstagramurl: json["userinstagramurl"],
        username: json["username"],
        userrealname: json["userrealname"],
        usersearchindex: json["usersearchindex"],
        usertiktokurl: json["usertiktokurl"],
        useruid: json["useruid"],
        token: json["token"],
        totalmade: json["totalmade"],
        paypal: json["paypal"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toMap() => {
        "address": address,
        "isverified": isverified,
        "userbio": userbio,
        "usercontactnumber": usercontactnumber,
        "usercover": usercover,
        "usercreatedat": usercreatedat,
        "userdob": userdob,
        "useremail": useremail,
        "userfacebookurl": userfacebookurl,
        "usergender": usergender,
        "userimage": userimage,
        "userinstagramurl": userinstagramurl,
        "username": username,
        "userrealname": userrealname,
        "usersearchindex": usersearchindex,
        "usertiktokurl": usertiktokurl,
        "useruid": useruid,
        "token": token,
        "totalmade": totalmade,
        "paypal": paypal,
        "percentage": percentage,
      };
}
