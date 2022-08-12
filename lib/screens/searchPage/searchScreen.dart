// ignore_for_file: sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageHelper.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageWidgets.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ConstantColors constantColors = ConstantColors();
  final textController = TextEditingController();
  final PageController pageController = PageController();
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constantColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: size.height * 0.2,
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                  width: size.width,
                  child: Provider.of<SearchPageHelper>(context, listen: false)
                      .topNavBar(context, pageIndex, pageController)),
            ),
            Container(
              width: size.width * 0.85,
              height: size.height * 0.06,
              child: TextFormField(
                controller: textController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: constantColors.black,
                  hintText: "Search by user or video",
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
                  prefixIcon: Icon(
                    Icons.search_outlined,
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
        height: size.height,
        width: size.width,
        child: PageView(
          controller: pageController,
          children: [
            UserSearch(userSearchVal: textController.text),
            VideoSearch(videoSearchVal: textController.text),
            Center(
              child: Text("Hashtags"),
            ),
          ],
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              pageIndex = page;
            });
          },
        ),
      ),
    );
  }
}
