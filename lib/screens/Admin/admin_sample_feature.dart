import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class ContainerList {
  double? height;
  double? width;
  double? scale;
  double? rotation;
  double? xPosition;
  double? yPosition;
  String? gifSelected;

  ContainerList({
    this.height,
    this.rotation,
    this.scale,
    this.width,
    this.xPosition,
    this.yPosition,
    this.gifSelected,
  });
}

class KotohoSampleFeature extends StatefulWidget {
  const KotohoSampleFeature(
      {Key? key,
      this.gifUrl =
          "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FDress-Outline%20(1).png?alt=media&token=9b27ed6c-b787-412f-96d4-231e2530c70e"})
      : super(key: key);
  final String gifUrl;

  @override
  _KotohoSampleFeatureState createState() => _KotohoSampleFeatureState();
}

class _KotohoSampleFeatureState extends State<KotohoSampleFeature> {
  CameraController? controller;
  List<ContainerList> list = [];
  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  bool showCamera = false;
  Size? screen;
  late String selectedGif;
  bool isLoading = true;
  bool canMove = false;
  bool imageTaken = false;
  late File imageFile;

  List<String> outfitsList = [
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FDress-Outline%20(2).png?alt=media&token=2ef9a7c6-36ed-4078-ac80-b920d674cc79",
    "https://firebasestorage.googleapis.com/v0/b/gdfe-ac584.appspot.com/o/test%2FDress-Outline.png?alt=media&token=de028540-6333-4872-902e-0455fb85ac3e",
  ];

  @override
  void initState() {
    screen = Size(400, 500);
    list.add(ContainerList(
      height: 80.h,
      width: 100.w,
      rotation: 0.0,
      scale: 2.0,
      xPosition: 0,
      yPosition: 0,
      gifSelected: widget.gifUrl,
    ));

    dev.log("starting x = ${list[0].xPosition!}");

    super.initState();
    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller!.startImageStream(
        (CameraImage image) {},
      );

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar2 = AppBar(
      title: const Text('Kotoho Sample'),
      backgroundColor: constantColors.black,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              imageTaken = false;
              canMove = false;
              list[0].gifSelected =
                  "https://images.twinkl.co.uk/tr/image/upload/t_illustration/illustation/Dress-Outline.png";
            });
          },
          icon: Icon(Icons.restore),
        ),
      ],
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile file = await controller!.takePicture();
          setState(() {
            imageFile = File(file.path);
            imageTaken = true;
            canMove = true;
            list[0].gifSelected = outfitsList[0];
          });
        },
        child: Icon(Icons.camera),
        backgroundColor: constantColors.navButton,
        foregroundColor: constantColors.whiteColor,
      ),
      appBar: appBar2,
      backgroundColor: Colors.black,
      body: isLoading == false
          ? Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: imageTaken == false
                      ? CameraPreview(controller!)
                      : Image.file(imageFile),
                ),
                Container(
                  height: MediaQuery.of(context).size.height -
                      appBar2.preferredSize.height -
                      100,
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  // color: constantColors.redColor,
                  child: Stack(
                    children: list.map((value) {
                      return GestureDetector(
                        onScaleStart: (details) {
                          if (value == null) return;
                          _initPos = details.focalPoint;
                          _currentPos =
                              Offset(value.xPosition!, value.yPosition!);
                          _currentScale = value.scale;
                          _currentRotation = value.rotation;
                        },
                        onScaleUpdate: (details) {
                          if (canMove == true) {
                            if (value == null) return;
                            final delta = details.focalPoint - _initPos!;
                            final left =
                                (delta.dx / screen!.width) + _currentPos!.dx;
                            final top =
                                (delta.dy / screen!.height) + _currentPos!.dy;

                            setState(() {
                              value.xPosition = Offset(left, top).dx;
                              value.yPosition = Offset(left, top).dy;
                              value.rotation =
                                  details.rotation + _currentRotation!;
                              value.scale = details.scale * _currentScale!;
                            });
                          }
                          // print(
                          //     "x value = ${left * MediaQuery.of(context).size.width}");
                          // print(
                          //     " y value = ${top * MediaQuery.of(context).size.height}");
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              left: value.xPosition! * screen!.width,
                              top: value.yPosition! * screen!.height,
                              child: Transform.scale(
                                scale: value.scale,
                                child: Transform.rotate(
                                  angle: value.rotation!,
                                  child: Container(
                                    height: value.height,
                                    width: value.width,
                                    child: FittedBox(
                                      fit: BoxFit.fill,
                                      child: Listener(
                                        onPointerDown: (details) {
                                          // if (_inAction) return;
                                          // _inAction = true;
                                          // _activeItem = val;
                                          _initPos = details.position;
                                          _currentPos = Offset(value.xPosition!,
                                              value.yPosition!);
                                          _currentScale = value.scale;
                                          _currentRotation = value.rotation;
                                        },
                                        onPointerUp: (details) {
                                          // _inAction = false;
                                        },
                                        child: InkWell(
                                          child: Container(
                                            height: value.height,
                                            width: value.width,
                                            child: Image.network(
                                              value.gifSelected!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        // child: Image.network(value.name),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Visibility(
                  visible: imageTaken,
                  child: Positioned(
                    bottom: 0,
                    left: 10,
                    right: 10,
                    child: Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: outfitsList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    // selectedGif = gifList[index];
                                    list[0].gifSelected = outfitsList[index];
                                  });
                                },
                                child: CircleAvatar(
                                  minRadius: 40,
                                  backgroundColor: Colors.white,
                                  child: Image.network(
                                      outfitsList[index].toString(),
                                      height: 45),
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text("Loading Effect"),
                  ),
                ],
              ),
            ),
    );
  }
}
