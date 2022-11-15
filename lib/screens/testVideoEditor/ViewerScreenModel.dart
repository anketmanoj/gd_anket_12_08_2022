// To parse this JSON data, do
//
//     final viewScreenModel = viewScreenModelFromMap(jsonString);

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class ViewScreenModel {
  ViewScreenModel({
    this.iconData,
    this.function,
    this.image,
  });

  IconData? iconData;
  void Function()? function;
  String? image;

  factory ViewScreenModel.fromJson(String str) =>
      ViewScreenModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ViewScreenModel.fromMap(Map<String, dynamic> json) => ViewScreenModel(
        iconData: json["iconData"],
        function: json["function"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "iconData": iconData,
        "function": function,
        "image": image,
      };
}
