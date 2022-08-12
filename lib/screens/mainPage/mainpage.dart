import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage_helpers.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      body: Stack(
        children: [
          bodyColor(),
          Provider.of<MainPageHelpers>(context, listen: false)
              .bodyImage(context),

          Provider.of<MainPageHelpers>(context, listen: false)
              .mainButton(context),

          // Provider.of<LandingHelpers>(context, listen: false)
          //     .privacyText(context),
        ],
      ),
    );
  }
}
