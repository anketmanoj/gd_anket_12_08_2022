import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

class AnonProfilePage extends StatelessWidget {
  const AnonProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      body: Stack(
        children: [
          bodyColor(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.h,
                  child: Image.asset(
                    'assets/images/png/GDlogo.png',
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Login Required!",
                  style: TextStyle(
                    color: constantColors.black,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "To interact with all the various features within Glamorous Diastation, please log in!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SubmitButton(
                  function: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: MainPage(), type: PageTransitionType.fade));
                  },
                  text: "Login",
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
