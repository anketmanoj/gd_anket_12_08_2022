import 'dart:developer';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/providers/recommendedProvider.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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

  @override
  void initState() {
    super.initState();

    if (SharedPreferencesHelper.getRecommendedOptions("selected_options")
        .isNotEmpty) {
      selectedOptions =
          SharedPreferencesHelper.getRecommendedOptions("selected_options");

      selectedOptions.forEach((element) {
        _recommendedOptions.remove(element);
      });
    }
  }

  List<String?> _recommendedOptions = [
    LocaleKeys.musician.tr(),
    LocaleKeys.performers.tr(),
    LocaleKeys.dance.tr(),
    LocaleKeys.cosplayers.tr(),
    LocaleKeys.movie.tr(),
    LocaleKeys.actor.tr(),
    LocaleKeys.fashion.tr(),
    LocaleKeys.landscape.tr(),
    LocaleKeys.sports.tr(),
    LocaleKeys.animals.tr(),
    LocaleKeys.space.tr(),
    LocaleKeys.art.tr(),
    LocaleKeys.mystery.tr(),
    LocaleKeys.airplane.tr(),
    LocaleKeys.games.tr(),
    LocaleKeys.food.tr(),
    LocaleKeys.romance.tr(),
    LocaleKeys.sexy.tr(),
    LocaleKeys.sciencefiction.tr(),
    LocaleKeys.car.tr(),
    LocaleKeys.jobs.tr(),
    LocaleKeys.anime.tr(),
    LocaleKeys.ship.tr(),
    LocaleKeys.railroads.tr(),
    LocaleKeys.building.tr(),
    LocaleKeys.health.tr(),
    LocaleKeys.science.tr(),
    LocaleKeys.natural.tr(),
    LocaleKeys.machine.tr(),
    LocaleKeys.trip.tr(),
    LocaleKeys.travel.tr(),
    LocaleKeys.fantasy.tr(),
    LocaleKeys.funny.tr(),
    LocaleKeys.beauty.tr(),
  ];

  List<String> selectedOptions = [];

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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    LocaleKeys.chooseContents.tr(),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.onlytengenres.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Wrap(
                    children: List<Widget>.generate(
                      _recommendedOptions.length,
                      (int idx) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ChoiceChip(
                            backgroundColor: constantColors.whiteColor,
                            label: Text(_recommendedOptions[idx]!),
                            onSelected: (bool selected) {
                              if (selectedOptions.length <= 10) {
                                setState(() {
                                  selectedOptions
                                      .add(_recommendedOptions[idx]!);
                                  _recommendedOptions.removeAt(idx);
                                });
                              } else {
                                Get.dialog(
                                  SimpleDialog(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          "Max choices reached (10 Recommendations)",
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                            selected: false,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Divider(),
                Wrap(
                  children: List<Widget>.generate(
                    selectedOptions.length,
                    (int idx) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ChoiceChip(
                          backgroundColor: constantColors.whiteColor,
                          label: Text(selectedOptions[idx]),
                          onSelected: (bool selected) {
                            setState(() {
                              _recommendedOptions.add(selectedOptions[idx]);
                              selectedOptions.removeAt(idx);
                            });
                          },
                          selected: true,
                        ),
                      );
                    },
                  ).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                SubmitButton(
                  function: () {
                    SharedPreferencesHelper.setRecommendedOptions(
                        "selected_options", selectedOptions);

                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.confirm,
                      title: "Genres Selected!",
                    );
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
