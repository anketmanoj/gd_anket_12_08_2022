import 'dart:convert';

class GraphData {
  GraphData({
    required this.id,
    required this.month,
    required this.amount,
  });

  String id;
  int month;
  double amount;

  factory GraphData.fromJson(String str) => GraphData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GraphData.fromMap(Map<String, dynamic> json) => GraphData(
        id: json["id"],
        month: json["month"],
        amount: json["amount"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "month": month,
        "amount": amount,
      };
}
