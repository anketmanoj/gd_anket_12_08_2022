import 'dart:io';

import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/PostPage/previewVideo.dart';
import 'package:diamon_rose_app/screens/VideoWorkAll/select_model/select_model_screen.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PostScreen extends StatefulWidget {
  PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ConstantColors constantColors = ConstantColors();

  XFile? _videoFile;
  // ignore: use_late_for_private_fields_and_variables
  VideoPlayerController? _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<File> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    final File file = File(fileName!);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 60,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  addStory(context: context);
                  // SelectModelScreen();
                },
                child: Text(
                  "Post Video",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  addStory({required BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: StatefulBuilder(builder: (context, innerState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.darkColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 150),
                    child: Divider(
                      thickness: 4,
                      color: constantColors.whiteColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: "Gallery",
                              backgroundColor: constantColors.greenColor,
                              child: Icon(
                                Icons.photo_album,
                                color: constantColors.whiteColor,
                              ),
                              onPressed: () async {
                                XFile? video = await ImagePicker()
                                    .pickVideo(source: ImageSource.gallery);

                                innerState(() {
                                  _videoFile = video;
                                });

                                print(_videoFile!.path);

                                final File file =
                                    await genThumbnailFile(_videoFile!.path);

                                _videoPlayerController =
                                    VideoPlayerController.file(
                                        File(_videoFile!.path));

                                _videoPlayerController!
                                  // ignore: unawaited_futures
                                  ..initialize().then((value) {
                                    // _videoPlayerController!.play();
                                    // Navigator.push(
                                    //     context,
                                    //     PageTransition(
                                    //         child: PreviewVideoScreen(
                                    //             thumbnailFile: file,
                                    //             videoFile:
                                    //                 File(_videoFile!.path),
                                    //             videoPlayerController:
                                    //                 _videoPlayerController!),
                                    //         type: PageTransitionType.fade));
                                  });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Gallery",
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            FloatingActionButton(
                              heroTag: "Camera",
                              backgroundColor: constantColors.blueColor,
                              child: Icon(
                                FontAwesomeIcons.camera,
                                color: constantColors.whiteColor,
                              ),
                              onPressed: () async {
                                XFile? video = await ImagePicker()
                                    .pickVideo(source: ImageSource.camera);

                                innerState(() {
                                  _videoFile = video;
                                });

                                print(_videoFile!.path);

                                final File file =
                                    await genThumbnailFile(_videoFile!.path);

                                _videoPlayerController =
                                    VideoPlayerController.file(
                                        File(_videoFile!.path));

                                _videoPlayerController!
                                  // ignore: unawaited_futures
                                  ..initialize().then((value) {
                                    // _videoPlayerController!.play();

                                    // Navigator.push(
                                    //     context,
                                    //     PageTransition(
                                    //         child: PreviewVideoScreen(
                                    //             thumbnailFile: file,
                                    //             videoFile:
                                    //                 File(_videoFile!.path),
                                    //             videoPlayerController:
                                    //                 _videoPlayerController!),
                                    //         type: PageTransitionType.fade));
                                  });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Camera",
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
