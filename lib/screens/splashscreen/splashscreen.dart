import 'dart:async';
import 'dart:developer';

import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/feedPages/feedPage.dart';
import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConstantColors constantColors = ConstantColors();

  @override
  void initState() {
    Timer(
        const Duration(
          seconds: 1,
        ), () async {
      if (FirebaseAuth.instance.currentUser != null) {
        final bool checkExists = await Provider.of<FirebaseOperations>(context,
                listen: false)
            .checkUserExists(useruid: FirebaseAuth.instance.currentUser!.uid);
        if (checkExists == true) {
          log("anket here -- user exists");
          await Provider.of<Authentication>(context, listen: false)
              .returningUserLogin(FirebaseAuth.instance.currentUser!.uid);
          await FirebaseAuth.instance
              .fetchSignInMethodsForEmail(
                  FirebaseAuth.instance.currentUser!.email!)
              .then((value) {
            final String loginVal = value[0];
            if (loginVal.contains("password")) {
              log("email detected");
              SharedPreferencesHelper.setString("login", "email");
            } else if (loginVal.contains("apple")) {
              log("apple login detected");
              SharedPreferencesHelper.setString("login", "apple");
            } else if (loginVal.contains("google")) {
              log("gmail login detected");
              SharedPreferencesHelper.setString("login", "gmail");
            } else if (loginVal.contains("facebook")) {
              log("facebook login detected");
              SharedPreferencesHelper.setString("login", "facebook");
            }
          });
          context.read<Authentication>().setIsAnon(false);
          Navigator.pushReplacement(context,
              PageTransition(child: FeedPage(), type: PageTransitionType.fade));
          // signed in
        } else {
          log("anket here -- user doesntr");

          // ignore: unawaited_futures
          Navigator.pushReplacement(context,
              PageTransition(child: MainPage(), type: PageTransitionType.fade));
        }
      } else {
        log("User should be anon");
        context.read<Authentication>().setIsAnon(true);
        // ignore: unawaited_futures
        Navigator.pushReplacement(context,
            PageTransition(child: FeedPage(), type: PageTransitionType.fade));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Hero(
              tag: "logo",
              child: Container(
                child: Image.asset("assets/images/png/GDlogo.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
