import 'dart:math';

import 'package:camera/camera.dart';
import 'package:diamon_rose_app/main.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:xl/xl.dart';

// class ArViewTest extends StatefulWidget {
//   const ArViewTest({Key? key}) : super(key: key);

//   @override
//   State<ArViewTest> createState() => _ArViewerPageState();
// }

// class _ArViewerPageState extends State<ArViewTest> {
//   CameraController? controller;

//   Offset _offset = Offset.zero;
//   Offset _initialFocalPoint = Offset.zero;
//   Offset _sessionOffset = Offset.zero;
//   Offset _initialAngle = Offset.zero;

//   double _scale = 1.0;
//   double _initialScale = 1.0;

//   double _angle = 0.0;

//   late String selectedGif;

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(cameras![0], ResolutionPreset.max);
//     controller!.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       controller!.startImageStream(
//         (CameraImage image) {},
//       );
//       setState(() {
//         selectedGif = gifList[0].toString();
//       });
//     });
//   }

//   List<String> gifList = [
//     'https://thumbs.gfycat.com/EsteemedDimpledEstuarinecrocodile-max-1mb.gif',
//     'https://onlinepngtools.com/images/examples-onlinepngtools/sunset.gif',
//     'https://data.whicdn.com/images/152926369/original.gif',
//     'https://freepikpsd.com/file/2019/11/gif-png-animation-13-Transparent-Images.gif',
//     'https://freepikpsd.com/file/2019/11/funny-gifs-png-5-Transparent-Images.gif',
//     'https://media3.giphy.com/avatars/Kennymays/cyEh4EuvWwqS.gif',
//     'https://pa1.narvii.com/6547/6ff6730ac7ae0ceaac2c00664f0016d794af4859_hq.gif',
//     'https://freight.cargo.site/t/original/i/811f29f9a053002018dcaa5d29222edd4f9fd20378f4ecdb1387121158e1a8ff/original.gif',
//     'https://www.icegif.com/wp-content/uploads/mario-icegif-10.gif',
//   ];

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (controller!.value.isInitialized) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('AR Viewer'),
//         ),
//         body: Stack(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: CameraPreview(
//                 controller!,
//               ),
//             ),
//             Positioned(
//               top: 0,
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: GestureDetector(
//                 onScaleStart: (details) {
//                   _initialFocalPoint = details.focalPoint;
//                   _initialScale = _scale;
//                 },
//                 onScaleUpdate: (details) {
//                   setState(() {
//                     _sessionOffset = details.focalPoint - _initialFocalPoint;
//                     _scale = _initialScale * details.scale;
//                     _angle = details.rotation;
//                   });

//                   print("Anket angle == $_angle");
//                 },
//                 onScaleEnd: (details) {
//                   setState(() {
//                     _offset += _sessionOffset;
//                     _sessionOffset = Offset.zero;
//                   });
//                 },
//                 child: Transform.translate(
//                   offset: _offset + _sessionOffset,
//                   child: Transform.scale(
//                     scale: _scale,
//                     child: Transform.rotate(
//                       angle: _angle,
//                       child: Container(
//                         child: Image.network(
//                           selectedGif,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
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
//                   selectedGif = gifList[index];
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
//     ],
//   ),
// );
//     } else {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Camera Feed'),
//         ),
//         body: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//   }
// }
class ContainerList {
  double? height;
  double? width;
  double? scale;
  double? rotation;
  double? xPosition;
  double? yPosition;
  String? gifSelected;
  double? xRotation;
  double? yRotation;
  double? xOffset;
  double? yOffset;

  ContainerList({
    this.height,
    this.rotation,
    this.scale,
    this.width,
    this.xPosition,
    this.yPosition,
    this.gifSelected,
    this.xOffset,
    this.xRotation,
    this.yOffset,
    this.yRotation,
  });
}

class ArViewTest extends StatefulWidget {
  const ArViewTest({Key? key}) : super(key: key);

  @override
  _ArViewTestState createState() => _ArViewTestState();
}

class _ArViewTestState extends State<ArViewTest> {
  List<ContainerList> list = [];
  Offset? _initPos;
  Offset? _currentPos = Offset(0, 0);
  double? _currentScale;
  double? _currentRotation;
  Size? screen;
  late String selectedGif;
  List<String> gifList = [
    'https://thumbs.gfycat.com/EsteemedDimpledEstuarinecrocodile-max-1mb.gif',
    'https://onlinepngtools.com/images/examples-onlinepngtools/sunset.gif',
    'https://data.whicdn.com/images/152926369/original.gif',
    'https://freepikpsd.com/file/2019/11/gif-png-animation-13-Transparent-Images.gif',
    'https://freepikpsd.com/file/2019/11/funny-gifs-png-5-Transparent-Images.gif',
    'https://media3.giphy.com/avatars/Kennymays/cyEh4EuvWwqS.gif',
    'https://pa1.narvii.com/6547/6ff6730ac7ae0ceaac2c00664f0016d794af4859_hq.gif',
    'https://freight.cargo.site/t/original/i/811f29f9a053002018dcaa5d29222edd4f9fd20378f4ecdb1387121158e1a8ff/original.gif',
    'https://www.icegif.com/wp-content/uploads/mario-icegif-10.gif',
  ];

  @override
  void initState() {
    screen = Size(400, 500);
    list.add(ContainerList(
      height: 200.0,
      width: 200.0,
      rotation: 0.0,
      scale: 1.0,
      xPosition: 0.1,
      yPosition: 0.1,
      gifSelected: gifList[0],
      xRotation: 1.0,
      yRotation: 1.0,
      xOffset: 50,
      yOffset: 50,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: constantColors.greyColor,
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Stack(
              children: list.map((value) {
                return XL(
                  layers: [
                    XLayer(
                      xRotation: value.xRotation!,
                      yRotation: value.yRotation!,
                      xOffset: value.xOffset!,
                      yOffset: value.yOffset!,
                      child: GestureDetector(
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
                                        child: Container(
                                          height: value.height,
                                          width: value.width,
                                          child: Image.network(
                                            value.gifSelected!,
                                            fit: BoxFit.contain,
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
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Container(
                height: 200,
                child: ListView.builder(
                  itemCount: gifList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            // selectedGif = gifList[index];
                            screen = Size(400, 500);
                            list.add(ContainerList(
                              height: 200.0,
                              width: 200.0,
                              rotation: 0.0,
                              scale: 1.0,
                              xPosition: 0.2,
                              yPosition: 0.2,
                              gifSelected: gifList[index],
                              xRotation: 1.0,
                              yRotation: 1.0,
                              xOffset: list.last.xOffset! + 50,
                              yOffset: list.last.xOffset! + 50,
                            ));
                          });
                        },
                        child: CircleAvatar(
                          minRadius: 40,
                          backgroundColor: Colors.white,
                          child: Image.network(gifList[index].toString(),
                              height: 45),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
