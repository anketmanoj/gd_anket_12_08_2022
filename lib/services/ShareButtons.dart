// To parse this JSON data, do
//
//     final shareButtons = shareButtonsFromMap(jsonString);

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class ShareButtons {
  ShareButtons({
    required this.iconData,
    required this.onButtonTop,
  });

  IconData iconData;
  void Function() onButtonTop;

  factory ShareButtons.fromJson(String str) =>
      ShareButtons.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ShareButtons.fromMap(Map<String, dynamic> json) => ShareButtons(
        iconData: json["iconData"],
        onButtonTop: json["onButtonTop"],
      );

  Map<String, dynamic> toMap() => {
        "iconData": iconData,
        "onButtonTop": onButtonTop,
      };
}
