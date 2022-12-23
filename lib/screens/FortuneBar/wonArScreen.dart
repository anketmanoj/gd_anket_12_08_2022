import 'dart:async';
import 'dart:developer' as dev;

import 'package:confetti/confetti.dart';
import 'package:diamon_rose_app/screens/FortuneBar/LuckySpinScreen.dart';
import 'package:diamon_rose_app/screens/FortuneBar/fortuneBarProvider.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:sizer/sizer.dart';

class WonArScreen extends StatefulWidget {
  const WonArScreen();

  @override
  State<WonArScreen> createState() => _WonArScreenState();
}

class _WonArScreenState extends State<WonArScreen> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 2));

    Future.delayed(Duration.zero, () {
      Get.snackbar(
        'AR added to My Materials',
        "Congrats! The AR you've just won has been automatically added to your My Materials Screen!",
        overlayColor: constantColors.navButton,
        colorText: constantColors.whiteColor,
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.elasticInOut,
        reverseAnimationCurve: Curves.easeOut,
      );
      _controllerCenter.play();
      Timer(Duration(seconds: 2), () {
        dev.log("STOP!");
        _controllerCenter.stop();
      });
    });
  }

  @override
  void dispose() {
    _controllerCenter.dispose();

    super.dispose();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FortuneBarProvider>(
      builder: (context, fbp, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: constantColors.transperant,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              bodyColor(),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Won AR from ${fbp.getArRollSelected.ownerName}",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Container(
                              height: 50.h,
                              child: ImageNetworkLoader(
                                  fit: BoxFit.contain,
                                  imageUrl: fbp.getArRollSelected.gif),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.pop(context);
                              Get.off(LuckySpinScreen());
                            },
                            child: Text("Spin Again!"),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Open in AR Viewer"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality
                      .explosive, // don't specify a direction, blast randomly
                  shouldLoop:
                      true, // start again as soon as the animation is finished
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ], // manually specify the colors to be used
                  createParticlePath: drawStar, // define a custom shape/path.
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
