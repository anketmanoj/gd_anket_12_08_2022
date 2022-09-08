// To parse this JSON data, do
//
//     final purchaseCarats = purchaseCaratsFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class PurchaseCarats {
  PurchaseCarats({
    required this.price,
    required this.name,
  });

  double price;
  String name;

  factory PurchaseCarats.fromJson(String str) =>
      PurchaseCarats.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PurchaseCarats.fromMap(Map<String, dynamic> json) => PurchaseCarats(
        price: json["price"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "price": price,
        "name": name,
      };
}
