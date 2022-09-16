import 'dart:async';

import 'package:diamon_rose_app/screens/GiphyTest/gigphy_get_anket.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';

//Builder
typedef GiphyGetWrapperBuilder = Widget Function(
    Stream<GiphyGif>, AnketGiphyGetWrapper);

class AnketGiphyGetWrapper extends StatelessWidget {
  final String giphy_api_key;
  final GiphyGetWrapperBuilder builder;
  final StreamController<GiphyGif> streamController =
      new StreamController.broadcast();

  AnketGiphyGetWrapper(
      {Key? key, required this.giphy_api_key, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(streamController.stream, this);
  }

  getGif(String queryText, BuildContext context) async {
    GiphyGif? gif = await GiphyGetAnket.getAnketGif(
      queryText: queryText,
      tabColor: constantColors.navButton,

      context: context,
      apiKey: giphy_api_key, //YOUR API KEY HERE
      lang: GiphyLanguage.spanish,
    );
    if (gif != null) streamController.add(gif);
    // stream.add(gif!);
  }
}
