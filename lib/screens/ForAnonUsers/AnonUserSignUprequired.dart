import 'package:diamon_rose_app/screens/mainPage/mainpage.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

Future SignUpRequired(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    builder: (context) {
      return Container(
        height: 60.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: constantColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.greyColor,
                ),
              ),
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
      );
    },
  );
}
