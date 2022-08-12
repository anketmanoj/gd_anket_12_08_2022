// To parse this JSON data, do
//
//     final arViewOnlyModel = arViewOnlyModelFromMap(jsonString);

import 'dart:convert';

class ArViewOnlyModel {
  ArViewOnlyModel({
    required this.ARwithGDbackcover,
  });

  String ARwithGDbackcover;

  factory ArViewOnlyModel.fromJson(String str) =>
      ArViewOnlyModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ArViewOnlyModel.fromMap(Map<String, dynamic> json) => ArViewOnlyModel(
        ARwithGDbackcover: json["ARwithGDbackcover"],
      );

  Map<String, dynamic> toMap() => {
        "ARwithGDbackcover": ARwithGDbackcover,
      };
}
