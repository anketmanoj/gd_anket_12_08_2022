import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class VideoTemplateFeatureScreen extends StatelessWidget {
  const VideoTemplateFeatureScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: constantColors.transperant,
        elevation: 0,
      ),
      body: Stack(
        children: [
          bodyColor(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 9,
                        child: Container(
                          child: Center(
                            child: Container(
                              height: 30.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/GDlogo.png')),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          child: Column(
                            children: [
                              Text(
                                "Use Template",
                                style: TextStyle(
                                  color: constantColors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Replace the clips with your own!",
                                style: TextStyle(
                                  color: constantColors.greyColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: constantColors.greyColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [],
                        ),
//
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
