// To parse this JSON data, do
//
//     final notifyUsers = notifyUsersFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class NotifyUsers {
  NotifyUsers({
    required this.personalUserId,
    required this.token,
  });

  String personalUserId;
  String token;

  factory NotifyUsers.fromJson(String str) =>
      NotifyUsers.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotifyUsers.fromMap(Map<String, dynamic> json) => NotifyUsers(
        personalUserId: json["personalUserId"],
        token: json["token"],
      );

  Map<String, dynamic> toMap() => {
        "personalUserId": personalUserId,
        "token": token,
      };
}
