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
      gif: json['gif'] as String,
      main: json['main'] as String,
      alpha: json['alpha'] as String,
      audioFlag: json['audioFlag'] ?? false,
      layerType: json['layerType'].toString(),
      valueType: json['valueType'].toString(),
      audioFile: json['audioFile'].toString(),
      timestamp: json['timestamp'] as Timestamp,
      ownerId: json['ownerId'].toString(),
      ownerName: json['ownerName'].toString(),
      usage: json['usage'] as String?,
      endDuration: json['endDuration'].toString(),
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
      'endDuration': endDuration,
    };
  }
}
