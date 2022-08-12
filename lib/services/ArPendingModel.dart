// To parse this JSON data, do
//
//     final arPendingModel = arPendingModelFromMap(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ArPendingModel {
  ArPendingModel({
    required this.gif,
    required this.layerType,
    required this.valueType,
    required this.timestamp,
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.usage,
    main,
  });

  String gif;
  String layerType;
  String valueType;
  Timestamp timestamp;
  String id;
  String ownerId;
  String ownerName;
  String usage;
  String? main;

  factory ArPendingModel.fromJson(String str) =>
      ArPendingModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ArPendingModel.fromMap(Map<String, dynamic> json) => ArPendingModel(
        gif: json["gif"],
        layerType: json["layerType"],
        valueType: json["valueType"],
        timestamp: json["timestamp"],
        id: json["id"],
        ownerId: json["ownerId"],
        ownerName: json["ownerName"],
        usage: json["usage"],
        main: json["main"],
      );

  Map<String, dynamic> toMap() => {
        "gif": gif,
        "layerType": layerType,
        "valueType": valueType,
        "timestamp": timestamp,
        "id": id,
        "ownerId": ownerId,
        "ownerName": ownerName,
        "usage": usage,
        "main": main,
      };
}
