// To parse this JSON data, do
//
//     final languageModle = languageModleFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class LanguageModel {
  LanguageModel({
    required this.flag,
    required this.name,
    required this.locale,
  });

  String flag;
  String name;
  String locale;

  factory LanguageModel.fromJson(String str) =>
      LanguageModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LanguageModel.fromMap(Map<String, dynamic> json) => LanguageModel(
        flag: json["flag"],
        name: json["name"],
        locale: json["locale"],
      );

  Map<String, dynamic> toMap() => {
        "flag": flag,
        "name": name,
        "locale": locale,
      };
}
