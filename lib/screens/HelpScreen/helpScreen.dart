import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({Key? key}) : super(key: key);
  final ConstantColors constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Help Pages", context: context),
      backgroundColor: constantColors.bioBg,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 30, vertical: (250 / 100.h * 100).h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
    );
  }
}
