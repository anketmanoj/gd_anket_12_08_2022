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
  bool audioFlag;
  String ownerId;
  String ownerName;
  String? usage = 'Material';

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
  });

  // create myarcollection from json
  factory MyArCollection.fromJson(Map<String, dynamic> json) {
    return MyArCollection(
      id: json['id'],
      gif: json['gif'] as String,
      main: json['main'] as String,
      alpha: json['alpha'] as String,
      audioFlag: json['audioFlag'] as bool,
      layerType: json['layerType'] as String,
      valueType: json['valueType'] as String,
      audioFile: json['audioFile'] as String,
      timestamp: json['timestamp'] as Timestamp,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      usage: json['usage'] as String?,
      imgSeq: (json['imgSeq'] as List).map((item) => item as String).toList(),
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
    };
  }
}
