// ignore_for_file: flutter_style_todos

import 'dart:io';

import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/mainPage/loginScreen.dart';
import 'package:diamon_rose_app/screens/mainPage/signup_screen.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MainPageHelpers with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();

  bool _hideTutorial = false;
  bool get getHideTutorial => _hideTutorial;

  void setHideTutorial(bool value) {
    _hideTutorial = value;
    SharedPreferencesHelper.setBool("hideTutorial", _hideTutorial);
    notifyListeners();
  }

  Widget bodyImage(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3,
      left: 0,
      right: 0,
      child: Hero(
        tag: "logo",
        child: Container(
          child: Image.asset(
            'assets/images/png/GDlogo.png',
          ),
        ),
      ),
    );
  }

  Widget mainButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.7,
      right: MediaQuery.of(context).size.width * 0.12,
      left: MediaQuery.of(context).size.width * 0.12,
      child: Column(
        children: [
          _LoginOptions(
            constantColors: constantColors,
            text: "Sign up",
            function: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: SignUpscreen(), type: PageTransitionType.fade));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: _LoginOptions(
              constantColors: constantColors,
              text: "Login",
              function: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: LoginScreen(), type: PageTransitionType.fade));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginOptions extends StatelessWidget {
  _LoginOptions({
    Key? key,
    required this.function,
    required this.text,
    required this.constantColors,
  }) : super(key: key);

  void Function()? function;
  String text;

  final ConstantColors constantColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: FlatButton(
        onPressed: function,
        child: Text(
          text,
          style: TextStyle(
            color: constantColors.whiteColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
