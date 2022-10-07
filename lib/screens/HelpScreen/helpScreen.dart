import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/HelpScreen/tutorialVideos.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: LocaleKeys.helpscreen.tr(), context: context),
      backgroundColor: constantColors.bioBg,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Center(
          child: Container(
            height: 40.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SubmitButton(
                  text: "Tutorial Videos",
                  function: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: TutorialVideoScreen(),
                            type: PageTransitionType.fade));
                  },
                ),
                SubmitButton(
                  text: "Terms of Use",
                  function: () async {
                    final url =
                        'https://diamantrose.co.jp/en/works/glamorous-diastation/terms-en/termsofusegd/';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                      );
                    }
                  },
                ),
                SubmitButton(
                  text: "Privacy Policy",
                  function: () async {
                    final url =
                        'https://diamantrose.co.jp/en/works/glamorous-diastation/terms-en/privacypolicy/';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                      );
                    }
                  },
                ),
                SubmitButton(
                  text: "Cookie Policy",
                  function: () async {
                    final url =
                        'https://diamantrose.co.jp/works/glamorous-diastation/terms/cookie-policy/';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
