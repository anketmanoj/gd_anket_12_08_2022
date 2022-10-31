import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class GraphData {
  GraphData({
    required this.id,
    required this.month,
    required this.amount,
    required this.timestamp,
  });

  String id;
  int month;
  double amount;
  Timestamp timestamp;

  factory GraphData.fromJson(String str) => GraphData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GraphData.fromMap(Map<String, dynamic> json) => GraphData(
        id: json["id"],
        month: json["month"],
        amount: json["amount"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "month": month,
        "amount": amount,
        "timestamp": timestamp,
      };
}
