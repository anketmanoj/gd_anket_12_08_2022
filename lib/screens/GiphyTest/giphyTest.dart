import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';

class GiphyTest extends StatefulWidget {
  final String title;
  const GiphyTest({Key? key, required this.title}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _GiphyTestState createState() => _GiphyTestState();
}

class _GiphyTestState extends State<GiphyTest> {
  //Gif
  GiphyGif? currentGif;

  // Giphy Client
  GiphyClient? client;

  // Random ID
  String randomId = "";

  String giphyApiKey = "0X2ffUW2nnfVcPUc2C7alPhfdrj2tA6M";

  @override
  void initState() {
    super.initState();

    client = GiphyClient(apiKey: giphyApiKey, randomId: '');
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      client!.getRandomId().then((value) {
        setState(() {
          randomId = value;
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GiphyGetWrapper(
        giphy_api_key: giphyApiKey,
        builder: (stream, giphyGetWrapper) {
          stream.listen((gif) {
            log("gif id ${gif.id}");
            log("gif source ${gif.embedUrl}");
            log("gif source ${gif.embedUrl}");
            // ! USe this link format https://i.giphy.com/media/${URL_PART}/giphy.gif
            setState(() {
              currentGif = gif;
            });
          });

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Row(
                children: [const Text("GET DEMO")],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Random ID: $randomId"),
                  const Text(
                    "Selected GIF",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  currentGif != null
                      ? SizedBox(
                          child: GiphyGifWidget(
                            imageAlignment: Alignment.center,
                            gif: currentGif!,
                            giphyGetWrapper: giphyGetWrapper,
                            borderRadius: BorderRadius.circular(30),
                            showGiphyLabel: true,
                          ),
                        )
                      : const Text("No GIF")
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  giphyGetWrapper.getGif('', context);
                },
                tooltip: 'Open Sticker',
                child: const Icon(Icons
                    .insert_emoticon)), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}
