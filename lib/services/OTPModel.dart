// To parse this JSON data, do
//
//     final otpSecreteId = otpSecreteIdFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class OtpSecreteId {
  OtpSecreteId({
    required this.secretId,
  });

  String secretId;

  factory OtpSecreteId.fromJson(String str) =>
      OtpSecreteId.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OtpSecreteId.fromMap(Map<String, dynamic> json) => OtpSecreteId(
        secretId: json["secret_id"],
      );

  Map<String, dynamic> toMap() => {
        "secret_id": secretId,
      };
}
