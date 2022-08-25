// To parse this JSON data, do
//
//     final effectBgModel = effectBgModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class EffectModel {
  EffectModel({
    required this.gif,
    required this.id,
    this.layerType,
    this.owner,
    required this.ownerId,
    required this.timestamp,
    required this.usage,
    required this.valueType,
  });

  String gif;
  String id;
  String? layerType;
  String? owner;
  String ownerId;
  Timestamp timestamp;
  String usage;
  String valueType;

  factory EffectModel.fromJson(String str) =>
      EffectModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EffectModel.fromMap(Map<String, dynamic> json) => EffectModel(
        gif: json["gif"],
        id: json["id"],
        layerType: json["layerType"],
        owner: json["owner"],
        ownerId: json["ownerId"],
        timestamp: json["timestamp"],
        usage: json["usage"],
        valueType: json["valueType"],
      );

  Map<String, dynamic> toMap() => {
        "gif": gif,
        "id": id,
        "layerType": layerType,
        "owner": owner,
        "ownerId": ownerId,
        "timestamp": timestamp,
        "usage": usage,
        "valueType": valueType,
      };
}
