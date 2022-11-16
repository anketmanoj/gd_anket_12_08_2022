import 'package:cloud_firestore/cloud_firestore.dart';

class MyArCollection {
  String id;
  String gif;
  String main;
  String alpha;
  String layerType;
  String valueType;
  Timestamp timestamp;
  List<String> imgSeq;
  String audioFile;
  bool audioFlag = false;
  String ownerId;
  String ownerName;
  String? usage = 'Material';
  String? endDuration;

  MyArCollection({
    required this.gif,
    required this.main,
    required this.alpha,
    required this.id,
    required this.layerType,
    required this.valueType,
    required this.timestamp,
    required this.imgSeq,
    required this.audioFile,
    required this.audioFlag,
    required this.ownerId,
    required this.ownerName,
    this.usage,
    this.endDuration,
  });

  // create myarcollection from json
  factory MyArCollection.fromJson(Map<String, dynamic> json) {
    return MyArCollection(
      id: json['id'],
      gif: json['gif'] ?? "",
      main: json['main'] ?? "",
      alpha: json['alpha'] ?? "",
      audioFlag: json['audioFlag'] ?? false,
      layerType: json['layerType'] ?? "",
      valueType: json['valueType'] ?? "",
      audioFile: json['audioFile'] ?? "",
      timestamp: json['timestamp'] as Timestamp,
      ownerId: json['ownerId'] ?? "",
      ownerName: json['ownerName'] ?? "",
      usage: json['usage'] as String?,
      endDuration: json['endDuration'] ?? "",
      imgSeq: json['imgSeq'] != null
          ? (json['imgSeq'] as List).map((item) => item as String).toList()
          : [],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'gif': gif,
      'main': main,
      'alpha': alpha,
      'id': id,
      'layerType': layerType,
      'timestamp': timestamp,
      'imgSeq': imgSeq,
      'valueType': valueType,
      'audioFile': audioFile,
      'audioFlag': audioFlag,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'usage': usage,
      'endDuration': endDuration,
    };
  }
}
