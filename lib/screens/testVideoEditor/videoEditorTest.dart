// // ignore_for_file: avoid_catches_without_on_clauses

// import 'dart:convert';
// import 'dart:io';

// import 'package:diamon_rose_app/screens/testVideoEditor/imgseqanimation.dart';
// import 'package:ffmpeg_kit_flutter_https_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_https_gpl/ffprobe_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_gif/flutter_gif.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_sequence_animator/image_sequence_animator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class TestVideoEditor extends StatefulWidget {
//   TestVideoEditor({Key? key}) : super(key: key);

//   @override
//   State<TestVideoEditor> createState() => _TestVideoEditorState();
// }

// class _TestVideoEditorState extends State<TestVideoEditor>
//     with TickerProviderStateMixin {
//   File? _videoFile;
//   File? outputFile;
//   File? matteFile;
//   bool finishedFFmpeg = false;
//   double? sliderValue;
//   bool loading = true;
//   String? folderName;
//   File? audioFile;

//   List<String> _fullPathsOffline = [];
//   ImageSequenceAnimatorState? offlineImageSequenceAnimator;

//   void onOfflineReadyToPlay(ImageSequenceAnimatorState _imageSequenceAnimator) {
//     offlineImageSequenceAnimator = _imageSequenceAnimator;
//   }

//   void onOfflinePlaying(ImageSequenceAnimatorState _imageSequenceAnimator) {
//     setState(() {});
//   }

//   late FlutterGifController controller;

//   @override
//   void initState() {
//     super.initState();
//     runFFmpegCommand();
//   }

//   Future<void> runFFmpegCommand() async {
//     if (await Permission.storage.request().isGranted) {
//       // Form matte file
//       final Directory appDocument = await getApplicationDocumentsDirectory();
//       final String rawDocument = appDocument.path;
//       final String imgSeqFolder = "${rawDocument}/";

//       setState(() {
//         folderName = imgSeqFolder;
//       });

//       try {
//         await FFprobeKit.execute(
//                 '-i ${Uri.parse("https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2Ftest_input%20(1).mp4?alt=media&token=8487186e-6a0d-48ff-b41c-6f5151be68f4")} -show_entries format=duration -v quiet -of json')
//             .then((value) {
//           value.getOutput().then((mapOutput) async {
//             final Map<String, dynamic> json = jsonDecode(mapOutput!);

//             final String durationString = json['format']['duration'];

//             print("durationString: $durationString");

//             //! #############################################################
//             final String commandForImgSeqFile =
//                 '-y -i ${Uri.parse("https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2Ftest_input%20(1).mp4?alt=media&token=8487186e-6a0d-48ff-b41c-6f5151be68f4")} -i ${Uri.parse("https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2Ftest_alpha.mp4?alt=media&token=cd9c6984-c5ef-47cb-960b-50cb7a4fabff")} -filter_complex "[1][0]scale2ref[mask][main];[main][mask]alphamerge,fps=25,scale=720:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" ${imgSeqFolder}imgSeq%d.png';

//             try {
//               await FFmpegKit.execute(commandForImgSeqFile).then((rc) async {
//                 for (int i = 0;
//                     i < (double.parse(durationString).floor() * 25);
//                     i++) {
//                   _fullPathsOffline.add("${imgSeqFolder}imgSeq$i.png");
//                 }
//               });

//               _fullPathsOffline.removeAt(0);

//               _fullPathsOffline.forEach((element) {
//                 print(" element: $element");
//               });
//               setState(() {
//                 loading = false;
//               });
//               print("folder name $folderName");
//             } catch (e) {
//               print("FFmpeg img seq Error ==== ${e.toString()}");
//             }

//             // Extract audio

//             try {
//               await FFmpegKit.execute(
//                       '-vn -sn -dn -y -i ${Uri.parse("https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2Ftest_input%20(1).mp4?alt=media&token=8487186e-6a0d-48ff-b41c-6f5151be68f4")} -vn -acodec copy ${imgSeqFolder}audio.aac')
//                   .then((rc) {
//                 print("FFmpeg audio extraction success");
//                 audioFile = File("${imgSeqFolder}audio.aac");
//               });
//             } catch (e) {
//               print("FFmpeg audio extraction Error ==== ${e.toString()}");
//             } catch (e) {}
//             //! #############################################################
//           });
//         });
//       } catch (e) {
//         print("FFmpeg Error ==== ${e.toString()}");
//       }
//     } else if (await Permission.storage.request().isDenied) {
//       await openAppSettings();
//     }
//   }

//   // Future<File> writeToFile(ByteData data) async {
//   //   final buffer = data.buffer;
//   //   Directory tempDir = await getApplicationDocumentsDirectory();
//   //   String tempPath = tempDir.path;
//   //   var filePath =
//   //       tempPath + '/video.tmp'; // file_01.tmp is dump file, can be anything
//   //   return new File(filePath).writeAsBytes(
//   //       buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       body: loading
//           ? Center(
//               child: Text(
//                 "Processing video",
//                 style: TextStyle(
//                   fontSize: 30,
//                   color: Colors.white,
//                 ),
//               ),
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   child: Column(
//                     children: [
//                       Text("Loading done"),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => ImageSeqAniScreen(
//                                 player: audioFile!,
//                                 folderName: folderName!,
//                                 fileName: "imgSeq",
//                                 fullPathsOffline: _fullPathsOffline,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Text("ImgSeqScreen"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Container(
//                 //   height: 200,
//                 //   child: Image.file(File(_fullPathsOffline[3])),
//                 // ),
//               ],
//             ),
//     );
//   }
// }
