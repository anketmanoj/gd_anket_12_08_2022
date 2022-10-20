import 'dart:io';

import 'package:diamon_rose_app/services/youtubeUrls.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialVideoScreen extends StatelessWidget {
  TutorialVideoScreen({Key? key}) : super(key: key);

  final List<YoutubeTutorials> youtubeUrls = [
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/Ts427IAxG74", title: "How to Sign Up"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/CzxlwrsNFHE", title: "How to Login"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/5XOUcXOMbAc",
        title: "Explaining the Following and Recommended Tab"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/RZ5bbZy6C1M",
        title: "Navigating the Profile Page Menu"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/e-zsHVwxC2c",
        title: "How to create AR's"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/eXSBx5twVuU",
        title: "How to use the Video Editor"),
    YoutubeTutorials(
        youtubeUrl: "https://youtu.be/hTX2uNm9tCA",
        title: "How to Purchase & Use Carats"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Tutorial Videos", context: context),
      backgroundColor: constantColors.whiteColor,
      body: ListView.builder(
        itemCount: youtubeUrls.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () async {
              final url = youtubeUrls[index].youtubeUrl;
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: false,
                );
              }
            },
            leading: Icon(Icons.arrow_forward_ios),
            trailing: Icon(
              Icons.question_mark_rounded,
              color: constantColors.navButton,
            ),
            title: Text(
              youtubeUrls[index].title,
              style: TextStyle(
                color: constantColors.navButton,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
