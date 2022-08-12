// To parse this JSON data, do
//
//     final rvmResponse = rvmResponseFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class RvmResponse {
  RvmResponse({
    required this.alphaFile,
    this.audioFile,
    required this.totalNumberPngs,
  });

  String alphaFile;
  String? audioFile;
  int totalNumberPngs;

  factory RvmResponse.fromJson(String str) =>
      RvmResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RvmResponse.fromMap(Map<String, dynamic> json) => RvmResponse(
        alphaFile: json["alpha_file"],
        audioFile: json["audio_file"],
        totalNumberPngs: json["total_number_pngs"],
      );

  Map<String, dynamic> toMap() => {
        "alpha_file": alphaFile,
        "audio_file": audioFile,
        "total_number_pngs": totalNumberPngs,
      };
}
