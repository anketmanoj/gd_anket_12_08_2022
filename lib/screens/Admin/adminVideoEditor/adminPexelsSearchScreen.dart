import 'dart:developer';

import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/Admin/adminVideoEditor/adminPreviewPexels.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:diamon_rose_app/services/pexelsService/previewPexelVideo.dart';
import 'package:diamon_rose_app/services/pexelsService/searchForVideoModel.dart'
    as pexel;
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

class AdminPexelsSearchScreen extends StatefulWidget {
  const AdminPexelsSearchScreen();

  @override
  State<AdminPexelsSearchScreen> createState() =>
      _AdminPexelsSearchScreenState();
}

class _AdminPexelsSearchScreenState extends State<AdminPexelsSearchScreen> {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constantColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 20.h,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
          ),
        ),
        backgroundColor: constantColors.black,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Search",
              style: TextStyle(
                color: constantColors.whiteColor,
              ),
            ),
            Container(
              width: 85.w,
              height: 6.h,
              child: TextFormField(
                controller: textController,
                onEditingComplete: () {
                  log("value");
                  setState(() {});
                  FocusScope.of(context).unfocus();
                },
                autocorrect: false,
                style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: constantColors.black,
                  hintText: "Search for video",
                  hintStyle: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.search_outlined,
                    ),
                    color: constantColors.whiteColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      textController.clear();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.clear,
                      color: constantColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: AdminPexelSearch(
          searchQuery: textController.text,
        ),
      ),
    );
  }
}

class AdminPexelSearch extends StatefulWidget {
  final String searchQuery;
  AdminPexelSearch({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<AdminPexelSearch> createState() => _AdminPexelSearchState();
}

class _AdminPexelSearchState extends State<AdminPexelSearch> {
  final ConstantColors constantColors = ConstantColors();

  pexel.SearchForVideoModel? value;

  Future<pexel.SearchForVideoModel?> getSearchPexelResults(
      {required String searchQuery}) async {
    final response = await http.get(
      Uri.parse(
          "https://api.pexels.com/videos/search?query=$searchQuery&per_page=80&orientation=portrait&size=medium"),
      headers: {
        "Authorization":
            "563492ad6f91700001000001933231fd77ce46fab50bdb31e7298df0"
      },
    );
    if (response.statusCode == 200) {
      log("search pexel response full = ${response.body}");
      value = pexel.SearchForVideoModel.fromJson(response.body);

      return value;
    } else {
      log("response.statusCode == ${response.statusCode}");
      log("idhar bro");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<pexel.SearchForVideoModel?>(
      future: getSearchPexelResults(searchQuery: widget.searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data!.videos.isEmpty) {
            return Center(
              child: Text("No Videos found for ${widget.searchQuery}"),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: InkWell(
                  onTap: () async {
                    final url = 'https://www.pexels.com/';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Videos provided by",
                        style: TextStyle(
                          color: constantColors.navButton,
                        ),
                      ),
                      Container(
                        child: Image.asset("assets/images/pexelsLogo.png"),
                        width: 20.w,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: snapshot.data!.videos.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              child: AdminPreviewPexelVideoScreen(
                                  pexelVideoUrl: snapshot
                                      .data!.videos[index].videoFiles[0].link),
                              type: PageTransitionType.fade),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30),
                              ),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      snapshot.data!.videos[index].image),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: InkWell(
                              onTap: () async {
                                final url =
                                    snapshot.data!.videos[index].user.url;
                                if (await canLaunch(url)) {
                                  await launch(
                                    url,
                                    forceSafariVC: false,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: constantColors.greyColor
                                        .withOpacity(0.7)),
                                child: Text(
                                  snapshot.data!.videos[index].user.name
                                      .capitalizeFirst!,
                                  style: TextStyle(
                                      color: constantColors.whiteColor),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(
            child:
                Text("Use the search bar above to search for videos on Pexels"),
          );
        }
      },
    );
  }
}
