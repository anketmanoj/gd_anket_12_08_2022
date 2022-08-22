// To parse this JSON data, do
//
//     final adminList = adminListFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class AdminList {
  AdminList({
    required this.adminList,
  });

  List<String> adminList;

  factory AdminList.fromJson(String str) => AdminList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdminList.fromMap(Map<String, dynamic> json) => AdminList(
        adminList: List<String>.from(json["adminList"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "adminList": List<dynamic>.from(adminList.map((x) => x)),
      };
}
