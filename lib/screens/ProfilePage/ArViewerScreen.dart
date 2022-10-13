import 'dart:developer' as dev;
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

class ArViewerPage extends StatefulWidget {
  const ArViewerPage({Key? key, required this.gifUrl}) : super(key: key);
  final String gifUrl;

  @override
  _ArViewerPageState createState() => _ArViewerPageState();
}

class _ArViewerPageState extends State<ArViewerPage> {
  CameraController? controller;
  List<ContainerList> list = [];
  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  bool showCamera = false;
  Size? screen;
  late String selectedGif;
  bool isLoading = false;

  @override
  void initState() {
    screen = Size(400, 500);
    list.add(ContainerList(
      height: 200.0,
      width: 200.0,
      rotation: 0.0,
      scale: 1.0,
      xPosition: 0,
      yPosition: 0,
      gifSelected: widget.gifUrl,
    ));

    dev.log("starting x = ${list[0].xPosition!}");

    super.initState();
    // controller = CameraController(cameras![0], ResolutionPreset.max);
    // controller!.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   controller!.startImageStream(
    //     (CameraImage image) {},
    //   );

    //   setState(() {
    //     isLoading = false;
    //   });
    // });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar2 = AppBar(
      title: const Text('Effect Viewer'),
      backgroundColor: constantColors.black,
    );
    return Scaffold(
      appBar: appBar2,
      backgroundColor: Colors.black,
      body: isLoading == false
          ? Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/arViewer/bg.png",
                    fit: BoxFit.cover,
                  ),
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
                                          onLongPress: () {
                                            setState(() {
                                              list.remove(value);
                                            });
                                          },
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
                // Positioned(
                //   bottom: 0,
                //   left: 10,
                //   right: 10,
                //   child: Container(
                //       height: 200,
                //       child: ListView.builder(
                //         itemCount: gifList.length,
                //         scrollDirection: Axis.horizontal,
                //         itemBuilder: (context, index) {
                //           return Padding(
                //             padding: const EdgeInsets.only(right: 10),
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   // selectedGif = gifList[index];
                //                   screen = Size(400, 500);
                //                   list.add(ContainerList(
                //                     height: 200.0,
                //                     width: 200.0,
                //                     rotation: 0.0,
                //                     scale: 1.0,
                //                     xPosition: 0.2,
                //                     yPosition: 0.2,
                //                     gifSelected: gifList[index],
                //                   ));
                //                 });
                //               },
                //               child: CircleAvatar(
                //                 minRadius: 40,
                //                 backgroundColor: Colors.white,
                //                 child: Image.network(gifList[index].toString(),
                //                     height: 45),
                //               ),
                //             ),
                //           );
                //         },
                //       )),
                // ),
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
