// To parse this JSON data, do
//
//     final debugClass = debugClassFromMap(jsonString);

import 'dart:convert';

class DebugClass {
  DebugClass({
    required this.debug,
  });

  bool debug;

  factory DebugClass.fromJson(String str) =>
      DebugClass.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DebugClass.fromMap(Map<String, dynamic> json) => DebugClass(
        debug: json["debug"],
      );

  Map<String, dynamic> toMap() => {
        "debug": debug,
      };
}
