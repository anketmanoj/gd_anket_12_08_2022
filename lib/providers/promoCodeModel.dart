// To parse this JSON data, do
//
//     final promoCodeModel = promoCodeModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class PromoCodeModel {
  PromoCodeModel({
    required this.name,
    required this.promocode,
    required this.creatorname,
    required this.date,
  });

  String name;
  String promocode;
  String creatorname;
  Timestamp date;

  factory PromoCodeModel.fromJson(String str) =>
      PromoCodeModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PromoCodeModel.fromMap(Map<String, dynamic> json) => PromoCodeModel(
        name: json["name"],
        promocode: json["promocode"],
        creatorname: json["creatorname"],
        date: json["date"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "promocode": promocode,
        "creatorname": creatorname,
        "date": date,
      };
}
