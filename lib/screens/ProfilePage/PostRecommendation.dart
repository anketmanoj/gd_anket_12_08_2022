import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class PostRecommendationScreen extends StatefulWidget {
  PostRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<PostRecommendationScreen> createState() =>
      _PostRecommendationScreenState();
}

class _PostRecommendationScreenState extends State<PostRecommendationScreen> {
  ConstantColors constantColors = ConstantColors();

  // set selected recommendation list of strings to shared preference
  Future<void> _setSelectedRecommendationListToSharedPrefs(
      List<String> selectedRecommendationList) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selected_recommendations';
    final value = selectedRecommendationList;
    await prefs.setStringList(key, value);
  }

  List<String> _defaultRecommendedOptions = [
    'Musician',
    'Performer',
    'Dance',
    'Cosplayers',
    'Movie',
    'Actor',
    'Fashion',
    'Landscape',
    'Sports',
    'Animals',
    'Space',
    'Art',
    'Mystery',
    'Airplane',
    'Games',
    'Food',
    'Romance',
    'Sexy',
    'Science fiction',
    'Car',
    'Jobs',
    'Anime',
    'Ship',
    'Railroads',
    'Building',
    'Health',
    'Science',
    'Natural',
    'Machine',
    'Trip',
    'Travel',
    'Fantasy',
    'Funny',
    'Beauty',
  ];

  List<String?> _recommendedOptions = [
    'Musician',
    'Performer',
    'Dance',
    'Cosplayers',
    'Movie',
    'Actor',
    'Fashion',
    'Landscape',
    'Sports',
    'Animals',
    'Space',
    'Art',
    'Mystery',
    'Airplane',
    'Games',
    'Food',
    'Romance',
    'Sexy',
    'Science fiction',
    'Car',
    'Jobs',
    'Anime',
    'Ship',
    'Railroads',
    'Building',
    'Health',
    'Science',
    'Natural',
    'Machine',
    'Trip',
    'Travel',
    'Fantasy',
    'Funny',
    'Beauty',
  ];

  @override
  Widget build(BuildContext context) {
    final RecommendedProvider recommendedProvider =
        Provider.of<RecommendedProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 0.9],
            colors: [
              Color(0xFF760380),
              Color(0xFFE6ADFF),
              constantColors.whiteColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Choose what kind of contents you would like to see in your \"recommended\" page",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "You can choose up to 10 genres",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Container(
                            height: size.height,
                            child: MultiSelectChipField<String?>(
                              headerColor: constantColors.mainColor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              selectedChipColor:
                                  constantColors.black.withOpacity(0.4),
                              selectedTextStyle: TextStyle(
                                color: constantColors.whiteColor,
                              ),
                              showHeader: false,
                              scroll: false,
                              items: _recommendedOptions.map((e) {
                                return MultiSelectItem("$e", "$e");
                              }).toList(),
                              onTap: (values) {
                                if (values.length == 0) {
                                  _setSelectedRecommendationListToSharedPrefs(
                                      _defaultRecommendedOptions);
                                } else if (values.length > 10) {
                                  // show snackbar error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "You can only choose up to 10 genres")));
                                } else {
                                  _setSelectedRecommendationListToSharedPrefs(
                                      values.map((e) => "$e").toList());
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // child: Stack(
        //   children: [
        //     Positioned(
        //       top: size.height * 0.08,
        //       left: 10,
        //       child: IconButton(
        //         onPressed: () => Navigator.pop(context),
        //         icon: Icon(
        //           Icons.arrow_back_ios,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //       top: size.height * 0.15,
        //       left: 10,
        //       right: 10,
        //       bottom: 5,
        //       child: Container(
        //         child: Column(
        //           children: [
        //             Container(
        //               padding: EdgeInsets.symmetric(horizontal: 20),
        //               child: Text(
        //                 "Choose what kind of contents you would like to see in your \"recommended\" page",
        //                 textAlign: TextAlign.center,
        //                 style: TextStyle(
        //                   fontSize: 20,
        //                   color: Colors.white,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.only(top: 20),
        //               child: Container(
        //                 padding: EdgeInsets.symmetric(horizontal: 20),
        //                 child: Text(
        //                   "You can choose up to 10 genres",
        //                   textAlign: TextAlign.center,
        //                   style: TextStyle(
        //                     fontSize: 16,
        //                     color: Colors.white,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.only(top: 25),
        //               child: Container(
        //                 height: size.height * 0.6,
        //                 child: MultiSelectChipField<String?>(
        //                   headerColor: constantColors.mainColor,
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(20),
        //                   ),
        //                   selectedChipColor:
        //                       constantColors.black.withOpacity(0.4),
        //                   selectedTextStyle: TextStyle(
        //                     color: constantColors.whiteColor,
        //                   ),
        //                   showHeader: false,
        //                   scroll: false,
        //                   items: _recommendedOptions.map((e) {
        //                     return MultiSelectItem("$e", "$e");
        //                   }).toList(),
        //                   onTap: (values) {
        //                     if (values.length == 0) {
        //                       _setSelectedRecommendationListToSharedPrefs(
        //                           _defaultRecommendedOptions);
        //                     } else if (values.length > 10) {
        //                       // show snackbar error
        //                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                           content: Text(
        //                               "You can only choose up to 10 genres")));
        //                     } else {
        //                       _setSelectedRecommendationListToSharedPrefs(
        //                           values.map((e) => "$e").toList());
        //                     }
        //                   },
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
