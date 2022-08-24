// import 'package:diamon_rose_app/config.dart';
// import 'package:diamon_rose_app/constants/mux_constants.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;

// Future<String> getPlayBackId(String videoFirebaseUrl) async {
//   try {
//     print('${MUX_BASE_URL}assets');
//     // var response =
//     //     await http.post(, body: {'name': 'doodle', 'color': 'blue'});

//     var result = await getIt
//         .get<Dio>()
//         .post(MUX_BASE_URL + 'assets', data: {"videoUrl": videoFirebaseUrl});

//     return result.data['data']['playback_ids'][0]['id'];
//   } catch (e) {
//     print(e);
//     return Future.value("");
//   }
// }

// String getMuxVideoUrl(String playBackId) {
//   return MUX_STREAM_SERVER + playBackId + MUX_VIDEO_EXTENSION;
// }

// String getMuxThumbnailImage(String playBackId) {
//   return MUX_THUMB_SERVER + playBackId + MUX_IMAGE_EXTENSION;
// }
